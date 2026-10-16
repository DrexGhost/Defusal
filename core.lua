local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

local Core = {}

Core.CONFIG_FILE = "NexusXDefusal.json"
Core.CONFIG_FOLDER = "DefusalConfigs"
Core.BOMB_TIME = 40
Core.BUTTON_DEFAULT_SIZE = 58

Core.BOMB_COLORS = {
    {name = "Red", color = Color3.fromRGB(255, 50, 50)},
    {name = "Orange", color = Color3.fromRGB(255, 150, 0)},
    {name = "Yellow", color = Color3.fromRGB(255, 220, 0)},
    {name = "Green", color = Color3.fromRGB(50, 255, 50)},
    {name = "Cyan", color = Color3.fromRGB(0, 220, 255)},
    {name = "Blue", color = Color3.fromRGB(50, 120, 255)},
    {name = "Purple", color = Color3.fromRGB(180, 50, 255)},
    {name = "Pink", color = Color3.fromRGB(255, 100, 200)},
    {name = "White", color = Color3.fromRGB(255, 255, 255)},
}

Core.teamColor = Color3.fromRGB(0, 150, 255)
Core.enemyColor = Color3.fromRGB(255, 0, 0)

Core.T = {
    bg1 = Color3.fromRGB(14, 18, 32),
    bg2 = Color3.fromRGB(6, 9, 18),
    panel = Color3.fromRGB(20, 26, 44),
    panelHi = Color3.fromRGB(30, 38, 62),
    card = Color3.fromRGB(24, 30, 50),
    cardHover = Color3.fromRGB(34, 42, 68),
    row = Color3.fromRGB(26, 32, 52),
    accent = Color3.fromRGB(0, 229, 204),
    accentDim = Color3.fromRGB(0, 140, 128),
    accentSoft = Color3.fromRGB(140, 250, 235),
    text = Color3.fromRGB(232, 238, 248),
    textDim = Color3.fromRGB(150, 162, 190),
    textMuted = Color3.fromRGB(90, 102, 130),
    stroke = Color3.fromRGB(44, 54, 86),
    success = Color3.fromRGB(80, 230, 140),
    warn = Color3.fromRGB(255, 200, 80),
    danger = Color3.fromRGB(255, 90, 110),
    toggleOff = Color3.fromRGB(48, 58, 88),
    online = Color3.fromRGB(80, 230, 140),
    blue = Color3.fromRGB(70, 130, 220),
    blueHi = Color3.fromRGB(90, 150, 240),
}

Core.settings = {
    menuOpen = true,
    esp = false,
    espHitbox = false,
    espTeam = false,
    espNick = false,
    espDist = false,
    espHP = false,
    espWeapon = false,
    espTracer = false,
    espBomb = false,
    hitboxBomb = false,
    labelBomb = false,
    bombColorIndex = 1,
    aimbot = false,
    aimbotTeam = false,
    wallhack = false,
    aimbotSpeed = 5,
    aimbotPart = "Head",
    aimbotFov = 100,
    showFovCircle = false,
    silentAim = false,
    silentTeam = false,
    silentWallbang = false,
    silentShowFovCircle = false,
    silentFov = 50,
    silentPart = "Head",
    noclip = false,
    speed = false,
    walkSpeed = 50,
    floatBtnPos = {0, 20, 0.5, 0},
    floatBtnSize = 58,
    guiScale = 85,
    watermark = false,
    watermarkScale = 100,
}

Core.toggleRefs = {}
Core.sliderRefs = {}
Core.partBtnRefs = {}

Core.dataStore = nil

function Core.loadSettings()
    local success, result = pcall(function()
        if not LocalPlayer:FindFirstChild("DefusalSettings") then
            local ds = Instance.new("Folder")
            ds.Name = "DefusalSettings"
            ds.Parent = LocalPlayer
        end
        return LocalPlayer.DefusalSettings
    end)
    if success and result then
        Core.dataStore = result
        for name, defaultValue in pairs(Core.settings) do
            local stored = Core.dataStore:FindFirstChild(name)
            if stored then
                if stored:GetAttribute("dataType") == "table" and stored:IsA("StringValue") then
                    local ok, decoded = pcall(function()
                        return HttpService:JSONDecode(stored.Value)
                    end)
                    if ok then Core.settings[name] = decoded end
                elseif type(defaultValue) == type(stored.Value) then
                    Core.settings[name] = stored.Value
                end
            end
        end
    end
end

function Core.saveSetting(name, value)
    Core.settings[name] = value
    if not Core.dataStore then return end

    local stored = Core.dataStore:FindFirstChild(name)
    local dataType
    if type(value) == "table" then
        dataType = "table"
    elseif typeof(value) == "string" then
        dataType = "string"
    elseif typeof(value) == "number" then
        dataType = "number"
    else
        dataType = "bool"
    end

    if stored and stored:GetAttribute("dataType") ~= dataType then
        stored:Destroy()
        stored = nil
    end

    if not stored then
        if dataType == "table" then
            stored = Instance.new("StringValue")
            stored:SetAttribute("dataType", "table")
        elseif dataType == "string" then
            stored = Instance.new("StringValue")
        elseif dataType == "number" then
            stored = Instance.new("NumberValue")
        else
            stored = Instance.new("BoolValue")
        end
        stored.Name = name
        stored.Parent = Core.dataStore
    end

    if dataType == "table" then
        stored.Value = HttpService:JSONEncode(value)
    else
        stored.Value = value
    end
end

function Core.ensureFolder()
    if not isfolder or not makefolder then return false end
    local ok = pcall(function()
        if not isfolder(Core.CONFIG_FOLDER) then
            makefolder(Core.CONFIG_FOLDER)
        end
    end)
    return ok
end

function Core.isValidConfigName(name)
    if type(name) ~= "string" then return false end
    if #name < 1 or #name > 30 then return false end
    if not name:match("^[%w_%-]+$") then return false end
    return true
end

function Core.listConfigs()
    if not isfolder or not listfiles then return {} end
    if not Core.ensureFolder() then return {} end
    local result = {}
    local ok, files = pcall(function()
        return listfiles(Core.CONFIG_FOLDER)
    end)
    if not ok or type(files) ~= "table" then return result end
    for _, filePath in ipairs(files) do
        local fileName = tostring(filePath):match("([^/\\]+)$") or tostring(filePath)
        local n = fileName:match("^(.+)%.json$")
        if n then table.insert(result, n) end
    end
    table.sort(result)
    return result
end

function Core.saveConfigAs(name)
    if not Core.isValidConfigName(name) then
        return false, "Invalid name"
    end
    if not Core.ensureFolder() then
        return false, "File system not available"
    end
    local data = {}
    for k, v in pairs(Core.settings) do
        data[k] = v
    end
    local ok, encoded = pcall(function()
        return HttpService:JSONEncode(data)
    end)
    if not ok then return false, "JSON encode failed" end
    local path = Core.CONFIG_FOLDER .. "/" .. name .. ".json"
    local ok2, err = pcall(function()
        writefile(path, encoded)
    end)
    if not ok2 then return false, tostring(err) end
    return true
end

function Core.loadConfigFrom(name)
    if not Core.isValidConfigName(name) then
        return false, "Invalid name"
    end
    if not isfile then return false, "File system not available" end
    local path = Core.CONFIG_FOLDER .. "/" .. name .. ".json"
    if not isfile(path) then
        return false, "Config not found"
    end
    local ok, contents = pcall(function()
        return readfile(path)
    end)
    if not ok then return false, tostring(contents) end
    local ok2, decoded = pcall(function()
        return HttpService:JSONDecode(contents)
    end)
    if not ok2 then return false, "JSON decode failed" end
    if type(decoded) ~= "table" then return false, "Invalid config" end
    for k, v in pairs(decoded) do
        if Core.settings[k] ~= nil then
            local currentType = type(Core.settings[k])
            local newType = type(v)
            if currentType == newType then
                Core.settings[k] = v
                Core.saveSetting(k, v)
            end
        end
    end
    return true
end

function Core.deleteConfig(name)
    if not Core.isValidConfigName(name) then return false end
    if not isfolder or not delfile then return false end
    local path = Core.CONFIG_FOLDER .. "/" .. name .. ".json"
    local ok = pcall(function() delfile(path) end)
    return ok
end

function Core.saveConfig()
    local data = {}
    for k, v in pairs(Core.settings) do
        data[k] = v
    end
    local ok, encoded = pcall(function()
        return HttpService:JSONEncode(data)
    end)
    if not ok then return false, "JSON encode failed" end
    local ok2, err = pcall(function()
        writefile(Core.CONFIG_FILE, encoded)
    end)
    if not ok2 then return false, tostring(err) end
    return true
end

function Core.loadConfig()
    if not isfile(Core.CONFIG_FILE) then return false, "File not found" end
    local ok, contents = pcall(function()
        return readfile(Core.CONFIG_FILE)
    end)
    if not ok then return false, tostring(contents) end
    local ok2, decoded = pcall(function()
        return HttpService:JSONDecode(contents)
    end)
    if not ok2 then return false, "JSON decode failed" end
    if type(decoded) ~= "table" then return false, "Invalid config" end
    for k, v in pairs(decoded) do
        if Core.settings[k] ~= nil then
            local currentType = type(Core.settings[k])
            local newType = type(v)
            if currentType == newType then
                Core.settings[k] = v
                Core.saveSetting(k, v)
            end
        end
    end
    return true
end

return Core

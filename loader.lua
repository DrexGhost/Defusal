local player = game.Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local base = "https://raw.githubusercontent.com/DrexGhost/Defusal/main/"

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DefusalLoaderLog"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 6000
screenGui.Parent = PlayerGui

local logFrame = Instance.new("Frame")
logFrame.Size = UDim2.new(0, 520, 0, 400)
logFrame.Position = UDim2.new(0.5, -260, 0.5, -200)
logFrame.BackgroundColor3 = Color3.fromRGB(14, 18, 32)
logFrame.BorderSizePixel = 0
logFrame.Parent = screenGui

local logCorner = Instance.new("UICorner")
logCorner.CornerRadius = UDim.new(0, 12)
logCorner.Parent = logFrame

local logStroke = Instance.new("UIStroke")
logStroke.Color = Color3.fromRGB(44, 54, 86)
logStroke.Thickness = 1
logStroke.Parent = logFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 36)
title.BackgroundColor3 = Color3.fromRGB(20, 26, 44)
title.BorderSizePixel = 0
title.Text = "DEFUSAL LOADER"
title.TextColor3 = Color3.fromRGB(232, 238, 248)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.Parent = logFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = title

local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(0, 70, 0, 26)
copyBtn.Position = UDim2.new(1, -104, 0, 5)
copyBtn.BackgroundColor3 = Color3.fromRGB(0, 229, 204)
copyBtn.BorderSizePixel = 0
copyBtn.Text = "COPY"
copyBtn.TextColor3 = Color3.fromRGB(10, 14, 24)
copyBtn.TextSize = 11
copyBtn.Font = Enum.Font.GothamBold
copyBtn.AutoButtonColor = false
copyBtn.Parent = title

local copyCorner = Instance.new("UICorner")
copyCorner.CornerRadius = UDim.new(0, 6)
copyCorner.Parent = copyBtn

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -32, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 90, 110)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 12
closeBtn.Font = Enum.Font.GothamBold
closeBtn.AutoButtonColor = false
closeBtn.Parent = title

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    logFrame.Visible = false
end)

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -16, 1, -46)
scroll.Position = UDim2.new(0, 8, 0, 40)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 229, 204)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = logFrame

local logLayout = Instance.new("UIListLayout")
logLayout.Padding = UDim.new(0, 3)
logLayout.SortOrder = Enum.SortOrder.LayoutOrder
logLayout.Parent = scroll

local logPad = Instance.new("UIPadding")
logPad.PaddingBottom = UDim.new(0, 6)
logPad.PaddingRight = UDim.new(0, 6)
logPad.Parent = scroll

local C_OK = Color3.fromRGB(80, 230, 140)
local C_FAIL = Color3.fromRGB(255, 90, 110)
local C_INFO = Color3.fromRGB(150, 162, 190)
local C_ACC = Color3.fromRGB(0, 229, 204)
local C_WARN = Color3.fromRGB(255, 200, 80)

local logLines = {}

local function log(text, color)
    table.insert(logLines, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 16)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color or Color3.fromRGB(232, 238, 248)
    lbl.TextSize = 11
    lbl.Font = Enum.Font.Code
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextWrapped = true
    lbl.Parent = scroll
end

copyBtn.MouseButton1Click:Connect(function()
    local text = table.concat(logLines, "\n")
    if setclipboard then
        setclipboard(text)
        copyBtn.Text = "OK!"
        task.wait(1)
        copyBtn.Text = "COPY"
    else
        copyBtn.Text = "N/A"
        task.wait(1)
        copyBtn.Text = "COPY"
    end
end)

local function fetch(name)
    local url = base .. name
    local ok, code = pcall(function()
        return game:HttpGet(url)
    end)
    if not ok then
        log("[FAIL] fetch " .. name .. ": " .. tostring(code), C_FAIL)
        return nil
    end
    log("[OK] fetched " .. name .. " (" .. #code .. "b)", C_OK)
    return code
end

local function compile(name, code)
    local fn, err = loadstring(code)
    if not fn then
        log("[FAIL] compile " .. name, C_FAIL)
        log("   " .. tostring(err), C_FAIL)
        return nil
    end
    log("[OK] compiled " .. name, C_OK)
    return fn
end

local function run(name, fn, ...)
    if not fn then
        log("[SKIP] " .. name .. " — no function", C_WARN)
        return nil
    end
    local ok, result = pcall(fn, ...)
    if not ok then
        log("[FAIL] run " .. name, C_FAIL)
        log("   " .. tostring(result), C_FAIL)
        return nil
    end
    log("[OK] ran " .. name, C_OK)
    return result
end

log("START LOADER", C_ACC)
log("", C_INFO)

local Core = run("core.lua", compile("core.lua", fetch("core.lua")))
if not Core then
    log("КРИТИЧЕСКАЯ ОШИБКА: Core не загрузился", C_FAIL)
    return
end

Core.loadSettings()
Core.settings.noclip = false
Core.settings.speed = false
Core.saveSetting("noclip", false)
Core.saveSetting("speed", false)

log("", C_INFO)

local GUI = run("gui.lua", compile("gui.lua", fetch("gui.lua")), Core)
if not GUI then
    log("КРИТИЧЕСКАЯ ОШИБКА: GUI не загрузился", C_FAIL)
    return
end

log("", C_INFO)

local Logic = run("esp_logic.lua", compile("esp_logic.lua", fetch("esp_logic.lua")), Core, GUI)
if not Logic then
    log("КРИТИЧЕСКАЯ ОШИБКА: Logic не загрузился", C_FAIL)
    return
end

log("", C_INFO)
log("=== ЗАГРУЗКА ВКЛАДОК ===", C_ACC)

local function loadTab(name)
    local code = fetch(name)
    if not code then return end
    local fn = compile(name, code)
    if not fn then return end
    local ok, build = pcall(fn, Core, GUI, Logic)
    if not ok then
        log("[FAIL] build " .. name, C_FAIL)
        log("   " .. tostring(build), C_FAIL)
        return
    end
    if type(build) == "function" then
        local ok2, err = pcall(build)
        if not ok2 then
            log("[FAIL] call build " .. name, C_FAIL)
            log("   " .. tostring(err), C_FAIL)
            return
        end
        log("[OK] " .. name .. " tab created", C_OK)
    else
        log("[WARN] " .. name .. " — build is not a function", C_WARN)
    end
end

loadTab("main.lua")
loadTab("esp.lua")
loadTab("combat.lua")
loadTab("movement.lua")
loadTab("settings.lua")

log("", C_INFO)
log("=== ПОСЛЕ ЗАГРУЗКИ ===", C_ACC)

local tabsCount = #GUI._tabs
local pagesCount = #GUI._pages
log("Вкладок создано: " .. tostring(tabsCount), tabsCount > 0 and C_OK or C_FAIL)
log("Страниц создано: " .. tostring(pagesCount), pagesCount > 0 and C_OK or C_FAIL)

local okActivate = pcall(function()
    GUI.activateFirstTab()
end)
if okActivate then
    log("[OK] GUI.activateFirstTab", C_OK)
else
    log("[FAIL] GUI.activateFirstTab", C_FAIL)
end

local okState = pcall(function()
    GUI.setOpenState(Core.settings.menuOpen)
end)
if okState then
    log("[OK] GUI.setOpenState", C_OK)
else
    log("[FAIL] GUI.setOpenState", C_FAIL)
end

local okEvents = pcall(function()
    Logic.setupEvents()
end)
if okEvents then
    log("[OK] Logic.setupEvents", C_OK)
else
    log("[FAIL] Logic.setupEvents", C_FAIL)
end

local okLoop = pcall(function()
    Logic.startLoop()
end)
if okLoop then
    log("[OK] Logic.startLoop", C_OK)
else
    log("[FAIL] Logic.startLoop", C_FAIL)
end

log("", C_INFO)
log("Вкладок в GUI: " .. tostring(#GUI._tabs), C_ACC)
log("Menu visible: " .. tostring(GUI.Main.Visible), C_ACC)
log("", C_INFO)
log("LOADER DONE", C_ACC)
log("Открой меню по Left Alt", C_INFO)

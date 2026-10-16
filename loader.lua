local base = "https://raw.githubusercontent.com/DrexGhost/Defusal/main/"

local function fetch(name)
    local url = base .. name
    local ok, code = pcall(function()
        return game:HttpGet(url)
    end)
    if not ok then
        warn("[Defusal] fetch failed: " .. name .. " — " .. tostring(code))
        return nil
    end
    return code
end

local function compile(name, code)
    if not code then return nil end
    local fn, err = loadstring(code)
    if not fn then
        warn("[Defusal] compile failed: " .. name .. " — " .. tostring(err))
        return nil
    end
    return fn
end

local function run(name, fn, ...)
    if not fn then return nil end
    local ok, result = pcall(fn, ...)
    if not ok then
        warn("[Defusal] run failed: " .. name .. " — " .. tostring(result))
        return nil
    end
    return result
end

local Core = run("core.lua", compile("core.lua", fetch("core.lua")))
if not Core then return end

Core.loadSettings()

Core.settings.noclip = false
Core.settings.speed = false
Core.saveSetting("noclip", false)
Core.saveSetting("speed", false)

local GUI = run("gui.lua", compile("gui.lua", fetch("gui.lua")), Core)
if not GUI then return end

local Logic = run("esp_logic.lua", compile("esp_logic.lua", fetch("esp_logic.lua")), Core, GUI)
if not Logic then return end

local function loadTab(name)
    local code = fetch(name)
    if not code then return end
    local fn = compile(name, code)
    if not fn then return end
    local ok, build = pcall(fn, Core, GUI, Logic)
    if not ok then
        warn("[Defusal] tab build failed: " .. name .. " — " .. tostring(build))
        return
    end
    if type(build) == "function" then
        local ok2, err = pcall(build)
        if not ok2 then
            warn("[Defusal] tab call failed: " .. name .. " — " .. tostring(err))
        end
    end
end

loadTab("main.lua")
loadTab("esp.lua")
loadTab("combat.lua")
loadTab("movement.lua")
loadTab("settings.lua")

pcall(function() GUI.activateFirstTab() end)
pcall(function() GUI.setOpenState(Core.settings.menuOpen) end)
pcall(function() Logic.setupEvents() end)
pcall(function() Logic.startLoop() end)

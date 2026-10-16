local base = "https://raw.githubusercontent.com/DrexGhost/Defusal/main/"

local function load(name)
    local url = base .. name
    local ok, code = pcall(function()
        return game:HttpGet(url)
    end)
    if not ok then
        warn("[Defusal] Failed to fetch " .. name .. ": " .. tostring(code))
        return nil
    end
    local fn, err = loadstring(code)
    if not fn then
        warn("[Defusal] Failed to compile " .. name .. ": " .. tostring(err))
        return nil
    end
    local ok2, result = pcall(fn)
    if not ok2 then
        warn("[Defusal] Failed to run " .. name .. ": " .. tostring(result))
        return nil
    end
    return result
end

local Core = load("core.lua")
if not Core then return end

Core.loadSettings()

Core.settings.noclip = false
Core.settings.speed = false
Core.saveSetting("noclip", false)
Core.saveSetting("speed", false)

local GUI = load("gui.lua", Core)
if not GUI then return end

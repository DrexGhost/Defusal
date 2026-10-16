local Core, GUI, Logic = ...

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local T = Core.T
local settings = Core.settings

local function build()
    local tab = GUI.makeTab("Movement", 5, "motion")
    local page = GUI.makePage()

    GUI.makeSectionHeader(page, "Player", 1)

    GUI.makeToggle(page, "Noclip", "Проходить сквозь стены", settings.noclip, 2, function(v)
        settings.noclip = v
        if v then
            local oldConn = Logic.getNoclipConnection()
            if oldConn then oldConn:Disconnect() end
            Logic.applyNoclip()
            local conn = RunService.Stepped:Connect(function()
                if settings.noclip and LocalPlayer.Character then
                    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end)
            Logic.setNoclipConnection(conn)
        else
            local oldConn = Logic.getNoclipConnection()
            if oldConn then oldConn:Disconnect() end
            Logic.setNoclipConnection(nil)
            Logic.removeNoclip()
        end
    end, "noclip")

    GUI.makeToggle(page, "Speed", "Ускорение", settings.speed, 3, function(v)
        settings.speed = v
        if v then
            local oldConn = Logic.getSpeedConnection()
            if oldConn then oldConn:Disconnect() end
            local conn = RunService.Heartbeat:Connect(function()
                if settings.speed and LocalPlayer.Character then
                    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum.WalkSpeed = settings.walkSpeed end
                end
            end)
            Logic.setSpeedConnection(conn)
        else
            local oldConn = Logic.getSpeedConnection()
            if oldConn then oldConn:Disconnect() end
            Logic.setSpeedConnection(nil)
            if LocalPlayer.Character then
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = 16 end
            end
        end
    end, "speed")

    GUI.makeSlider(page, "Walk Speed", 16, 200, settings.walkSpeed, 4, function(v)
        settings.walkSpeed = v
    end, "walkSpeed")

    tab.Button.MouseButton1Click:Connect(function()
        GUI.switchTab(tab, page)
    end)

    return tab, page
end

return build

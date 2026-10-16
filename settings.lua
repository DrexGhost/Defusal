local Core = ...
local GUI = ...
local Logic = ...

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local T = Core.T
local settings = Core.settings

local function refreshAllUI()
    local function refreshToggle(name, val)
        local ref = Core.toggleRefs[name]
        if ref and ref.setEnabled then
            ref.setEnabled(val, true)
        end
    end

    refreshToggle("esp", settings.esp)
    refreshToggle("espHitbox", settings.espHitbox)
    refreshToggle("espTeam", settings.espTeam)
    refreshToggle("espNick", settings.espNick)
    refreshToggle("espDist", settings.espDist)
    refreshToggle("espHP", settings.espHP)
    refreshToggle("espWeapon", settings.espWeapon)
    refreshToggle("espTracer", settings.espTracer)
    refreshToggle("espBomb", settings.espBomb)
    refreshToggle("hitboxBomb", settings.hitboxBomb)
    refreshToggle("labelBomb", settings.labelBomb)
    refreshToggle("aimbot", settings.aimbot)
    refreshToggle("aimbotTeam", settings.aimbotTeam)
    refreshToggle("wallhack", settings.wallhack)
    refreshToggle("showFovCircle", settings.showFovCircle)
    refreshToggle("silentAim", settings.silentAim)
    refreshToggle("silentTeam", settings.silentTeam)
    refreshToggle("silentWallbang", settings.silentWallbang)
    refreshToggle("silentShowFovCircle", settings.silentShowFovCircle)
    refreshToggle("noclip", settings.noclip)
    refreshToggle("speed", settings.speed)

    if Core.sliderRefs["aimbotSpeed"] then Core.sliderRefs["aimbotSpeed"].setValue(settings.aimbotSpeed, true) end
    if Core.sliderRefs["aimbotFov"] then Core.sliderRefs["aimbotFov"].setValue(settings.aimbotFov, true) end
    if Core.sliderRefs["silentFov"] then Core.sliderRefs["silentFov"].setValue(settings.silentFov, true) end
    if Core.sliderRefs["walkSpeed"] then Core.sliderRefs["walkSpeed"].setValue(settings.walkSpeed, true) end
    if Core.sliderRefs["guiScale"] then Core.sliderRefs["guiScale"].setValue(settings.guiScale, true) end
    if Core.sliderRefs["floatBtnSize"] then Core.sliderRefs["floatBtnSize"].setValue(settings.floatBtnSize, true) end

    if Core.partBtnRefs["aimbot"] then
        Core.partBtnRefs["aimbot"].Text = "Aim Part: " .. settings.aimbotPart
    end
    if Core.partBtnRefs["silent"] then
        Core.partBtnRefs["silent"].Text = "Silent Part: " .. settings.silentPart
    end

    if Core.bombColorBtnRef then
        local idx = settings.bombColorIndex or 1
        if idx < 1 or idx > #Core.BOMB_COLORS then idx = 1 end
        Core.bombColorBtnRef.Text = "Bomb Color: " .. Core.BOMB_COLORS[idx].name
        Core.bombColorBtnRef.TextColor3 = Core.BOMB_COLORS[idx].color
    end

    GUI.setScale((settings.guiScale or 85) / 100)
    GUI.setButtonSize(settings.floatBtnSize or Core.BUTTON_DEFAULT_SIZE)

    if settings.floatBtnPos then
        GUI.setButtonPos(settings.floatBtnPos)
    end

    Logic.refreshESP()

    if Logic.getNoclipConnection() then
        Logic.getNoclipConnection():Disconnect()
        Logic.setNoclipConnection(nil)
    end
    if settings.noclip then
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
        Logic.removeNoclip()
    end

    if Logic.getSpeedConnection() then
        Logic.getSpeedConnection():Disconnect()
        Logic.setSpeedConnection(nil)
    end
    if settings.speed then
        local conn = RunService.Heartbeat:Connect(function()
            if settings.speed and LocalPlayer.Character then
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = settings.walkSpeed end
            end
        end)
        Logic.setSpeedConnection(conn)
    end

    Logic.updateFovCircle()
    Logic.updateSilentFovCircle()
    Logic.updateBombEsp()

    GUI.setOpenState(settings.menuOpen)
end

local function build()
    local tab = GUI.makeTab("Settings", 6, "settings")
    local page = GUI.makePage()

    GUI.makeSectionHeader(page, "Config", 1)

    local statusLbl = Instance.new("TextLabel")
    statusLbl.Size = UDim2.new(1, 0, 0, 18)
    statusLbl.BackgroundTransparency = 1
    statusLbl.Text = ""
    statusLbl.TextColor3 = T.textMuted
    statusLbl.TextSize = 10
    statusLbl.Font = Enum.Font.Gotham
    statusLbl.TextXAlignment = Enum.TextXAlignment.Left
    statusLbl.LayoutOrder = 2
    statusLbl.Parent = page

    local statusToken = 0
    local function showStatus(text, color)
        statusToken = statusToken + 1
        local myToken = statusToken
        statusLbl.Text = text
        statusLbl.TextColor3 = color or T.textMuted
        task.delay(3, function()
            if statusToken == myToken then
                statusLbl.Text = ""
            end
        end)
    end

    GUI.makeActionButton(page, "SAVE CONFIG", "primary", 3, function()
        local ok, err = Core.saveConfig()
        if ok then
            showStatus("Saved: " .. Core.CONFIG_FILE, T.success)
        else
            showStatus("Save error: " .. tostring(err), T.danger)
        end
    end)

    GUI.makeActionButton(page, "LOAD CONFIG", "blue", 4, function()
        local ok, err = Core.loadConfig()
        if ok then
            showStatus("Loaded: " .. Core.CONFIG_FILE, T.success)
            refreshAllUI()
        else
            showStatus("Load error: " .. tostring(err), T.danger)
        end
    end)

    GUI.makeSectionHeader(page, "Appearance", 5)

    GUI.makeSlider(page, "GUI Scale (%)", 70, 95, settings.guiScale or 85, 6, function(v)
        settings.guiScale = v
        GUI.setScale(v / 100)
    end, "guiScale")

    GUI.makeSlider(page, "Button Size", 40, 80, settings.floatBtnSize or Core.BUTTON_DEFAULT_SIZE, 7, function(v)
        settings.floatBtnSize = v
        GUI.setButtonSize(v)
    end, "floatBtnSize")

    tab.Button.MouseButton1Click:Connect(function()
        GUI.switchTab(tab, page)
    end)

    return tab, page
end

return build

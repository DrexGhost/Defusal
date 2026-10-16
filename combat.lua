local Core, GUI, Logic = ...

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local T = Core.T
local settings = Core.settings

local function build()
    local tab = GUI.makeTab("Combat", 4, "combat")
    local page = GUI.makePage()

    GUI.makeSectionHeader(page, "Aimbot", 1)

    GUI.makeToggle(page, "Aimbot", "Автонаведение", settings.aimbot, 2, function(v)
        settings.aimbot = v
        Logic.updateFovCircle()
    end, "aimbot")

    GUI.makeToggle(page, "Aimbot Team", "Стрелять в тиммейтов", settings.aimbotTeam, 3, function(v)
        settings.aimbotTeam = v
    end, "aimbotTeam")

    GUI.makeToggle(page, "Wallhack", "Игнорировать стены", settings.wallhack, 4, function(v)
        settings.wallhack = v
    end, "wallhack")

    GUI.makeToggle(page, "FOV Circle", "Круг FOV", settings.showFovCircle, 5, function(v)
        settings.showFovCircle = v
        Logic.updateFovCircle()
    end, "showFovCircle")

    GUI.makeSlider(page, "Aimbot Speed", 1, 20, settings.aimbotSpeed, 6, function(v)
        settings.aimbotSpeed = v
    end, "aimbotSpeed")

    GUI.makeSlider(page, "Aimbot FOV", 50, 500, settings.aimbotFov, 7, function(v)
        settings.aimbotFov = v
        Logic.updateFovCircle()
    end, "aimbotFov")

    local aimPartBtn = Instance.new("TextButton")
    aimPartBtn.Size = UDim2.new(1, 0, 0, 42)
    aimPartBtn.BackgroundColor3 = T.card
    aimPartBtn.BorderSizePixel = 0
    aimPartBtn.Text = "Aim Part: " .. settings.aimbotPart
    aimPartBtn.TextColor3 = T.text
    aimPartBtn.TextSize = 13
    aimPartBtn.Font = Enum.Font.GothamBold
    aimPartBtn.AutoButtonColor = false
    aimPartBtn.LayoutOrder = 8
    aimPartBtn.Parent = page

    local aimPartCorner = Instance.new("UICorner")
    aimPartCorner.CornerRadius = UDim.new(0, 10)
    aimPartCorner.Parent = aimPartBtn

    local aimPartStroke = Instance.new("UIStroke")
    aimPartStroke.Color = T.stroke
    aimPartStroke.Thickness = 1
    aimPartStroke.Parent = aimPartBtn

    Core.partBtnRefs["aimbot"] = aimPartBtn

    local aimParts = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}
    local aimPartIndex = 1
    for idx, p in ipairs(aimParts) do
        if p == settings.aimbotPart then aimPartIndex = idx break end
    end

    aimPartBtn.MouseButton1Click:Connect(function()
        aimPartIndex = aimPartIndex + 1
        if aimPartIndex > #aimParts then aimPartIndex = 1 end
        settings.aimbotPart = aimParts[aimPartIndex]
        aimPartBtn.Text = "Aim Part: " .. settings.aimbotPart
        Core.saveSetting("aimbotPart", settings.aimbotPart)
    end)

    aimPartBtn.MouseEnter:Connect(function()
        TweenService:Create(aimPartBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.cardHover}):Play()
        TweenService:Create(aimPartStroke, TweenInfo.new(0.15), {Color = T.accent, Transparency = 0.4}):Play()
    end)
    aimPartBtn.MouseLeave:Connect(function()
        TweenService:Create(aimPartBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.card}):Play()
        TweenService:Create(aimPartStroke, TweenInfo.new(0.15), {Color = T.stroke, Transparency = 0}):Play()
    end)

    GUI.makeSectionHeader(page, "Silent Aim (Risk ban)", 9)

    GUI.makeToggle(page, "Silent Aim", "Невидимое наведение", settings.silentAim, 10, function(v)
        settings.silentAim = v
        Logic.updateSilentFovCircle()
    end, "silentAim")

    GUI.makeToggle(page, "Silent Team", "Стрелять в тиммейтов", settings.silentTeam, 11, function(v)
        settings.silentTeam = v
    end, "silentTeam")

    GUI.makeToggle(page, "Wallbang", "Стрельба через стены", settings.silentWallbang, 12, function(v)
        settings.silentWallbang = v
    end, "silentWallbang")

    GUI.makeToggle(page, "FOV Circle", "Круг FOV", settings.silentShowFovCircle, 13, function(v)
        settings.silentShowFovCircle = v
        Logic.updateSilentFovCircle()
    end, "silentShowFovCircle")

    GUI.makeSlider(page, "Silent FOV", 50, 500, settings.silentFov, 14, function(v)
        settings.silentFov = v
        Logic.updateSilentFovCircle()
    end, "silentFov")

    local silentPartBtn = Instance.new("TextButton")
    silentPartBtn.Size = UDim2.new(1, 0, 0, 42)
    silentPartBtn.BackgroundColor3 = T.card
    silentPartBtn.BorderSizePixel = 0
    silentPartBtn.Text = "Silent Part: " .. settings.silentPart
    silentPartBtn.TextColor3 = T.text
    silentPartBtn.TextSize = 13
    silentPartBtn.Font = Enum.Font.GothamBold
    silentPartBtn.AutoButtonColor = false
    silentPartBtn.LayoutOrder = 15
    silentPartBtn.Parent = page

    local silentPartCorner = Instance.new("UICorner")
    silentPartCorner.CornerRadius = UDim.new(0, 10)
    silentPartCorner.Parent = silentPartBtn

    local silentPartStroke = Instance.new("UIStroke")
    silentPartStroke.Color = T.stroke
    silentPartStroke.Thickness = 1
    silentPartStroke.Parent = silentPartBtn

    Core.partBtnRefs["silent"] = silentPartBtn

    local silentParts = {"Head", "Torso"}
    local silentPartIndex = 1
    for idx, p in ipairs(silentParts) do
        if p == settings.silentPart then silentPartIndex = idx break end
    end

    silentPartBtn.MouseButton1Click:Connect(function()
        silentPartIndex = silentPartIndex + 1
        if silentPartIndex > #silentParts then silentPartIndex = 1 end
        settings.silentPart = silentParts[silentPartIndex]
        silentPartBtn.Text = "Silent Part: " .. settings.silentPart
        Core.saveSetting("silentPart", settings.silentPart)
    end)

    silentPartBtn.MouseEnter:Connect(function()
        TweenService:Create(silentPartBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.cardHover}):Play()
        TweenService:Create(silentPartStroke, TweenInfo.new(0.15), {Color = T.accent, Transparency = 0.4}):Play()
    end)
    silentPartBtn.MouseLeave:Connect(function()
        TweenService:Create(silentPartBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.card}):Play()
        TweenService:Create(silentPartStroke, TweenInfo.new(0.15), {Color = T.stroke, Transparency = 0}):Play()
    end)

    tab.Button.MouseButton1Click:Connect(function()
        GUI.switchTab(tab, page)
    end)

    return tab, page
end

return build

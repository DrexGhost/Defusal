local Core = ...
local GUI = ...

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local T = Core.T

local function build()
    local tab = GUI.makeTab("Main", 2, "dashboard")
    local page = GUI.makePage()

    local profileCard = Instance.new("Frame")
    profileCard.Size = UDim2.new(1, 0, 0, 92)
    profileCard.BackgroundColor3 = T.card
    profileCard.BorderSizePixel = 0
    profileCard.LayoutOrder = 1
    profileCard.Parent = page

    local pcCorner = Instance.new("UICorner")
    pcCorner.CornerRadius = UDim.new(0, 12)
    pcCorner.Parent = profileCard

    local pcStroke = Instance.new("UIStroke")
    pcStroke.Color = T.stroke
    pcStroke.Thickness = 1
    pcStroke.Transparency = 0.3
    pcStroke.Parent = profileCard

    local pcGradient = Instance.new("UIGradient")
    pcGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 34, 62)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(22, 22, 32)),
    })
    pcGradient.Rotation = 115
    pcGradient.Parent = profileCard

    local avatarRing = Instance.new("Frame")
    avatarRing.Size = UDim2.new(0, 64, 0, 64)
    avatarRing.Position = UDim2.new(0, 14, 0.5, -32)
    avatarRing.BackgroundColor3 = T.accent
    avatarRing.BorderSizePixel = 0
    avatarRing.ZIndex = 2
    avatarRing.Parent = profileCard

    local avatarRingCorner = Instance.new("UICorner")
    avatarRingCorner.CornerRadius = UDim.new(1, 0)
    avatarRingCorner.Parent = avatarRing

    local avatarRingGradient = Instance.new("UIGradient")
    avatarRingGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(160, 120, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(90, 65, 220)),
    })
    avatarRingGradient.Rotation = 135
    avatarRingGradient.Parent = avatarRing

    local avatarWrap = Instance.new("Frame")
    avatarWrap.Size = UDim2.new(0, 58, 0, 58)
    avatarWrap.Position = UDim2.new(0.5, -29, 0.5, -29)
    avatarWrap.BackgroundColor3 = T.bg1
    avatarWrap.BorderSizePixel = 0
    avatarWrap.ZIndex = 3
    avatarWrap.Parent = avatarRing

    local avatarWrapCorner = Instance.new("UICorner")
    avatarWrapCorner.CornerRadius = UDim.new(1, 0)
    avatarWrapCorner.Parent = avatarWrap

    local avatar = Instance.new("ImageLabel")
    avatar.Size = UDim2.new(1, 0, 1, 0)
    avatar.BackgroundTransparency = 1
    avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
    avatar.ZIndex = 4
    avatar.Parent = avatarWrap

    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(1, 0)
    avatarCorner.Parent = avatar

    local onlineDot = Instance.new("Frame")
    onlineDot.Size = UDim2.new(0, 12, 0, 12)
    onlineDot.Position = UDim2.new(1, -14, 1, -14)
    onlineDot.BackgroundColor3 = T.online
    onlineDot.BorderSizePixel = 0
    onlineDot.ZIndex = 5
    onlineDot.Parent = avatarRing

    local onlineDotCorner = Instance.new("UICorner")
    onlineDotCorner.CornerRadius = UDim.new(1, 0)
    onlineDotCorner.Parent = onlineDot

    local onlineDotStroke = Instance.new("UIStroke")
    onlineDotStroke.Color = T.card
    onlineDotStroke.Thickness = 2
    onlineDotStroke.Parent = onlineDot

    local nameText = Instance.new("TextLabel")
    nameText.Size = UDim2.new(1, -100, 0, 20)
    nameText.Position = UDim2.new(0, 92, 0, 22)
    nameText.BackgroundTransparency = 1
    nameText.Text = LocalPlayer.DisplayName
    nameText.TextColor3 = T.text
    nameText.TextSize = 15
    nameText.Font = Enum.Font.GothamBold
    nameText.TextXAlignment = Enum.TextXAlignment.Left
    nameText.ZIndex = 4
    nameText.Parent = profileCard

    local userText = Instance.new("TextLabel")
    userText.Size = UDim2.new(1, -100, 0, 14)
    userText.Position = UDim2.new(0, 92, 0, 42)
    userText.BackgroundTransparency = 1
    userText.Text = "@" .. LocalPlayer.Name
    userText.TextColor3 = T.textDim
    userText.TextSize = 11
    userText.Font = Enum.Font.Gotham
    userText.TextXAlignment = Enum.TextXAlignment.Left
    userText.ZIndex = 4
    userText.Parent = profileCard

    local idText = Instance.new("TextLabel")
    idText.Size = UDim2.new(1, -100, 0, 12)
    idText.Position = UDim2.new(0, 92, 0, 58)
    idText.BackgroundTransparency = 1
    idText.Text = "ID: " .. tostring(LocalPlayer.UserId)
    idText.TextColor3 = T.textMuted
    idText.TextSize = 10
    idText.Font = Enum.Font.Gotham
    idText.TextXAlignment = Enum.TextXAlignment.Left
    idText.ZIndex = 4
    idText.Parent = profileCard

    GUI.makeSectionHeader(page, "Server", 2)

    local statsRow = Instance.new("Frame")
    statsRow.Size = UDim2.new(1, 0, 0, 56)
    statsRow.BackgroundTransparency = 1
    statsRow.LayoutOrder = 3
    statsRow.Parent = page

    local statsLayout = Instance.new("UIListLayout")
    statsLayout.FillDirection = Enum.FillDirection.Horizontal
    statsLayout.Padding = UDim.new(0, 8)
    statsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    statsLayout.Parent = statsRow

    local function MakeStat(order, title)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(0.5, -4, 1, 0)
        card.BackgroundColor3 = T.row
        card.BorderSizePixel = 0
        card.LayoutOrder = order
        card.Parent = statsRow

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 10)
        c.Parent = card

        local s = Instance.new("UIStroke")
        s.Color = T.stroke
        s.Thickness = 1
        s.Transparency = 0.4
        s.Parent = card

        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, -20, 0, 12)
        t.Position = UDim2.new(0, 12, 0, 10)
        t.BackgroundTransparency = 1
        t.Text = title:upper()
        t.TextColor3 = T.textMuted
        t.TextSize = 9
        t.Font = Enum.Font.GothamBold
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Parent = card

        local v = Instance.new("TextLabel")
        v.Size = UDim2.new(1, -20, 0, 20)
        v.Position = UDim2.new(0, 12, 0, 26)
        v.BackgroundTransparency = 1
        v.Text = "0"
        v.TextColor3 = T.text
        v.TextSize = 16
        v.Font = Enum.Font.GothamBold
        v.TextXAlignment = Enum.TextXAlignment.Left
        v.Parent = card

        return v
    end

    local playersValue = MakeStat(1, "Players")
    local pingValue = MakeStat(2, "Ping")

    playersValue.Text = tostring(#Players:GetPlayers())
    pcall(function()
        pingValue.Text = tostring(math.floor(LocalPlayer:GetNetworkPing() * 1000)) .. " ms"
    end)

    task.spawn(function()
        while GUI.screenGui.Parent do
            task.wait(1)
            playersValue.Text = tostring(#Players:GetPlayers())
            pcall(function()
                pingValue.Text = tostring(math.floor(LocalPlayer:GetNetworkPing() * 1000)) .. " ms"
            end)
        end
    end)

    tab.Button.MouseButton1Click:Connect(function()
        GUI.switchTab(tab, page)
    end)

    return tab, page
end

return build

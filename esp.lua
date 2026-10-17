local Core, GUI, Logic = ...

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local T = Core.T
local settings = Core.settings

local function build()
    local tab = GUI.makeTab("ESP", 3, "crosshair")
    local page = GUI.makePage()

    GUI.makeSectionHeader(page, "Player ESP", 1)

    GUI.makeToggle(page, "ESP Player", "Главный переключатель", settings.esp, 2, function(v)
        settings.esp = v
        Logic.refreshESP()
    end, "esp")

    GUI.makeToggle(page, "ESP Hitbox", "Подсветка игроков", settings.espHitbox, 3, function(v)
        settings.espHitbox = v
    end, "espHitbox")

    GUI.makeToggle(page, "ESP Team", "Показывать тиммейтов", settings.espTeam, 4, function(v)
        settings.espTeam = v
    end, "espTeam")

    GUI.makeToggle(page, "Nickname", "Ники игроков", settings.espNick, 5, function(v)
        settings.espNick = v
    end, "espNick")

    GUI.makeToggle(page, "Distance", "Дистанция", settings.espDist, 6, function(v)
        settings.espDist = v
    end, "espDist")

    GUI.makeToggle(page, "HP Bar", "Полоса здоровья", settings.espHP, 7, function(v)
        settings.espHP = v
    end, "espHP")

    GUI.makeToggle(page, "Weapon", "Оружие", settings.espWeapon, 8, function(v)
        settings.espWeapon = v
    end, "espWeapon")

    GUI.makeToggle(page, "Tracer", "Линии до игроков", settings.espTracer, 9, function(v)
        settings.espTracer = v
    end, "espTracer")

    GUI.makeToggle(page, "Arrows", "Стрелки за экраном", settings.espArrows, 10, function(v)
        settings.espArrows = v
    end, "espArrows")

    GUI.makeSectionHeader(page, "Bomb ESP", 11)

    GUI.makeToggle(page, "ESP Bomb", "Подсветка бомбы", settings.espBomb, 12, function(v)
        settings.espBomb = v
        if not v then
            settings.hitboxBomb = false
            settings.labelBomb = false
            Core.saveSetting("hitboxBomb", false)
            Core.saveSetting("labelBomb", false)
            if Core.toggleRefs["hitboxBomb"] then
                Core.toggleRefs["hitboxBomb"].setEnabled(false, true)
            end
            if Core.toggleRefs["labelBomb"] then
                Core.toggleRefs["labelBomb"].setEnabled(false, true)
            end
        end
        Logic.updateBombEsp()
    end, "espBomb")

    GUI.makeToggle(page, "Hitbox Bomb", "Хитбокс бомбы", settings.hitboxBomb, 13, function(v)
        settings.hitboxBomb = v
        Logic.updateBombEsp()
    end, "hitboxBomb")

    GUI.makeToggle(page, "Label Bomb", "Текст у бомбы", settings.labelBomb, 14, function(v)
        settings.labelBomb = v
        Logic.updateBombEsp()
    end, "labelBomb")

    local colorBtn = Instance.new("TextButton")
    colorBtn.Size = UDim2.new(1, 0, 0, 42)
    colorBtn.BackgroundColor3 = T.card
    colorBtn.BorderSizePixel = 0
    colorBtn.Text = "Bomb Color: " .. Core.BOMB_COLORS[settings.bombColorIndex or 1].name
    colorBtn.TextColor3 = Core.BOMB_COLORS[settings.bombColorIndex or 1].color
    colorBtn.TextSize = 13
    colorBtn.Font = Enum.Font.GothamBold
    colorBtn.AutoButtonColor = false
    colorBtn.LayoutOrder = 15
    colorBtn.Parent = page

    local colorBtnCorner = Instance.new("UICorner")
    colorBtnCorner.CornerRadius = UDim.new(0, 10)
    colorBtnCorner.Parent = colorBtn

    local colorBtnStroke = Instance.new("UIStroke")
    colorBtnStroke.Color = T.stroke
    colorBtnStroke.Thickness = 1
    colorBtnStroke.Parent = colorBtn

    Core.bombColorBtnRef = colorBtn

    colorBtn.MouseButton1Click:Connect(function()
        local idx = (settings.bombColorIndex or 1) + 1
        if idx > #Core.BOMB_COLORS then idx = 1 end
        settings.bombColorIndex = idx
        Core.saveSetting("bombColorIndex", idx)
        colorBtn.Text = "Bomb Color: " .. Core.BOMB_COLORS[idx].name
        colorBtn.TextColor3 = Core.BOMB_COLORS[idx].color
        Logic.updateBombEsp()
    end)

    colorBtn.MouseEnter:Connect(function()
        TweenService:Create(colorBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.cardHover}):Play()
        TweenService:Create(colorBtnStroke, TweenInfo.new(0.15), {Color = T.accent, Transparency = 0.4}):Play()
    end)
    colorBtn.MouseLeave:Connect(function()
        TweenService:Create(colorBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.card}):Play()
        TweenService:Create(colorBtnStroke, TweenInfo.new(0.15), {Color = T.stroke, Transparency = 0}):Play()
    end)

    tab.Button.MouseButton1Click:Connect(function()
        GUI.switchTab(tab, page)
    end)

    return tab, page
end

return build

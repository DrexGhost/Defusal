local Core, GUI = ...

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local settings = Core.settings
local T = Core.T

local Logic = {}

local HAS_DRAWING = false
if Drawing and Drawing.new then
    HAS_DRAWING = true
end

local function isPlayerAlive(target)
    if not target then return false end
    local char = target.Character
    if not char then return false end
    local alive = target:GetAttribute("Alive")
    if alive == false then return false end
    local healthAttr = target:GetAttribute("Health")
    if healthAttr ~= nil and healthAttr <= 0 then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        if hum.Health <= 0 then return false end
        if hum:GetState() == Enum.HumanoidStateType.Dead then return false end
    end
    local head = char:FindFirstChild("Head")
    local root = char:FindFirstChild("HumanoidRootPart")
    if head and root and head:IsA("BasePart") and root:IsA("BasePart") then
        if head.Position.Y < root.Position.Y - 2 then return false end
    end
    return true
end

local function isTeammate(target)
    if target == LocalPlayer then return false end
    local myTeam = LocalPlayer:GetAttribute("Team")
    local targetTeam = target:GetAttribute("Team")
    if myTeam and targetTeam then return myTeam == targetTeam end
    return false
end

local function getWeaponName(target)
    local skin = target:GetAttribute("CurrentSkin")
    if skin then
        local weapon = string.match(skin, "^([^_]+)")
        if weapon then return weapon end
        return skin
    end
    return "None"
end

local function getWeaponSkin(target)
    local skin = target:GetAttribute("CurrentSkin")
    if skin then
        local _, skinName = string.match(skin, "^([^_]+)_(.+)$")
        if skinName then return skinName end
    end
    return ""
end

local function isVisible(targetPart)
    if not targetPart then return false end
    if not LocalPlayer.Character then return false end
    local origin = camera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit
    local distance = (targetPart.Position - origin).Magnitude
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    local ray = workspace:Raycast(origin, direction * distance, rayParams)
    if ray then
        local hit = ray.Instance
        if hit and hit:IsDescendantOf(targetPart.Parent) then return true end
        return false
    end
    return true
end

local function getTargetPartFor(character, partName)
    if not character then return nil end
    if partName == "Head" then
        return character:FindFirstChild("Head")
    elseif partName == "Torso" then
        return character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    else
        local partMap = {
            ["Left Arm"] = "LeftUpperArm",
            ["Right Arm"] = "RightUpperArm",
            ["Left Leg"] = "LeftUpperLeg",
            ["Right Leg"] = "RightUpperLeg"
        }
        local pn = partMap[partName]
        if pn then return character:FindFirstChild(pn) end
    end
    return character:FindFirstChild("Head")
end

local espList = {}
local espConnectionTrack = {}
local attributeConns = {}

local function destroyESPFor(target)
    local data = espList[target]
    if not data then return end
    if data.highlight then data.highlight:Destroy() end
    if data.billboard then data.billboard:Destroy() end
    if data.hpBgDraw then pcall(function() data.hpBgDraw:Remove() end) end
    if data.hpFillDraw then pcall(function() data.hpFillDraw:Remove() end) end
    if data.tracerDraw then pcall(function() data.tracerDraw:Remove() end) end
    espList[target] = nil
end

local function createESP(target)
    if espList[target] then return end
    if target == LocalPlayer then return end
    if not target.Character then return end

    local character = target.Character
    local isTeam = isTeammate(target)
    local color = isTeam and Core.teamColor or Core.enemyColor

    local highlight = Instance.new("Highlight")
    highlight.Adornee = character
    highlight.FillColor = color
    highlight.FillTransparency = 0.4
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0.2
    highlight.Parent = character
    highlight.Enabled = false

    local billboard, nameLabel, weaponLabel, distLabel

    local head = character:FindFirstChild("Head")
    if head then
        billboard = Instance.new("BillboardGui")
        billboard.Adornee = head
        billboard.Size = UDim2.new(0, 220, 0, 60)
        billboard.StudsOffset = Vector3.new(0, 3.5, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = head
        billboard.Enabled = false

        nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0, 16)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = target.Name
        nameLabel.TextColor3 = color
        nameLabel.TextSize = 12
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextStrokeTransparency = 0.3
        nameLabel.Parent = billboard

        weaponLabel = Instance.new("TextLabel")
        weaponLabel.Size = UDim2.new(1, 0, 0, 14)
        weaponLabel.Position = UDim2.new(0, 0, 0, 20)
        weaponLabel.BackgroundTransparency = 1
        weaponLabel.Text = "None"
        weaponLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
        weaponLabel.TextSize = 11
        weaponLabel.Font = Enum.Font.Gotham
        weaponLabel.TextStrokeTransparency = 0.3
        weaponLabel.Parent = billboard

        distLabel = Instance.new("TextLabel")
        distLabel.Size = UDim2.new(1, 0, 0, 14)
        distLabel.Position = UDim2.new(0, 0, 0, 40)
        distLabel.BackgroundTransparency = 1
        distLabel.Text = "0m"
        distLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
        distLabel.TextSize = 11
        distLabel.Font = Enum.Font.Gotham
        distLabel.TextStrokeTransparency = 0.3
        distLabel.Parent = billboard
    end

    local hpBgDraw, hpFillDraw, tracerDraw
    if HAS_DRAWING then
        hpBgDraw = Drawing.new("Quad")
        hpBgDraw.Filled = true
        hpBgDraw.Color = Color3.fromRGB(30, 30, 40)
        hpBgDraw.Transparency = 0.5
        hpBgDraw.Visible = false

        hpFillDraw = Drawing.new("Quad")
        hpFillDraw.Filled = true
        hpFillDraw.Color = Color3.fromRGB(0, 255, 0)
        hpFillDraw.Transparency = 1
        hpFillDraw.Visible = false

        tracerDraw = Drawing.new("Line")
        tracerDraw.Thickness = 1.5
        tracerDraw.Transparency = 0.85
        tracerDraw.Visible = false
    end

    espList[target] = {
        highlight = highlight, billboard = billboard, nameLabel = nameLabel,
        weaponLabel = weaponLabel, distLabel = distLabel,
        hpBgDraw = hpBgDraw, hpFillDraw = hpFillDraw, tracerDraw = tracerDraw,
        isTeam = isTeam, color = color, character = character
    }
end

local function setupPlayerESP(target)
    if target == LocalPlayer then return end
    if espConnectionTrack[target] then return end
    local conn = target.CharacterAdded:Connect(function(newChar)
        newChar:WaitForChild("Head", 3)
        task.wait(0.1)
        destroyESPFor(target)
        if settings.esp then createESP(target) end
    end)
    espConnectionTrack[target] = conn
end

local function setupPlayerAttributes(target)
    if target == LocalPlayer then return end
    if attributeConns[target] then return end
    local conns = {}
    table.insert(conns, target:GetAttributeChangedSignal("Alive"):Connect(function()
        local data = espList[target]
        if data then
            local alive = isPlayerAlive(target)
            local show = settings.esp and alive and (not isTeammate(target) or settings.espTeam)
            if data.highlight then data.highlight.Enabled = show and settings.espHitbox end
            if data.billboard then data.billboard.Enabled = show end
        end
    end))
    table.insert(conns, target:GetAttributeChangedSignal("Health"):Connect(function()
        local data = espList[target]
        if data then
            local alive = isPlayerAlive(target)
            local show = settings.esp and alive and (not isTeammate(target) or settings.espTeam)
            if data.highlight then data.highlight.Enabled = show and settings.espHitbox end
            if data.billboard then data.billboard.Enabled = show end
        end
    end))
    attributeConns[target] = conns
end

local function updateESP()
    for target, data in pairs(espList) do
        if not target or not target.Character then
            destroyESPFor(target)
        elseif data.character ~= target.Character then
            destroyESPFor(target)
            createESP(target)
        else
            local isTeam = isTeammate(target)
            local alive = isPlayerAlive(target)
            data.isTeam = isTeam
            local shouldShow = alive and settings.esp and (not isTeam or settings.espTeam)
            local color = isTeam and Core.teamColor or Core.enemyColor

            if data.highlight then
                data.highlight.Enabled = shouldShow and settings.espHitbox
                data.highlight.FillColor = color
            end

            if data.billboard then
                data.billboard.Enabled = shouldShow
                if shouldShow then
                    data.nameLabel.Text = target.Name
                    data.nameLabel.TextColor3 = color
                    data.nameLabel.Visible = settings.espNick
                    if data.weaponLabel then
                        local weapon = getWeaponName(target)
                        local skin = getWeaponSkin(target)
                        data.weaponLabel.Text = skin ~= "" and (weapon .. " (" .. skin .. ")") or weapon
                        data.weaponLabel.Visible = settings.espWeapon
                    end
                    if data.distLabel then
                        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        local tRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
                        if myRoot and tRoot then
                            local d = math.floor((myRoot.Position - tRoot.Position).Magnitude + 0.5)
                            data.distLabel.Text = d .. "m"
                        end
                        data.distLabel.Visible = settings.espDist
                    end
                end
            end

            if data.hpBgDraw and data.hpFillDraw then
                if shouldShow and settings.espHP then
                    local head = target.Character:FindFirstChild("Head")
                    local hrp = target.Character:FindFirstChild("HumanoidRootPart")
                    if head and hrp then
                        local topPos, topOn = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1.2, 0))
                        local botPos, botOn = camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                        if topOn and botOn then
                            local topY = math.min(topPos.Y, botPos.Y)
                            local botY = math.max(topPos.Y, botPos.Y)
                            local barW = 3
                            local barX = math.min(topPos.X, botPos.X) - 12
                            local health = target:GetAttribute("Health") or 100
                            local maxHealth = target:GetAttribute("MaxHealth") or 100
                            local hpPct = math.clamp(health / maxHealth, 0, 1)
                            local fillTop = botY - (botY - topY) * hpPct

                            data.hpBgDraw.PointA = Vector2.new(barX, topY)
                            data.hpBgDraw.PointB = Vector2.new(barX + barW, topY)
                            data.hpBgDraw.PointC = Vector2.new(barX + barW, botY)
                            data.hpBgDraw.PointD = Vector2.new(barX, botY)
                            data.hpBgDraw.Visible = true

                            data.hpFillDraw.PointA = Vector2.new(barX, fillTop)
                            data.hpFillDraw.PointB = Vector2.new(barX + barW, fillTop)
                            data.hpFillDraw.PointC = Vector2.new(barX + barW, botY)
                            data.hpFillDraw.PointD = Vector2.new(barX, botY)
                            if hpPct > 0.6 then
                                data.hpFillDraw.Color = Color3.fromRGB(0, 255, 0)
                            elseif hpPct > 0.3 then
                                data.hpFillDraw.Color = Color3.fromRGB(255, 200, 0)
                            else
                                data.hpFillDraw.Color = Color3.fromRGB(255, 0, 0)
                            end
                            data.hpFillDraw.Visible = true
                        else
                            data.hpBgDraw.Visible = false
                            data.hpFillDraw.Visible = false
                        end
                    else
                        data.hpBgDraw.Visible = false
                        data.hpFillDraw.Visible = false
                    end
                else
                    data.hpBgDraw.Visible = false
                    data.hpFillDraw.Visible = false
                end
            end

            if data.tracerDraw then
                if shouldShow and settings.espTracer then
                    local hrp = target.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local tPos, tOn = camera:WorldToViewportPoint(hrp.Position)
                        if tOn then
                            local vp = camera.ViewportSize
                            data.tracerDraw.From = Vector2.new(vp.X / 2, vp.Y)
                            data.tracerDraw.To = Vector2.new(tPos.X, tPos.Y)
                            data.tracerDraw.Color = color
                            data.tracerDraw.Visible = true
                        else
                            data.tracerDraw.Visible = false
                        end
                    else
                        data.tracerDraw.Visible = false
                    end
                else
                    data.tracerDraw.Visible = false
                end
            end
        end
    end
end

local function refreshESP()
    local toDestroy = {}
    for target, _ in pairs(espList) do table.insert(toDestroy, target) end
    for _, target in ipairs(toDestroy) do destroyESPFor(target) end
    espList = {}
    if not settings.esp then return end
    for _, target in pairs(Players:GetPlayers()) do
        if target ~= LocalPlayer then createESP(target) end
    end
end

local function findAimbotTarget()
    if not settings.aimbot then return nil end
    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local best, bestDist = nil, settings.aimbotFov
    for _, target in pairs(Players:GetPlayers()) do
        if target ~= LocalPlayer and target.Character then
            if isPlayerAlive(target) then
                local skip = false
                if not settings.aimbotTeam and isTeammate(target) then skip = true end
                if not skip then
                    local part = getTargetPartFor(target.Character, settings.aimbotPart)
                    if part then
                        if not settings.wallhack and not isVisible(part) then skip = true end
                        if not skip then
                            local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
                            if onScreen then
                                local targetPos = Vector2.new(screenPos.X, screenPos.Y)
                                local dist = (targetPos - center).Magnitude
                                if dist < bestDist then
                                    bestDist = dist
                                    best = part
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return best
end

local fovCircle = Instance.new("ScreenGui")
fovCircle.Name = "Defusal_FovCircle"
fovCircle.ResetOnSpawn = false
fovCircle.Enabled = false
fovCircle.DisplayOrder = 998
fovCircle.IgnoreGuiInset = true
fovCircle.Parent = GUI.screenGui

local circleFrame = Instance.new("Frame", fovCircle)
circleFrame.Size = UDim2.new(0, settings.aimbotFov, 0, settings.aimbotFov)
circleFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
circleFrame.AnchorPoint = Vector2.new(0.5, 0.5)
circleFrame.BackgroundTransparency = 1
Instance.new("UICorner", circleFrame).CornerRadius = UDim.new(1, 0)

local circleStroke = Instance.new("UIStroke", circleFrame)
circleStroke.Color = Color3.fromRGB(255, 0, 0)
circleStroke.Thickness = 1.5

local function updateFovCircle()
    if settings.showFovCircle and settings.aimbot then
        fovCircle.Enabled = true
        circleFrame.Size = UDim2.new(0, settings.aimbotFov, 0, settings.aimbotFov)
        circleFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    else
        fovCircle.Enabled = false
    end
end

local silentFovCircle = Instance.new("ScreenGui")
silentFovCircle.Name = "Defusal_SilentFov"
silentFovCircle.ResetOnSpawn = false
silentFovCircle.Enabled = false
silentFovCircle.DisplayOrder = 997
silentFovCircle.IgnoreGuiInset = true
silentFovCircle.Parent = GUI.screenGui

local silentCircleFrame = Instance.new("Frame", silentFovCircle)
silentCircleFrame.Size = UDim2.new(0, settings.silentFov, 0, settings.silentFov)
silentCircleFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
silentCircleFrame.AnchorPoint = Vector2.new(0.5, 0.5)
silentCircleFrame.BackgroundTransparency = 1
Instance.new("UICorner", silentCircleFrame).CornerRadius = UDim.new(1, 0)

local silentCircleStroke = Instance.new("UIStroke", silentCircleFrame)
silentCircleStroke.Color = Color3.fromRGB(255, 220, 0)
silentCircleStroke.Thickness = 1.5

local function updateSilentFovCircle()
    if settings.silentAim and settings.silentShowFovCircle then
        silentFovCircle.Enabled = true
        silentCircleFrame.Size = UDim2.new(0, settings.silentFov, 0, settings.silentFov)
        silentCircleFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    else
        silentFovCircle.Enabled = false
    end
end

local silentTarget = nil
local silentHits = 0
local inSilentHook = false

local function findSilentTarget()
    if not settings.silentAim then return nil end
    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local best, bd = nil, settings.silentFov
    for _, t in pairs(Players:GetPlayers()) do
        if t ~= LocalPlayer and t.Character then
            if isPlayerAlive(t) then
                local skip = false
                if not settings.silentTeam and isTeammate(t) then skip = true end
                if not skip then
                    local part = getTargetPartFor(t.Character, settings.silentPart)
                    if part and part:IsA("BasePart") then
                        local sp, os = camera:WorldToViewportPoint(part.Position)
                        if os then
                            local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                            if d < bd then
                                bd = d
                                best = {player = t, part = part, character = t.Character}
                            end
                        end
                    end
                end
            end
        end
    end
    return best
end

RunService.RenderStepped:Connect(function()
    if settings.silentAim then
        silentTarget = findSilentTarget()
    else
        silentTarget = nil
    end
end)

local function isWeaponRaycast(origin, direction, params)
    if typeof(params) ~= "RaycastParams" then return false end
    if params.FilterType ~= Enum.RaycastFilterType.Exclude then return false end
    if typeof(direction) ~= "Vector3" then return false end
    local filter = params.FilterDescendantsInstances
    if not filter or #filter == 0 then return false end
    local hasMe, hasRoot, hasHitboxes, hasDebris = false, false, false, false
    for _, inst in ipairs(filter) do
        if typeof(inst) == "Instance" then
            if inst == LocalPlayer.Character then hasMe = true end
            if inst.Name == "HumanoidRootPart" and inst:IsA("BasePart") then hasRoot = true end
            if inst.Name == "Hitboxes" and inst:IsA("Model") then hasHitboxes = true end
            if inst.Name == "Debris" and inst:IsA("Folder") then hasDebris = true end
        end
    end
    return hasMe and hasRoot and hasHitboxes and hasDebris
end

local function isTargetVisibleFrom(origin, targetCharacter, targetPart)
    if not targetCharacter or not targetPart then return false end
    local dir = targetPart.Position - origin
    local dist = dir.Magnitude
    if dist < 0.1 then return true end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LocalPlayer.Character }
    params.IgnoreWater = true
    local result = workspace:Raycast(origin, dir, params)
    if not result then return true end
    if result.Instance:IsDescendantOf(targetCharacter) then return true end
    return false
end

local function rawRaycast(origin, dir, params)
    inSilentHook = true
    local ok, result = pcall(function() return workspace:Raycast(origin, dir, params) end)
    inSilentHook = false
    if ok then return result end
    return nil
end

if type(hookmetamethod) == "function" then
    local old
    old = hookmetamethod(game, "__namecall", function(self, ...)
        local m = getnamecallmethod()
        if not inSilentHook and settings.silentAim and silentTarget and m == "Raycast" and self == workspace then
            local args = {...}
            local origin = args[1]
            local direction = args[2]
            local params = args[3]
            if isWeaponRaycast(origin, direction, params) then
                local targetPart = silentTarget.character:FindFirstChild(settings.silentPart)
                if not targetPart then targetPart = silentTarget.character:FindFirstChild("Head") end
                if targetPart and targetPart:IsA("BasePart") then
                    local canHit = true
                    if not settings.silentWallbang then
                        canHit = isTargetVisibleFrom(origin, silentTarget.character, targetPart)
                    end
                    if canHit then
                        local newParams = RaycastParams.new()
                        newParams.FilterType = Enum.RaycastFilterType.Include
                        newParams.FilterDescendantsInstances = {silentTarget.character}
                        newParams.IgnoreWater = false
                        local toPart = targetPart.Position - origin
                        local newDir = toPart.Unit * direction.Magnitude
                        local fakeHit = rawRaycast(origin, newDir, newParams)
                        if fakeHit then
                            silentHits = silentHits + 1
                            return fakeHit
                        end
                    end
                end
            end
        end
        return old(self, ...)
    end)
end

local noclipConnection = nil
local speedConnection = nil
local savedCollide = {}

local function applyNoclip()
    if not LocalPlayer.Character then return end
    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            if savedCollide[part] == nil then savedCollide[part] = part.CanCollide end
            part.CanCollide = false
        end
    end
end

local function removeNoclip()
    if not LocalPlayer.Character then return end
    for part, state in pairs(savedCollide) do
        if part and part.Parent then part.CanCollide = state end
    end
    savedCollide = {}
end

local bombEsp = {
    highlight = nil, billboard = nil, label = nil, target = nil,
    plantStartTime = 0, lastCheck = 0
}

local function getBombColor()
    local idx = settings.bombColorIndex or 1
    if idx < 1 or idx > #Core.BOMB_COLORS then idx = 1 end
    return Core.BOMB_COLORS[idx].color
end

local function findBombCarrier()
    for _, target in pairs(Players:GetPlayers()) do
        if target.Character and isPlayerAlive(target) then
            local backC4 = target.Character:FindFirstChild("BackC4")
            if backC4 and backC4:IsA("BasePart") and backC4.Transparency < 1 then
                return target, backC4
            end
        end
    end
    return nil, nil
end

local function findDroppedBomb()
    local debris = game.Workspace:FindFirstChild("Debris")
    if not debris then return nil end
    local c4 = debris:FindFirstChild("C4")
    if c4 and c4:IsA("BasePart") then return c4 end
    return nil
end

local function findPlantedBomb()
    local debris = game.Workspace:FindFirstChild("Debris")
    if not debris then return nil end
    local planted = debris:FindFirstChild("PlantedC4")
    if planted then return planted end
    return nil
end

local function cleanupBombEsp()
    if bombEsp.highlight then bombEsp.highlight:Destroy() end
    if bombEsp.billboard then bombEsp.billboard:Destroy() end
    bombEsp.highlight = nil
    bombEsp.billboard = nil
    bombEsp.label = nil
    bombEsp.target = nil
    bombEsp.plantStartTime = 0
end

local function findVisiblePart(obj)
    if obj:IsA("BasePart") then return obj end
    if not obj:IsA("Model") then return nil end
    if obj.PrimaryPart then return obj.PrimaryPart end
    for _, d in pairs(obj:GetDescendants()) do
        if d:IsA("BasePart") and d.Transparency < 1 then return d end
    end
    for _, d in pairs(obj:GetDescendants()) do
        if d:IsA("BasePart") then return d end
    end
    return nil
end

local function updateBombEsp()
    if not settings.espBomb then
        if bombEsp.highlight or bombEsp.billboard then cleanupBombEsp() end
        return
    end
    if not settings.hitboxBomb and not settings.labelBomb then
        if bombEsp.highlight or bombEsp.billboard then cleanupBombEsp() end
        return
    end
    local carrier, backC4 = findBombCarrier()
    local planted = findPlantedBomb()
    local dropped = findDroppedBomb()
    local activeTarget, activePart
    local isPlanted, isCarrier, isDropped = false, false, false

    if planted then
        isPlanted = true
        activeTarget = planted
        activePart = findVisiblePart(planted)
    elseif carrier and backC4 then
        isCarrier = true
        activeTarget = carrier
        activePart = backC4
    elseif dropped then
        isDropped = true
        activeTarget = dropped
        activePart = dropped
    end

    if not activeTarget or not activePart then
        cleanupBombEsp()
        return
    end

    if isPlanted and bombEsp.plantStartTime == 0 then bombEsp.plantStartTime = tick() end
    if not isPlanted then bombEsp.plantStartTime = 0 end

    local highlightAdornee = (isPlanted and planted:IsA("Model")) and planted or activePart
    local billboardAdornee = activePart
    local bombColor = getBombColor()

    if bombEsp.target ~= activeTarget then
        cleanupBombEsp()
        bombEsp.target = activeTarget
        if isPlanted then bombEsp.plantStartTime = tick() end
    end

    if settings.hitboxBomb then
        if bombEsp.highlight and bombEsp.highlight.Parent ~= GUI.screenGui then
            bombEsp.highlight:Destroy()
            bombEsp.highlight = nil
        end
        if not bombEsp.highlight then
            local hl = Instance.new("Highlight")
            hl.Adornee = highlightAdornee
            hl.FillColor = bombColor
            hl.FillTransparency = 0.5
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.OutlineTransparency = 0.2
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent = GUI.screenGui
            bombEsp.highlight = hl
        else
            bombEsp.highlight.Adornee = highlightAdornee
            bombEsp.highlight.FillColor = bombColor
        end
    else
        if bombEsp.highlight then bombEsp.highlight:Destroy(); bombEsp.highlight = nil end
    end

    if settings.labelBomb then
        if not bombEsp.billboard then
            local bb = Instance.new("BillboardGui")
            bb.Adornee = billboardAdornee
            bb.Size = UDim2.new(0, 220, 0, 30)
            bb.StudsOffset = Vector3.new(0, 2, 0)
            bb.AlwaysOnTop = true
            bb.Parent = billboardAdornee
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, 0, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = "Bomb"
            lbl.TextColor3 = bombColor
            lbl.TextSize = 16
            lbl.Font = Enum.Font.GothamBold
            lbl.TextStrokeTransparency = 0.3
            lbl.Parent = bb
            bombEsp.billboard = bb
            bombEsp.label = lbl
        else
            bombEsp.billboard.Adornee = billboardAdornee
        end
        if bombEsp.label then
            bombEsp.label.TextColor3 = bombColor
            if isPlanted then
                local elapsed = tick() - bombEsp.plantStartTime
                local timeLeft = math.max(0, Core.BOMB_TIME - elapsed)
                bombEsp.label.Text = "Bomb Time: " .. math.ceil(timeLeft) .. "s"
            elseif isCarrier then
                bombEsp.label.Text = "Bomb: " .. carrier.Name
            elseif isDropped then
                bombEsp.label.Text = "Bomb (dropped)"
            end
        end
    else
        if bombEsp.billboard then bombEsp.billboard:Destroy(); bombEsp.billboard = nil; bombEsp.label = nil end
    end
end

Logic.isPlayerAlive = isPlayerAlive
Logic.isTeammate = isTeammate
Logic.getWeaponName = getWeaponName
Logic.getWeaponSkin = getWeaponSkin
Logic.isVisible = isVisible
Logic.getTargetPartFor = getTargetPartFor
Logic.refreshESP = refreshESP
Logic.updateESP = updateESP
Logic.updateBombEsp = updateBombEsp
Logic.updateFovCircle = updateFovCircle
Logic.updateSilentFovCircle = updateSilentFovCircle
Logic.findAimbotTarget = findAimbotTarget
Logic.applyNoclip = applyNoclip
Logic.removeNoclip = removeNoclip
Logic.createESP = createESP
Logic.destroyESPFor = destroyESPFor
Logic.setupPlayerESP = setupPlayerESP
Logic.setupPlayerAttributes = setupPlayerAttributes

Logic.getNoclipConnection = function() return noclipConnection end
Logic.setNoclipConnection = function(v) noclipConnection = v end
Logic.getSpeedConnection = function() return speedConnection end
Logic.setSpeedConnection = function(v) speedConnection = v end
Logic.getSavedCollide = function() return savedCollide end
Logic.resetSavedCollide = function() savedCollide = {} end

function Logic.setupEvents()
    for _, target in pairs(Players:GetPlayers()) do
        if target ~= LocalPlayer then
            if settings.esp then createESP(target) end
            setupPlayerESP(target)
            setupPlayerAttributes(target)
        end
    end

    Players.PlayerAdded:Connect(function(target)
        task.wait(0.5)
        if target ~= LocalPlayer then
            if settings.esp then createESP(target) end
            setupPlayerESP(target)
            setupPlayerAttributes(target)
        end
    end)

    Players.PlayerRemoving:Connect(function(target)
        destroyESPFor(target)
        if espConnectionTrack[target] then
            espConnectionTrack[target]:Disconnect()
            espConnectionTrack[target] = nil
        end
        if attributeConns[target] then
            for _, c in ipairs(attributeConns[target]) do c:Disconnect() end
            attributeConns[target] = nil
        end
    end)

    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)
        savedCollide = {}
        refreshESP()
        if settings.noclip then applyNoclip() end
    end)
end

function Logic.startLoop()
    local lastBombUpdate = 0
    RunService.RenderStepped:Connect(function(dt)
        if settings.esp then
            pcall(updateESP)
        end

        lastBombUpdate = lastBombUpdate + dt
        if lastBombUpdate >= 0.15 then
            lastBombUpdate = 0
            pcall(updateBombEsp)
        end

        if settings.aimbot then
            local target = findAimbotTarget()
            if target then
                local currentCFrame = camera.CFrame
                local targetCFrame = CFrame.new(currentCFrame.Position, target.Position)
                local smoothness = math.clamp((21 - settings.aimbotSpeed) / 20, 0.05, 1)
                camera.CFrame = currentCFrame:Lerp(targetCFrame, smoothness)
            end
        end
    end)
end

return Logic

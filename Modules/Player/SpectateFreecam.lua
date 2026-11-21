local VH = _G.VoidHub
local Services = VH.Services
local State = VH.State
local S = State.S
local Utils = VH.Utils
local UI = VH.UI

local Players = Services.Players
local LP = Services.LP

local getHRP = Utils.getHRP
local notify = Utils.notify
local registerModule = UI.registerModule

local addToggleOption = UI.addToggleOption
local addDropdownOption = UI.addDropdownOption
local addSliderOption = UI.addSliderOption
local addButtonOption = UI.addButtonOption
local addInfoRowOption = UI.addInfoRowOption
local addCustomFrameOption = UI.addCustomFrameOption

local saveConfig = VH.Config.saveConfig

local teleportToHRP = Utils.teleportToHRP
local teleportToCFrame = Utils.teleportToCFrame
local tweenTeleport = Utils.tweenTeleport
local spectatePlayer = Utils.spectatePlayer
local resetCameraToSelf = Utils.resetCameraToSelf
local enableFreecam = Utils.enableFreecam
local disableFreecam = Utils.disableFreecam

local spectateStatsLabels = State.spectateStatsLabels

registerModule("Player", "Spectate & Freecam", 160, 50, false, false, nil, function(drawer)
    local rName = addInfoRowOption(drawer, "Viewing Target Name", State.currentSpectateTarget and State.currentSpectateTarget.DisplayName or "--")
    local rHp = addInfoRowOption(drawer, "Target Health", "--")
    local rTeam = addInfoRowOption(drawer, "Target Team", "--")
    spectateStatsLabels.name = rName.Label
    spectateStatsLabels.hp = rHp.Label
    spectateStatsLabels.team = rTeam.Label

    local function doTeleport(targetCF, callback)
        local method = S.SpectateTPMethod or "Normal TP"
        local speed = S.SpectateTweenSpeed or 100
        return teleportToCFrame(targetCF, method, speed, callback)
    end

    addDropdownOption(drawer, "Teleport Method", { "Normal TP", "Tween TP" }, (S.SpectateTPMethod == "Tween TP") and 2 or 1, function(idx, opt)
        S.SpectateTPMethod = opt
        saveConfig()
    end)

    addSliderOption(drawer, "Tween TP Speed", 25, 300, S.SpectateTweenSpeed or 100, function(v)
        S.SpectateTweenSpeed = v
        saveConfig()
    end)

    addToggleOption(drawer, "Freecam Mode [Scriptable]", State.isFreecam or false, function(v)
        if v then
            enableFreecam()
        else
            disableFreecam()
        end
    end)

    addSliderOption(drawer, "Freecam Speed", 10, 300, S.FreecamSpeed or 60, function(v)
        S.FreecamSpeed = v
        saveConfig()
    end)

    addButtonOption(drawer, "Teleport Character to Freecam", function()
        local hrp = getHRP()
        if hrp and Services.Camera then
            hrp.CFrame = Services.Camera.CFrame
            notify("Teleported character to camera position!", Color3.fromRGB(50, 195, 75))
        end
    end)

    addButtonOption(drawer, "Reset Camera to Character", function()
        resetCameraToSelf()
        notify("Camera reset to local character", Color3.fromRGB(50, 195, 75))
    end)

    addButtonOption(drawer, "Teleport to Nearest Player", function()
        local myHRP = getHRP()
        if not myHRP then notify("Self root part not found!", Color3.fromRGB(218, 38, 38)); return end
        local nearest, shortestDist = nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                local root = p.Character:FindFirstChild("HumanoidRootPart") or p.Character:FindFirstChild("Torso") or p.Character.PrimaryPart
                if root then
                    local dist = (root.Position - myHRP.Position).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        nearest = p
                    end
                end
            end
        end
        if nearest then
            local targetHRP = nearest.Character:FindFirstChild("HumanoidRootPart") or nearest.Character:FindFirstChild("Torso") or nearest.Character.PrimaryPart
            local targetCF = targetHRP.CFrame + Vector3.new(0, 3, 0)
            if doTeleport(targetCF) then
                local actionWord = (S.SpectateTPMethod == "Tween TP") and "Tweening to nearest: " or "Teleported to nearest: "
                notify(actionWord .. nearest.DisplayName .. string.format(" (%.1f studs)", shortestDist), Color3.fromRGB(50, 195, 75))
            end
        else
            notify("No other players found nearby", Color3.fromRGB(218, 38, 38))
        end
    end)

    addButtonOption(drawer, "Teleport to Random Player", function()
        local list = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                local root = p.Character:FindFirstChild("HumanoidRootPart") or p.Character:FindFirstChild("Torso") or p.Character.PrimaryPart
                if root then table.insert(list, p) end
            end
        end
        if #list > 0 then
            local chosen = list[math.random(1, #list)]
            local targetHRP = chosen.Character:FindFirstChild("HumanoidRootPart") or chosen.Character:FindFirstChild("Torso") or chosen.Character.PrimaryPart
            local targetCF = targetHRP.CFrame + Vector3.new(0, 3, 0)
            if doTeleport(targetCF) then
                local actionWord = (S.SpectateTPMethod == "Tween TP") and "Tweening to random: " or "Teleported to random: "
                notify(actionWord .. chosen.DisplayName, Color3.fromRGB(50, 195, 75))
            end
        else
            notify("No alternative player found to teleport to", Color3.fromRGB(218, 38, 38))
        end
    end)

    addToggleOption(drawer, "Auto Follow Target", S.FollowActive, function(v)
        S.FollowActive = v
        S.FollowTarget = State.currentSpectateTarget
        saveConfig()
    end)

    local frame = addCustomFrameOption(drawer, 240)

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -8, 0, 24)
    box.Position = UDim2.new(0, 4, 0, 2)
    box.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
    box.BorderSizePixel = 0
    box.Font = Enum.Font.GothamMedium
    box.TextSize = 10
    box.TextColor3 = Color3.fromRGB(240, 240, 245)
    box.PlaceholderText = "Search player to view / teleport..."
    box.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
    box.Text = ""
    box.ClearTextOnFocus = false
    box.Parent = frame
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
    local bStroke = Instance.new("UIStroke")
    bStroke.Color = Color3.fromRGB(38, 38, 46)
    bStroke.Thickness = 1
    bStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    bStroke.Parent = box
    local bPad = Instance.new("UIPadding", box)
    bPad.PaddingLeft = UDim.new(0, 8)
    bPad.PaddingRight = UDim.new(0, 8)

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -8, 1, -30)
    scroll.Position = UDim2.new(0, 4, 0, 28)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = frame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scroll

    local function renderPlayers()
        for _, child in ipairs(scroll:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end

        local filter = box.Text:lower()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP then
                local formatted = p.DisplayName .. " @" .. p.Name
                if filter == "" or formatted:lower():find(filter, 1, true) then
                    local isViewing = (State.currentSpectateTarget == p)

                    local card = Instance.new("Frame")
                    card.Size = UDim2.new(1, -2, 0, 36)
                    card.BackgroundColor3 = isViewing and Color3.fromRGB(36, 36, 48) or Color3.fromRGB(24, 24, 28)
                    card.BorderSizePixel = 0
                    card.Parent = scroll
                    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 4)

                    local cStroke = Instance.new("UIStroke")
                    cStroke.Color = isViewing and (State.currentThemeColor or Color3.fromRGB(141, 47, 196)) or Color3.fromRGB(38, 38, 46)
                    cStroke.Thickness = 1
                    cStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    cStroke.Parent = card

                    local pThumb = Instance.new("ImageLabel")
                    pThumb.Size = UDim2.new(0, 28, 0, 28)
                    pThumb.Position = UDim2.new(0, 4, 0.5, -14)
                    pThumb.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
                    pThumb.BorderSizePixel = 0
                    pThumb.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(p.UserId) .. "&w=150&h=150"
                    pThumb.ScaleType = Enum.ScaleType.Fit
                    pThumb.Parent = card
                    Instance.new("UICorner", pThumb).CornerRadius = UDim.new(0, 4)

                    local info = Instance.new("Frame")
                    info.Size = UDim2.new(1, -140, 1, 0)
                    info.Position = UDim2.new(0, 36, 0, 0)
                    info.BackgroundTransparency = 1
                    info.BorderSizePixel = 0
                    info.Parent = card

                    local nameL = Instance.new("TextLabel")
                    nameL.Size = UDim2.new(1, 0, 0, 14)
                    nameL.Position = UDim2.new(0, 0, 0, 4)
                    nameL.BackgroundTransparency = 1
                    nameL.Font = Enum.Font.GothamBold
                    nameL.TextSize = 10
                    nameL.TextColor3 = Color3.fromRGB(240, 240, 245)
                    nameL.TextXAlignment = Enum.TextXAlignment.Left
                    nameL.TextTruncate = Enum.TextTruncate.AtEnd
                    nameL.Text = p.DisplayName
                    nameL.Parent = info

                    local userL = Instance.new("TextLabel")
                    userL.Size = UDim2.new(1, 0, 0, 12)
                    userL.Position = UDim2.new(0, 0, 0, 18)
                    userL.BackgroundTransparency = 1
                    userL.Font = Enum.Font.Gotham
                    userL.TextSize = 8
                    userL.TextColor3 = isViewing and (State.currentThemeColor or Color3.fromRGB(141, 47, 196)) or Color3.fromRGB(150, 150, 160)
                    userL.TextXAlignment = Enum.TextXAlignment.Left
                    userL.TextTruncate = Enum.TextTruncate.AtEnd
                    userL.Text = "@" .. p.Name
                    userL.Parent = info

                    local tp = Instance.new("TextButton")
                    tp.Size = UDim2.new(0, 32, 0, 22)
                    tp.Position = UDim2.new(1, -88, 0.5, -11)
                    tp.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
                    tp.BorderSizePixel = 0
                    tp.Font = Enum.Font.GothamBold
                    tp.TextSize = 9
                    tp.TextColor3 = Color3.fromRGB(255, 255, 255)
                    tp.Text = "TP"
                    tp.Parent = card
                    Instance.new("UICorner", tp).CornerRadius = UDim.new(0, 4)

                    tp.MouseButton1Click:Connect(function()
                        local targetHRP = p.Character and (p.Character:FindFirstChild("HumanoidRootPart") or p.Character:FindFirstChild("Torso"))
                        if targetHRP then
                            local targetCF = targetHRP.CFrame + Vector3.new(0, 3, 0)
                            if doTeleport(targetCF) then
                                local actionWord = (S.SpectateTPMethod == "Tween TP") and "Tweening to " or "Teleported to "
                                notify(actionWord .. p.DisplayName, Color3.fromRGB(50, 195, 75))
                            end
                        else
                            notify("Target character not loaded", Color3.fromRGB(218, 38, 38))
                        end
                    end)

                    local view = Instance.new("TextButton")
                    view.Size = UDim2.new(0, 50, 0, 22)
                    view.Position = UDim2.new(1, -52, 0.5, -11)
                    view.BackgroundColor3 = isViewing and Color3.fromRGB(218, 38, 38) or Color3.fromRGB(45, 45, 54)
                    view.BorderSizePixel = 0
                    view.Font = Enum.Font.GothamBold
                    view.TextSize = 9
                    view.TextColor3 = Color3.fromRGB(255, 255, 255)
                    view.Text = isViewing and "UNVIEW" or "VIEW"
                    view.Parent = card
                    Instance.new("UICorner", view).CornerRadius = UDim.new(0, 4)

                    view.MouseButton1Click:Connect(function()
                        if State.currentSpectateTarget == p then
                            spectatePlayer(nil)
                        else
                            spectatePlayer(p)
                        end
                        renderPlayers()
                    end)
                end
            end
        end
    end

    box:GetPropertyChangedSignal("Text"):Connect(renderPlayers)

    local addedCon = Players.PlayerAdded:Connect(renderPlayers)
    local removedCon = Players.PlayerRemoving:Connect(function(p)
        if State.currentSpectateTarget == p then
            spectatePlayer(nil)
        end
        renderPlayers()
    end)

    table.insert(S.Connections, addedCon)
    table.insert(S.Connections, removedCon)
    renderPlayers()
end, true, 340, 460)

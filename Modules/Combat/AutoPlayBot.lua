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

local function getBestTarget()
    local best = nil
    local bestVal = math.huge
    local myHRP = getHRP()
    if not myHRP then return nil end

    for _, p in ipairs(Players:GetPlayers()) do
        if p == LP then continue end
        if S.AutoplayTeamCheck and p.Team == LP.Team then continue end
        if S.AutoplayFriendCheck and checkFriendship(p.UserId) then continue end

        local char = p.Character
        local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char.PrimaryPart)
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hrp and hum and hum.Health > 0 then
            if S.AutoplayTargetMode == "Closest" then
                local dist = (hrp.Position - myHRP.Position).Magnitude
                if dist < bestVal then
                    bestVal = dist
                    best = p
                end
            elseif S.AutoplayTargetMode == "Lowest HP" then
                local hp = hum.Health
                if hp < bestVal then
                    bestVal = hp
                    best = p
                end
            end
        end
    end
    return best
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

local function startAutoplay()
    task.spawn(function()
        while S.AutoplayBot do
            task.wait(0.2)
            pcall(function()
                local char = getChar()
                local hum = getHum()
                local myHRP = getHRP()
                if not char or not hum or not myHRP or hum.Health <= 0 then return end

                local target = getBestTarget()
                if not target then
                    hum:Move(Vector3.new(0, 0, 0))
                    return
                end

                local targetHRP = target.Character and (target.Character:FindFirstChild("HumanoidRootPart") or target.Character:FindFirstChild("Torso") or target.Character.PrimaryPart)
                if not targetHRP then return end

                -- Auto Shoot / Aim
                if S.AutoplayShoot then
                    local tool = char:FindFirstChildOfClass("Tool")
                    if not tool then
                        local weapon = LP.Backpack:FindFirstChildOfClass("Tool")
                        if weapon then
                            hum:EquipTool(weapon)
                        end
                    else
                        local dist = (targetHRP.Position - myHRP.Position).Magnitude
                        if dist <= S.AutoplayRange and checkLineOfSight(targetHRP) then
                            tool:Activate()
                            pcall(function()
                                VirtualInputManager:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, true, game, 1)
                                task.wait(0.01)
                                VirtualInputManager:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, false, game, 1)
                            end)
                            shootTimer = shootTimer + 0.2
                        end
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

                -- Obstacle/Surface Raycast check (identifies front walls to force jump)
                local lookDir = myHRP.CFrame.LookVector
                local rayParams = RaycastParams.new()
                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                rayParams.FilterDescendantsInstances = {char}
                local frontRay = workspace:Raycast(myHRP.Position, lookDir * 4, rayParams)
                if frontRay and frontRay.Instance and not frontRay.Instance:IsDescendantOf(target.Character) then
                    hum.Jump = true
                end

                -- Pathfinding logic
                local targetPos = targetHRP.Position
                local path = PathfindingService:CreatePath({
                    AgentRadius = 2.0,
                    AgentHeight = 5.0,
                    AgentCanJump = true,
                    AgentCanClimb = true
                })

                path:ComputeAsync(myHRP.Position, targetPos)
                if path.Status == Enum.PathStatus.Success then
                    local waypoints = path:GetWaypoints()
                    if #waypoints > 1 then
                        local nextWaypoint = waypoints[2]
                        if S.WalkSpeed and S.WalkSpeed > 16 then
                            hum.WalkSpeed = S.WalkSpeed
                        end
                        hum:MoveTo(nextWaypoint.Position)
                        if nextWaypoint.Action == Enum.PathWaypointAction.Jump then
                            hum.Jump = true
                        end
                    else
                        hum:MoveTo(targetPos)
                    end
                else
                    hum:MoveTo(targetPos)
                end
            end)
        end
    end)
end

registerModule("Combat", "Autoplay Bot", 20, 50, true, S.AutoplayBot, function(v)
    S.AutoplayBot = v
    saveConfig()
    if v then
        startAutoplay()
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

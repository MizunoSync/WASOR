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
local PathfindingService = Services.PathfindingService

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


local UserInputService = Services.UserInputService
local walkConn
local currentWalkSession = 0

registerModule("Movement", "Auto-Walk to Mouse", 300, 50, true, S.PathfindingWalk, function(v)
    S.PathfindingWalk = v
    if v then
        walkConn = UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                currentWalkSession = currentWalkSession + 1
                local session = currentWalkSession
                task.spawn(function()
                    local hum = getHum(); local hrp = getHRP(); if not hum or not hrp then return end
                    local targetPos = Mouse.Hit.Position
                    local path = PathfindingService:CreatePath({ AgentRadius = 2, AgentHeight = 5, AgentCanJump = true })
                    local ok = pcall(function() path:ComputeAsync(hrp.Position, targetPos) end)
                    if ok and path.Status == Enum.PathStatus.Success then
                        local waypoints = path:GetWaypoints()
                        for i, wp in ipairs(waypoints) do
                            if currentWalkSession ~= session or not S.PathfindingWalk then break end
                            if wp.Action == Enum.PathWaypointAction.Jump then hum.Jump = true end
                            hum:MoveTo(wp.Position); local timeout = tick() + 1
                            repeat task.wait() if (hrp.Position - wp.Position).Magnitude < 4 or tick() > timeout then break end until currentWalkSession ~= session or not S.PathfindingWalk
                        end
                    else
                        hum:MoveTo(targetPos)
                    end
                end)
            end
        end)
        table.insert(S.Connections, walkConn)
    else
        currentWalkSession = currentWalkSession + 1
        if walkConn then pcall(function() walkConn:Disconnect() end) walkConn = nil end
        local hum = getHum()
        if hum then hum:MoveTo(getHRP().Position) end
    end
    saveConfig()
end)

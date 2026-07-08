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


registerModule("Player", "Reset Character", 160, 50, false, false, function()
    local char = getChar()
    local hum = getHum()
    local hrp = getHRP()
    
    if hum then
        pcall(function() hum.Health = 0 end)
    end
    
    task.delay(0.1, function()
        if char and hum and hum.Parent and hum.Health > 0 then
            pcall(function() char:BreakJoints() end)
        end
    end)
    
    task.delay(0.2, function()
        if char and hum and hum.Parent and hum.Health > 0 then
            if hrp then
                pcall(function() hrp.CFrame = CFrame.new(0, -99999, 0) end)
            end
        end
    end)
    
    task.delay(0.3, function()
        if char and hum and hum.Parent and hum.Health > 0 then
            local head = char:FindFirstChild("Head")
            local neck = head and (head:FindFirstChild("Neck") or char:FindFirstChild("Neck", true))
            if neck then
                pcall(function() neck:Destroy() end)
            elseif head then
                pcall(function() head:Destroy() end)
            end
        end
    end)
    
    task.delay(0.4, function()
        if char and hum and hum.Parent and hum.Health > 0 then
            pcall(function() hum:Destroy() end)
        end
    end)
    
    notify("Character reset!", Color3.fromRGB(218, 38, 38))
end)

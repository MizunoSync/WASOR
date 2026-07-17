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


registerModule("Combat", "Auto Clicker", 20, 50, true, S.AutoClicker, function(v)
    S.AutoClicker = v
    if v then
        task.spawn(function()
            if S.AutoClickerDelay and S.AutoClickerDelay > 0 then
                task.wait(S.AutoClickerDelay)
            end
            while S.AutoClicker and State.uiRunning do
                if mouse1press and mouse1release then
                    mouse1press()
                    task.wait(0.01)
                    mouse1release()
                    task.wait(S.AutoClickerInterval or 0.1)
                elseif mouse1click then
                    mouse1click()
                    task.wait(S.AutoClickerInterval or 0.1)
                else
                    pcall(function()
                        Services.VirtualUser:CaptureController()
                        Services.VirtualUser:ClickButton1(Vector2.new(Mouse.X, Mouse.Y))
                    end)
                    task.wait(S.AutoClickerInterval or 0.1)
                end
            end
        end)
    end
    saveConfig()
end, function(drawer)
    addKeybindOption(drawer, "Auto Clicker Bind", S.AutoClickerKey or Enum.KeyCode.Unknown, function(k) S.AutoClickerKey = k; saveConfig() end)
    addSliderOption(drawer, "Start Delay (sec)", 0, 5, S.AutoClickerDelay or 1, function(v) S.AutoClickerDelay = v; saveConfig() end)
    addSliderOption(drawer, "Click Interval (sec)", 1, 100, math.round((S.AutoClickerInterval or 0.1) * 100), function(v) S.AutoClickerInterval = v / 100; saveConfig() end)
end, false)

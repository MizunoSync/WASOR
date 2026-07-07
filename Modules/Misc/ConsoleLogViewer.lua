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


registerModule("Misc", "Console Log Viewer", 720, 50, false, false, nil, function(drawer)
    local conFeed = addScrollFeedOption(drawer, 80); activeConsoleFeed = conFeed; local showI, showW, showE = true, true, true
    local function rebuildConsole()
        conFeed:Clear()
        for _, log in ipairs(consoleLogs) do
            local msg = log.message; local mType = log.messageType; local col = Color3.fromRGB(220, 220, 220); local prefix = ""; local show = false
            if mType == Enum.MessageType.MessageOutput or mType == Enum.MessageType.MessageInfo then if mType == Enum.MessageType.MessageInfo then col = Color3.fromRGB(80, 180, 240); prefix = "[INFO] " end; show = showI
            elseif mType == Enum.MessageType.MessageWarning then col = Color3.fromRGB(240, 200, 50); prefix = "[WARN] "; show = showW
            elseif mType == Enum.MessageType.MessageError then col = Color3.fromRGB(240, 70, 70); prefix = "[ERROR] "; show = showE end
            if show then conFeed:AddEntry(prefix .. msg, col, log.count) end
        end
    end
    addToggleOption(drawer, "Show Prints & Info", showI, function(v) showI = v; rebuildConsole() end)
    addToggleOption(drawer, "Show Warnings", showW, function(v) showW = v; rebuildConsole() end)
    addToggleOption(drawer, "Show Errors", showE, function(v) showE = v; rebuildConsole() end)
    addButtonOption(drawer, "Clear Console Log", function() consoleLogs = {}; consoleLogsMap = {}; conFeed:Clear() end)
    rebuildConsole()
end, true, 240, 220)

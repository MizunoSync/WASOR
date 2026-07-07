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


registerModule("Misc", "Settings & Keybinds", 720, 50, false, false, nil, function(drawer)
    addToggleOption(drawer, "Auto-Reinject", S.AutoReinject, function(v) S.AutoReinject = v; saveConfig(); setupAutoReinject() end)
    addToggleOption(drawer, "Join/Leave Toasts", S.JoinLeaveToasts, function(v) S.JoinLeaveToasts = v; saveConfig() end)
    addKeybindOption(drawer, "Fly Bind", S.FlyKey, function(k) S.FlyKey = k; saveConfig() end)
    addKeybindOption(drawer, "NoClip Bind", S.NoClipKey, function(k) S.NoClipKey = k; saveConfig() end)
    addKeybindOption(drawer, "Bunnyhop Bind", S.BHopKey, function(k) S.BHopKey = k; saveConfig() end)
    addKeybindOption(drawer, "InfJump Bind", S.InfJumpKey, function(k) S.InfJumpKey = k; saveConfig() end)
    addKeybindOption(drawer, "Ghost Bind", S.GhostKey, function(k) S.GhostKey = k; saveConfig() end)
    addKeybindOption(drawer, "Blink Bind", S.BlinkKey, function(k) S.BlinkKey = k; saveConfig() end)
    addKeybindOption(drawer, "JumpStrength Bind", S.JumpStrengthKey, function(k) S.JumpStrengthKey = k; saveConfig() end)
end, false)

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


registerModule("Combat", "Aimbot", 20, 50, true, S.AimbotActive, function(v) S.AimbotActive = v; notify("Aimbot " .. (v and "Enabled" or "Disabled"), Color3.fromRGB(50, 195, 75)); saveConfig() end, function(drawer)
    addToggleOption(drawer, "Aimbot Team Check", S.AimbotTeamCheck, function(v) S.AimbotTeamCheck = v; saveConfig() end)
    addToggleOption(drawer, "Aimbot Ignore Friends", S.AimbotIgnoreFriends, function(v) S.AimbotIgnoreFriends = v; saveConfig() end)
    addToggleOption(drawer, "Draw FOV Circle", S.AimbotShowFOV, function(v) S.AimbotShowFOV = v; saveConfig() end)
    addSliderOption(drawer, "FOV Circle Radius", 20, 600, S.AimbotFOV, function(v) S.AimbotFOV = v; saveConfig() end)
    addSliderOption(drawer, "Aimbot Smoothness", 1, 30, S.AimbotSmooth, function(v) S.AimbotSmooth = v; saveConfig() end)
    addToggleOption(drawer, "Wall Visibility Check", S.AimbotVisibility, function(v) S.AimbotVisibility = v; saveConfig() end)
    addDropdownOption(drawer, "Locked Target Part", {"Head", "Torso", "Random"}, table.find({"Head", "Torso", "Random"}, S.AimbotPart) or 1, function(_, opt) S.AimbotPart = opt; saveConfig() end)
    addDropdownOption(drawer, "Aimbot Hold Mode", {"M2", "Keyboard"}, S.AimbotHoldMode == "Keyboard" and 2 or 1, function(_, opt) S.AimbotHoldMode = opt; saveConfig() end)
    addKeybindOption(drawer, "Aimbot Hold Key", S.AimbotHoldKey, function(k) S.AimbotHoldKey = k; saveConfig() end)
end, false)

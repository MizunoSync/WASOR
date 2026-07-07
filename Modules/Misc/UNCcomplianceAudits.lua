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


registerModule("Misc", "UNC compliance & Audits", 720, 50, false, false, nil, function(drawer)
    addButtonOption(drawer, "Run UNC Test Compliance Suite", function() runExternalScript("UNC Test", "https://raw.githubusercontent.com/VenezzaX/Usefulthings/refs/heads/main/Unc.lua") end)
    addButtonOption(drawer, "Run Executor Vuln Test", function() runExternalScript("Vulnerability Test", "https://raw.githubusercontent.com/VenezzaX/Usefulthings/refs/heads/main/VulnerabilityTest.lua") end)
    addButtonOption(drawer, "Run Workspace Instance Dumper", function() runExternalScript("Workspace Dumper", "https://raw.githubusercontent.com/VenezzaX/Usefulthings/refs/heads/main/WorkspaceDumper.lua") end)
    addButtonOption(drawer, "Run SUNC Exploit Tester", function() runExternalScript("SUNC Test", "https://raw.githubusercontent.com/VenezzaX/Usefulthings/refs/heads/main/Sunc.lua", 90441122676618) end)
    addButtonOption(drawer, "Run Myriad Executor Test", function() runExternalScript("Myriad Test", "https://raw.githubusercontent.com/VenezzaX/Usefulthings/refs/heads/main/MyriadTest.lua", 79035306837882) end)
    addButtonOption(drawer, "Teleport to SUNC Test Game", function() teleportToPlace(90441122676618) end)
    addButtonOption(drawer, "Teleport to Myriad Test Game", function() teleportToPlace(79035306837882) end)
end, true, 200, 180)

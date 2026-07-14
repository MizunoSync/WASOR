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


registerModule("Misc", "External Scripts Hub", 720, 50, false, false, nil, function(drawer)
    addButtonOption(drawer, "Load Rotector", function() runExternalScript("Rotector", "https://raw.githubusercontent.com/VenezzaX/RobloxRotector/refs/heads/main/Rotector.lua") end)
    addButtonOption(drawer, "Load FE Emotes Script", function() runExternalScript("FE Emotes", "https://raw.githubusercontent.com/VenezzaX/Usefulthings/refs/heads/main/FeEmotes.lua") end)
    addButtonOption(drawer, "Load Gamepass Bypass", function() runExternalScript("Gamepass Bypass", "https://raw.githubusercontent.com/VenezzaX/Usefulthings/refs/heads/main/gamepassbypass.lua") end)
    addButtonOption(drawer, "Load Coordinate UI", function() runExternalScript("Coordinate UI", "https://raw.githubusercontent.com/VenezzaX/Usefulthings/refs/heads/main/CoordinateUI.lua") end)
    addButtonOption(drawer, "Load Vex Explorer", function() runExternalScript("Vex", "https://raw.githubusercontent.com/Vezise/2026/main/Vez/VexExplorer/VEXExplorer.lua") end)
    addButtonOption(drawer, "Load Dex Explorer (Injected)", function() pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))() end); notify("Dex Explorer loaded successfully!", Color3.fromRGB(50, 195, 75)) end)
    addButtonOption(drawer, "Load Cobalt UI Wrapper", function() pcall(function() loadstring(game:HttpGet("https://github.com/notpoiu/cobalt/releases/latest/download/Cobalt.luau"))() end); notify("Cobalt UI loaded successfully!", Color3.fromRGB(50, 195, 75)) end)
    addButtonOption(drawer, "Load Infinite Yield Admin", function() pcall(function() loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source', true))() end); notify("Infinite Yield loaded successfully!", Color3.fromRGB(50, 195, 75)) end)
    addButtonOption(drawer, "Load SimpleSpy V3 (Remote)", function() pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/SimpleSpyV3/main.lua"))() end); notify("SimpleSpy V3 loaded successfully!", Color3.fromRGB(50, 195, 75)) end)
    addButtonOption(drawer, "Load Hydroxide", function() runExternalScript("Hydroxide", "https://raw.githubusercontent.com/Upbolt/Hydroxide/revision/init.lua") end)
end, true, 200, 220)

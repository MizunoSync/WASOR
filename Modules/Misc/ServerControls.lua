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


registerModule("Misc", "Server Controls", 720, 50, false, false, nil, function(drawer)
    addButtonOption(drawer, "Rejoin Instance", function() notify("Rejoining server instance...", Color3.fromRGB(218, 170, 42)); setupAutoReinject(); task.delay(0.5, function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP) end) end)
    addButtonOption(drawer, "Standard Server Hop", teleportToRandom)
    addButtonOption(drawer, "Join Random Server", teleportToRandom)
    addButtonOption(drawer, "Join Lowest Population", teleportToLowestPop)
    addButtonOption(drawer, "Join Highest Population", teleportToHighestPop)
    addButtonOption(drawer, "Copy Server JobId", function() local setclip = setclipboard or writeclipboard or toclipboard or print; pcall(function() setclip(game.JobId) end); notify("Server JobId copied to clipboard!", Color3.fromRGB(50, 195, 75)) end)
    local rRegion = addInfoRowOption(drawer, "Region Location", "Loading..."); local rPing = addInfoRowOption(drawer, "Connection Ping", "--"); local rPlayers = addInfoRowOption(drawer, "Player Count Status", "--"); local rAge = addInfoRowOption(drawer, "Instance Uptime Age", "--")
    serverStatsLabels.region = rRegion.Label; serverStatsLabels.ping = rPing.Label; serverStatsLabels.players = rPlayers.Label; serverStatsLabels.age = rAge.Label
end, true, 200, 240)

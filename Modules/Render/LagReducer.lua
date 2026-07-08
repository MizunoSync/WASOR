local VH = _G.VoidHub
local Services = VH.Services
local State = VH.State
local S = State.S
local Utils = VH.Utils
local UI = VH.UI

local toggleGraphicsReducer = Utils.toggleGraphicsReducer

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


registerModule("Render", "Lag Reducer", 440, 50, true, S.GraphicsReducer, function(v)
    toggleGraphicsReducer(v)
    saveConfig()
end, function(drawer)
    addSliderOption(drawer, "FPS Limit Cap", 15, 360, S.FPSCap, function(v)
        S.FPSCap = v
        pcall(function() if setfpscap then setfpscap(v) end end)
        saveConfig()
    end)
    addToggleOption(drawer, "Potato Materials (Global)", S.LagReducePotatoMode, function(v)
        S.LagReducePotatoMode = v
        if S.GraphicsReducer then toggleGraphicsReducer(true) end
        saveConfig()
    end)
    addToggleOption(drawer, "Disable Game Shadows", S.LagReduceShadows, function(v)
        S.LagReduceShadows = v
        if S.GraphicsReducer then toggleGraphicsReducer(true) end
        saveConfig()
    end)
    addToggleOption(drawer, "Disable Decals & Textures", S.LagReduceDecals, function(v)
        S.LagReduceDecals = v
        if S.GraphicsReducer then toggleGraphicsReducer(true) end
        saveConfig()
    end)
    addToggleOption(drawer, "Disable Particles & Sparks", S.LagReduceParticles, function(v)
        S.LagReduceParticles = v
        if S.GraphicsReducer then toggleGraphicsReducer(true) end
        saveConfig()
    end)
    addToggleOption(drawer, "Disable Lighting Post-FX", S.LagReduceEffects, function(v)
        S.LagReduceEffects = v
        if S.GraphicsReducer then toggleGraphicsReducer(true) end
        saveConfig()
    end)
end, false)

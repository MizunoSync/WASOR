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


registerModule("Misc", "Chat Logger", 720, 50, false, false, nil, function(drawer)
    local filter = ""; local chatFeed = addScrollFeedOption(drawer, 80); activeChatFeed = chatFeed
    addTextboxOption(drawer, "Filter chat logs text", "Filter text", function(txt)
        filter = txt; chatFeed:Clear()
        for _, log in ipairs(S.ChatHistory) do local matches = true; if filter ~= "" then matches = log.Speaker:lower():find(filter:lower()) or log.Message:lower():find(filter:lower()) end; if matches then chatFeed:AddEntry(string.format("[%s] [%s]: %s", log.Timestamp, log.Speaker, log.Message), log.Color) end end
    end)
    addButtonOption(drawer, "Copy Entire Chat Logs", function()
        local text = ""; for _, log in ipairs(S.ChatHistory) do text = text .. string.format("[%s] [%s]: %s\n", log.Timestamp, log.Speaker, log.Message) end
        local write = setclipboard or writeclipboard or toclipboard or print
        if pcall(function() write(text) end) then notify("Logs copied to clipboard!", Color3.fromRGB(50, 195, 75)) else notify("Clipboard write failed", Color3.fromRGB(218, 38, 38)) end
    end)
    addToggleOption(drawer, "Toast notifications on chat", S.ToastChatEnabled, function(v) S.ToastChatEnabled = v; saveConfig() end)
    for _, log in ipairs(S.ChatHistory) do chatFeed:AddEntry(string.format("[%s] [%s]: %s", log.Timestamp, log.Speaker, log.Message), log.Color) end
end, true, 240, 220)

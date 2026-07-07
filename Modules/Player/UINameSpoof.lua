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


registerModule("Player", "UI Name Spoof", 160, 50, true, S.RandomizeUIText, function(v)
    S.RandomizeUIText = v
    local function clearHooks() for obj, data in pairs(S.UISpoofObjects) do if data.Conn then data.Conn:Disconnect() end; if data.DestConn then data.DestConn:Disconnect() end end; S.UISpoofObjects = {} end
    if v then
        S.SessionSpoofName = "Guest_" .. math.random(1000, 9999)
        local function hookObject(obj)
            if S.UISpoofObjects[obj] then return end
            if (obj:IsA("TextLabel") or obj:IsA("TextButton")) then
                local txt = obj.Text; local lowerText = string.lower(txt)
                if string.find(lowerText, string.lower(LP.Name), 1, true) or string.find(lowerText, string.lower(LP.DisplayName), 1, true) then
                    local data = {}
                    data.Conn = obj:GetPropertyChangedSignal("Text"):Connect(function()
                        if not obj or not obj.Parent then if data.Conn then data.Conn:Disconnect() end; if data.DestConn then data.DestConn:Disconnect() end; S.UISpoofObjects[obj] = nil; return end
                        processUISpoofText(obj)
                    end)
                    data.DestConn = obj.AncestryChanged:Connect(function(_, parent) if not parent then if data.Conn then data.Conn:Disconnect() end; if data.DestConn then data.DestConn:Disconnect() end; S.UISpoofObjects[obj] = nil end end)
                    S.UISpoofObjects[obj] = data; processUISpoofText(obj)
                end
            end
        end
        local pg = LP:WaitForChild("PlayerGui")
        for _, obj in ipairs(pg:GetDescendants()) do hookObject(obj) end
        local addedConn = pg.DescendantAdded:Connect(hookObject); table.insert(S.Connections, addedConn)
    else clearHooks() end
    saveConfig()
end, function(drawer)
    addTextboxOption(drawer, "Custom Spoof Text (Blank for Guest)", S.CustomUIText, function(txt)
        S.CustomUIText = txt
        for obj, _ in pairs(S.UISpoofObjects) do if obj and obj.Parent then processUISpoofText(obj) end end
        saveConfig()
    end)
end, false)

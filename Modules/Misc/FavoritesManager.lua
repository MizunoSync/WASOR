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


registerModule("Misc", "Favorites Manager", 720, 50, false, false, nil, function(drawer)
    addTextboxOption(drawer, "Save Place ID to Favorites", "Place ID", function(txt)
        local pid = tonumber(txt:match("%d+"))
        if not pid then notify("Enter a valid place ID", Color3.fromRGB(218, 38, 38)); return end
        for _, item in ipairs(S.FavoriteMaps) do if item.id == pid then notify("Already in favorites!", Color3.fromRGB(218, 170, 42)); return end end
        notify("Resolving Place ID info...", Color3.fromRGB(218, 170, 42))
        task.spawn(function()
            local gameName = "Place: " .. pid; local universeId = nil
            pcall(function()
                local res = HttpService:JSONDecode(robloxGet(("https://apis.roblox.com/universes/v1/places/%d/universe"):format(pid)))
                if res and res.universeId then universeId = res.universeId; local resDetails = HttpService:JSONDecode(robloxGet(("https://games.roblox.com/v1/games?universeIds=%d"):format(universeId))); if resDetails and resDetails.data and resDetails.data[1] then gameName = resDetails.data[1].name end end
            end)
            table.insert(S.FavoriteMaps, { id = pid, universeId = universeId, iconUrl = nil, name = gameName, lastPlayed = "Added: " .. os.date("%m-%d %H:%M") })
            saveFavorites(); notify("Saved: " .. gameName, Color3.fromRGB(50, 195, 75))
        end)
    end)
    local frame = addCustomFrameOption(drawer, 80)
    local scroll = Instance.new("ScrollingFrame"); scroll.Size = UDim2.new(1, -8, 1, 0); scroll.Position = UDim2.new(0, 4, 0, 0); scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0; scroll.ScrollBarThickness = 1; scroll.CanvasSize = UDim2.new(0, 0, 0, 0); scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; scroll.Parent = frame
    local layout = Instance.new("UIListLayout"); layout.Padding = UDim.new(0, 2); layout.Parent = scroll; rebuildFavorites(scroll)
end, true, 200, 200)

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


registerModule("Misc", "Online Friends", 720, 50, false, false, nil, function(drawer)
    local frame = addCustomFrameOption(drawer, 100)
    local refreshBtn = Instance.new("TextButton"); refreshBtn.Size = UDim2.new(1, -8, 0, 14); refreshBtn.Position = UDim2.new(0, 4, 0, 0); refreshBtn.BackgroundColor3 = currentThemeColor; refreshBtn.BorderSizePixel = 0; refreshBtn.Font = Enum.Font.GothamBold; refreshBtn.TextSize = 8; refreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255); refreshBtn.Text = "Refresh Online Friends"; refreshBtn.Parent = frame; table.insert(themeHeaders, refreshBtn)
    local scroll = Instance.new("ScrollingFrame"); scroll.Size = UDim2.new(1, -8, 1, -16); scroll.Position = UDim2.new(0, 4, 0, 16); scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0; scroll.ScrollBarThickness = 1; scroll.CanvasSize = UDim2.new(0, 0, 0, 0); scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; scroll.Parent = frame
    local layout = Instance.new("UIListLayout"); layout.Padding = UDim.new(0, 2); layout.Parent = scroll
    refreshBtn.MouseButton1Click:Connect(function() rebuildFriends(scroll) end); rebuildFriends(scroll)
end, true, 200, 200)

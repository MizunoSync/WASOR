local VH = _G.VoidHub
local State = VH.State
local S = State.S
local UI = VH.UI

local registerModule = UI.registerModule
local addSliderOption = UI.addSliderOption
local addToggleOption = UI.addToggleOption
local saveConfig = VH.Config.saveConfig

registerModule("Render", "Out-of-View Indicators", 440, 50, true, S.OutOfViewIndicators, function(v)
    S.OutOfViewIndicators = v
    saveConfig()
end, function(drawer)
    addToggleOption(drawer, "Indicator Team Check", S.OutOfViewTeamCheck, function(v) S.OutOfViewTeamCheck = v; saveConfig() end)
    addSliderOption(drawer, "Indicator Radius", 50, 400, S.OutOfViewIndicatorRadius or 200, function(v) S.OutOfViewIndicatorRadius = v; saveConfig() end)
end, false)

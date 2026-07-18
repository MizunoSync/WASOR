local VH = _G.VoidHub
local State = VH.State
local S = State.S
local Utils = VH.Utils
local UI = VH.UI

local getHum = Utils.getHum
local registerModule = UI.registerModule

local addToggleOption = UI.addToggleOption
local addSliderOption = UI.addSliderOption

local saveConfig = VH.Config.saveConfig

registerModule("Movement", "Speed Modification", 300, 50, true, S.ForceWalkSpeed, function(v) S.ForceWalkSpeed = v; local hum = getHum(); if hum then hum.WalkSpeed = v and S.WalkSpeed or gameDefaultSpeed end; saveConfig() end, function(drawer)
    addSliderOption(drawer, "WalkSpeed Speed", 16, 250, S.WalkSpeed, function(v) S.WalkSpeed = v; saveConfig(); local hum = getHum(); if hum and S.ForceWalkSpeed then hum.WalkSpeed = v end end)
    addToggleOption(drawer, "Always Enforce WalkSpeed", S.ForceWalkSpeed, function(v) S.ForceWalkSpeed = v; saveConfig(); local hum = getHum(); if hum then hum.WalkSpeed = v and S.WalkSpeed or gameDefaultSpeed end end)
end, false)

local VH = _G.VoidHub
local State = VH.State
local S = State.S
local Utils = VH.Utils
local UI = VH.UI

local getHum = Utils.getHum
local registerModule = UI.registerModule

local addToggleOption = UI.addToggleOption
local addSliderOption = UI.addSliderOption
local addKeybindOption = UI.addKeybindOption

local saveConfig = VH.Config.saveConfig

registerModule("Movement", "Jump Hack Strength", 300, 50, true, S.ForceJumpPower, function(v) S.ForceJumpPower = v; local hum = getHum(); if hum then if v then hum.UseJumpPower = true; hum.JumpPower = S.JumpPower else hum.UseJumpPower = gameDefaultUseJumpPower; hum.JumpPower = gameDefaultJumpPower end end; saveConfig() end, function(drawer)
    addSliderOption(drawer, "JumpPower Strength", 50, 350, S.JumpPower, function(v) S.JumpPower = v; saveConfig(); local hum = getHum(); if hum and S.ForceJumpPower then hum.UseJumpPower = true; hum.JumpPower = v end end)
    addToggleOption(drawer, "Always Enforce JumpPower", S.ForceJumpPower, function(v) S.ForceJumpPower = v; saveConfig(); local hum = getHum(); if hum then if v then hum.UseJumpPower = true; hum.JumpPower = S.JumpPower else hum.UseJumpPower = gameDefaultUseJumpPower; hum.JumpPower = gameDefaultJumpPower end end end)
    addKeybindOption(drawer, "Jump Strength Bind", S.JumpStrengthKey, function(k) S.JumpStrengthKey = k; saveConfig() end)
end, false)

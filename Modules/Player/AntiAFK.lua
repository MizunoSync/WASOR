local VH = _G.VoidHub
local State = VH.State
local S = State.S
local UI = VH.UI

local registerModule = UI.registerModule

local saveConfig = VH.Config.saveConfig

registerModule("Player", "Anti-AFK", 160, 50, true, S.AntiAFK, function(v) S.AntiAFK = v; saveConfig() end)

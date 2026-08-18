local VH = _G.VoidHub
local State = VH.State
local S = State.S
local UI = VH.UI

local registerModule = UI.registerModule

local saveConfig = VH.Config.saveConfig

registerModule("World", "Anti Fling", 580, 50, true, S.AntiFling, function(v) S.AntiFling = v; saveConfig() end)

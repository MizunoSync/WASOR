local VH = _G.VoidHub
local Services = VH.Services
local State = VH.State
local S = State.S
local UI = VH.UI

local RunService = Services.RunService

local registerModule = UI.registerModule

local saveConfig = VH.Config.saveConfig

registerModule("Render", "No 3D Rendering", 440, 50, true, S.No3DRender, function(v) S.No3DRender = v; pcall(function() RunService:Set3dRenderingEnabled(not v) end); saveConfig() end)

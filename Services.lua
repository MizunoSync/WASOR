local VH = _G.VoidHub
local Services = {}

Services.Players            = game:GetService("Players")
Services.RunService         = game:GetService("RunService")
Services.UserInputService   = game:GetService("UserInputService")
Services.HttpService        = game:GetService("HttpService")
Services.TeleportService    = game:GetService("TeleportService")
Services.Workspace          = game:GetService("Workspace")
Services.CoreGui            = game:GetService("CoreGui")
Services.MarketplaceService = game:GetService("MarketplaceService")
Services.Lighting           = game:GetService("Lighting")
Services.VirtualUser        = game:GetService("VirtualUser")
Services.TweenService       = game:GetService("TweenService")
Services.PathfindingService = game:GetService("PathfindingService")

Services.LP                 = Services.Players.LocalPlayer
Services.Mouse              = Services.LP:GetMouse()
Services.Camera             = Services.Workspace.CurrentCamera

VH.Services = Services
return Services

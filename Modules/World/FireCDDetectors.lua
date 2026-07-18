local VH = _G.VoidHub
local Utils = VH.Utils
local UI = VH.UI

local notify = Utils.notify
local registerModule = UI.registerModule

registerModule("World", "Fire CD Detectors", 580, 50, false, false, function()
    local count = 0
    for _, obj in ipairs(Workspace:GetDescendants()) do if obj:IsA("ClickDetector") then pcall(function() fireclickdetector(obj); count = count + 1 end) end end
    notify(string.format("Fired %d ClickDetectors!", count), Color3.fromRGB(50, 195, 75))
end)

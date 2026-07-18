local VH = _G.VoidHub
local Utils = VH.Utils
local UI = VH.UI

local notify = Utils.notify
local registerModule = UI.registerModule

registerModule("World", "Fire All Prompts", 580, 50, false, false, function()
    local count = 0
    for _, p in ipairs(Workspace:GetDescendants()) do if p:IsA("ProximityPrompt") then fireproximityprompt(p); count = count + 1 end end
    notify(string.format("Fired %d Proximity Prompts!", count), Color3.fromRGB(50, 195, 75))
end)

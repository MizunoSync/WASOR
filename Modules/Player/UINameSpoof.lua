local VH = _G.VoidHub
local Services = VH.Services
local State = VH.State
local S = State.S
local UI = VH.UI

local LP = Services.LP

local registerModule = UI.registerModule

local addTextboxOption = UI.addTextboxOption

local saveConfig = VH.Config.saveConfig

registerModule("Player", "UI Name Spoof", 160, 50, true, S.RandomizeUIText, function(v)
    S.RandomizeUIText = v
    local function clearHooks() for obj, data in pairs(S.UISpoofObjects) do if data.Conn then data.Conn:Disconnect() end; if data.DestConn then data.DestConn:Disconnect() end end; S.UISpoofObjects = {} end
    if v then
        S.SessionSpoofName = "Guest_" .. math.random(1000, 9999)
        local function hookObject(obj)
            if S.UISpoofObjects[obj] then return end
            if (obj:IsA("TextLabel") or obj:IsA("TextButton")) then
                local txt = obj.Text; local lowerText = string.lower(txt)
                if string.find(lowerText, string.lower(LP.Name), 1, true) or string.find(lowerText, string.lower(LP.DisplayName), 1, true) then
                    local data = {}
                    data.Conn = obj:GetPropertyChangedSignal("Text"):Connect(function()
                        if not obj or not obj.Parent then if data.Conn then data.Conn:Disconnect() end; if data.DestConn then data.DestConn:Disconnect() end; S.UISpoofObjects[obj] = nil; return end
                        processUISpoofText(obj)
                    end)
                    data.DestConn = obj.AncestryChanged:Connect(function(_, parent) if not parent then if data.Conn then data.Conn:Disconnect() end; if data.DestConn then data.DestConn:Disconnect() end; S.UISpoofObjects[obj] = nil end end)
                    S.UISpoofObjects[obj] = data; processUISpoofText(obj)
                end
            end
        end
        local pg = LP:WaitForChild("PlayerGui")
        for _, obj in ipairs(pg:GetDescendants()) do hookObject(obj) end
        local addedConn = pg.DescendantAdded:Connect(hookObject); table.insert(S.Connections, addedConn)
    else clearHooks() end
    saveConfig()
end, function(drawer)
    addTextboxOption(drawer, "Custom Spoof Text (Blank for Guest)", S.CustomUIText, function(txt)
        S.CustomUIText = txt
        for obj, _ in pairs(S.UISpoofObjects) do if obj and obj.Parent then processUISpoofText(obj) end end
        saveConfig()
    end)
end, false)

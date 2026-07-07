local VH = _G.VoidHub
local Cleanup = {}

local Services = VH.Services
local State = VH.State

Cleanup.destroyESP = function(p)
    local S = State.S
    local pool = S.ESPPool[p]
    if pool then
        pcall(function() pool.boxOutline.Visible = false; pool.boxOutline:Remove() end)
        pcall(function() pool.boxFill.Visible = false; pool.boxFill:Remove() end)
        pcall(function() pool.tracer.Visible = false; pool.tracer:Remove() end)
        pcall(function() pool.nameTag.Visible = false; pool.nameTag:Remove() end)
        pcall(function() pool.healthText.Visible = false; pool.healthText:Remove() end)
        pcall(function() pool.distText.Visible = false; pool.distText:Remove() end)
        pcall(function() pool.healthBarOutline.Visible = false; pool.healthBarOutline:Remove() end)
        pcall(function() pool.healthBarFill.Visible = false; pool.healthBarFill:Remove() end)
        if pool.skeleton then
            for _, line in ipairs(pool.skeleton) do pcall(function() line.Visible = false; line:Remove() end) end
        end
        S.ESPPool[p] = nil
    end
end

Cleanup.cleanupAll = function()
    local S = State.S
    pcall(function()
        local old = Services.CoreGui:FindFirstChild("MeteorRobloxGUI")
        if old then old:Destroy() end
        local oldChat = Services.CoreGui:FindFirstChild("DiscordNetworkHub")
        if oldChat then oldChat:Destroy() end
        local pg = Services.LP:FindFirstChild("PlayerGui")
        if pg then 
            local oldPg = pg:FindFirstChild("MeteorRobloxGUI"); if oldPg then oldPg:Destroy() end
            local oldChatPg = pg:FindFirstChild("DiscordNetworkHub"); if oldChatPg then oldChatPg:Destroy() end
        end
        if State.clearNetworkTags then pcall(State.clearNetworkTags) end
        State.networkTagsRunning = false
    end)
    
    for _, c in ipairs(S.Connections) do pcall(function() c:Disconnect() end) end
    S.Connections = {}
    
    if S.GodModeConn then pcall(function() S.GodModeConn:Disconnect() end) S.GodModeConn = nil end
    if S.TallRunningConn then pcall(function() S.TallRunningConn:Disconnect() end) S.TallRunningConn = nil end
    if S.SpoofConn then pcall(function() S.SpoofConn:Disconnect() end) S.SpoofConn = nil end
    
    for p, conn in pairs(S.ChatConnections) do pcall(function() conn:Disconnect() end) end
    S.ChatConnections = {}
    
    for p, _ in pairs(S.ESPPool) do Cleanup.destroyESP(p) end
    for p, bill in pairs(S.OverheadPool) do pcall(function() bill:Destroy() end) end
    S.OverheadPool = {}
    
    if S.AirWalkPlat then pcall(function() S.AirWalkPlat:Destroy() end) S.AirWalkPlat = nil end
    if S.GhostDummy then pcall(function() S.GhostDummy:Destroy() end) S.GhostDummy = nil end
    if S.FloatBody then pcall(function() S.FloatBody:Destroy() end) S.FloatBody = nil end
    if S.WaterPlat then pcall(function() S.WaterPlat:Destroy() end) S.WaterPlat = nil end
    
    if State.playerCards then
        for p, item in pairs(State.playerCards) do
            pcall(function() if item.HPConn then item.HPConn:Disconnect() end; if item.CharConn then item.CharConn:Disconnect() end end)
        end
        State.playerCards = {}
    end
    
    pcall(function()
        if State.isFreecam then
            State.isFreecam = false
            local char = Services.LP.Character
            local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char.PrimaryPart)
            if hrp then hrp.Anchored = false end
            if State.freecamConnection then State.freecamConnection:Disconnect() State.freecamConnection = nil end
            if State.freecamInputConn then State.freecamInputConn:Disconnect() State.freecamInputConn = nil end
            if State.freecamInputBeganConn then State.freecamInputBeganConn:Disconnect() State.freecamInputBeganConn = nil end
            if State.freecamInputEndedConn then State.freecamInputEndedConn:Disconnect() State.freecamInputEndedConn = nil end
            Services.UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            Services.Camera.CameraType = Enum.CameraType.Custom
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then Services.Camera.CameraSubject = hum end
        end
    end)
    
    pcall(function()
        if Services.LP.Character then
            VH.Utils.revertTallAnimations(Services.LP.Character)
            VH.Utils.disableGodMode()
        end
    end)
    
    pcall(function() VH.Utils.toggleMapXray(false); VH.Utils.toggleClearVision(false) end)
    pcall(function() Services.Lighting.Ambient = State.originalAmbient; Services.Lighting.OutdoorAmbient = State.originalOutdoor end)
    pcall(function() if getgenv().VoidFOVCircle then getgenv().VoidFOVCircle:Remove(); getgenv().VoidFOVCircle = nil end end)
end

VH.Cleanup = Cleanup
return Cleanup

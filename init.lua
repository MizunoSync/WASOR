
_G.VoidHub = {}

local VH = _G.VoidHub


local CoreModules = {
    "Core/Services",
    "Core/State",
    "Core/Utils",
    "Core/Config",
    "Core/Logger",
    "Core/Cleanup",
    "Core/UI"
}


local function runFile(path)
    if readfile and isfile and loadstring then
        local fullPath = "WASOR/" .. path .. ".lua"
        if isfile(fullPath) then
            local code = readfile(fullPath)
            local func, err = loadstring(code, fullPath)
            if func then
                return func()
            else
                warn("[WASOR Loader] Error parsing " .. fullPath .. ": " .. tostring(err))
            end
        else
            warn("[WASOR Loader] File not found: " .. fullPath)
        end
    else
        
        local target = script
        for segment in path:gmatch("[^/]+") do
            target = target:FindFirstChild(segment)
            if not target then break end
        end
        if target and target:IsA("ModuleScript") then
            return require(target)
        end
    end
end


for _, modulePath in ipairs(CoreModules) do
    runFile(modulePath)
end


VH.UI.InitializeUI()


local Modules = {
    
    "Modules/Combat/GodMode",
    "Modules/Combat/KillAura",
    "Modules/Combat/SilentAim",
    "Modules/Combat/NoRecoil",
    "Modules/Combat/TouchAura",
    "Modules/Combat/AutoClicker",
    "Modules/Combat/Aimbot",
    "Modules/Combat/Aimlock",
    "Modules/Combat/Triggerbot",
    "Modules/Combat/FlingPlayer",
    "Modules/Combat/FlingAll",

    
    "Modules/Player/ResetCharacter",
    "Modules/Player/InstantRespawn",
    "Modules/Player/NametagCustomizer",
    "Modules/Player/UINameSpoof",
    "Modules/Player/CustomIdleAnimation",
    "Modules/Player/ForceShiftLock",
    "Modules/Player/UnlockMaxZoom",
    "Modules/Player/GiveBTools",
    "Modules/Player/ClickDelete",
    "Modules/Player/ClickTeleport",
    "Modules/Player/AntiAFK",
    "Modules/Player/AutoRejoin",
    "Modules/Player/SpectateFreecam",

    
    "Modules/Movement/SpeedModification",
    "Modules/Movement/SprintSpeedBoost",
    "Modules/Movement/JumpHackStrength",
    "Modules/Movement/Climb",
    "Modules/Movement/WallRun",
    "Modules/Movement/FlyMode",
    "Modules/Movement/FlyBypass",
    "Modules/Movement/InfiniteJump",
    "Modules/Movement/AutoBunnyhop",
    "Modules/Movement/AutoWalktoMouse",
    "Modules/Movement/AirWalkPlatform",
    "Modules/Movement/NoClipPasses",
    "Modules/Movement/BlinkTeleport",
    "Modules/Movement/GhostStateMode",
    "Modules/Movement/FloatMode",
    "Modules/Movement/WaterWalk",
    "Modules/Movement/TallAnimations",
    "Modules/Movement/PlayerSpin",
    "Modules/Movement/GravityModifier",
    "Modules/Movement/AntiAnchor",
    "Modules/Movement/AntiSit",

    
    "Modules/Render/ESPBoxOutlines",
    "Modules/Render/ESPTracerLines",
    "Modules/Render/ShowPlayerNames",
    "Modules/Render/ShowHealthText",
    "Modules/Render/ShowDistanceText",
    "Modules/Render/DistanceBasedESP",
    "Modules/Render/SkeletonESP",
    "Modules/Render/Chams",
    "Modules/Render/SkipTeammates",
    "Modules/Render/HeadsUpOverheads",
    "Modules/Render/NetworkUserTags",
    "Modules/Render/MapXRay",
    "Modules/Render/ClearVision",
    "Modules/Render/No3DRendering",
    "Modules/Render/LagReducer",
    "Modules/Render/FullBrightMode",
    "Modules/Render/TimeofDayCycle",
    "Modules/Render/FieldofView",

    
    "Modules/World/InstantPrompts",
    "Modules/World/FireAllPrompts",
    "Modules/World/FireCDDetectors",
    "Modules/World/AutoTriggerPrompts",
    "Modules/World/ToolMagnet",
    "Modules/World/AutoJumpEdges",
    "Modules/World/AntiFlingSystem",
    "Modules/World/SaveCurrentLocation",
    "Modules/World/WarptoSavedLocation",
    "Modules/World/DestroyKillbricks",
    "Modules/World/DestroySeats",
    "Modules/World/AntiVoidNet",

    
    "Modules/Misc/ServerControls",
    "Modules/Misc/FavoritesManager",
    "Modules/Misc/OnlineFriends",
    "Modules/Misc/ChatLogger",
    "Modules/Misc/ExternalScriptsHub",
    "Modules/Misc/UNCcomplianceAudits",
    "Modules/Misc/ConsoleLogViewer",
    "Modules/Misc/SettingsKeybinds",
    "Modules/Misc/NetworkChatHub"
}


for _, modulePath in ipairs(Modules) do
    runFile(modulePath)
end


runFile("Core/Runtime")

print("[WASOR] Loader: FileBuild")

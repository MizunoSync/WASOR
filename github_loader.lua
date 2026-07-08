_G.VoidHub = {}

local GITHUB_USERNAME = "MizunoSync"
local GITHUB_REPO = "WASOR"
local GITHUB_BRANCH = "main"

local BASE_URL = string.format("https://raw.githubusercontent.com/%s/%s/%s/", GITHUB_USERNAME, GITHUB_REPO, GITHUB_BRANCH)

local CoreModules = {
    "Core/Services",
    "Core/State",
    "Core/Utils",
    "Core/Config",
    "Core/Logger",
    "Core/Cleanup",
    "Core/UI"
}

local Modules = {
    -- Combat
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

    -- Player
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

    -- Movement
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

    -- Render
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

    -- World
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

    -- Misc
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

local function runFile(path)
    local url = BASE_URL .. path .. ".lua?t=" .. tostring(os.time())
    local success, content = pcall(game.HttpGet, game, url)
    if success and content then
        local func, err = loadstring(content, path)
        if func then
            local runSuccess, runErr = pcall(func)
            if not runSuccess then
                warn("[VoidHub Loader] Runtime error in " .. path .. ": " .. tostring(runErr))
            end
        else
            warn("[VoidHub Loader] Parse error in " .. path .. ": " .. tostring(err))
        end
    else
        warn("[VoidHub Loader] Failed to fetch " .. url)
    end
end

for _, modulePath in ipairs(CoreModules) do
    runFile(modulePath)
end

_G.VoidHub.UI.InitializeUI()

for _, modulePath in ipairs(Modules) do
    runFile(modulePath)
end

runFile("Core/Runtime")

print("Misan nessa porra.")

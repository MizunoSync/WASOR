if _G.VoidHub and type(_G.VoidHub) == "table" and _G.VoidHub.Cleanup and _G.VoidHub.Cleanup.cleanupAll then
    pcall(_G.VoidHub.Cleanup.cleanupAll)
end

_G.VoidHub = {}
--- xz

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

local hasFileSystem = isfile and readfile and writefile and makefolder

local function createFolders()
    pcall(makefolder, "WASOR_cache")
    pcall(makefolder, "WASOR_cache/Core")
    pcall(makefolder, "WASOR_cache/Modules")
    pcall(makefolder, "WASOR_cache/Modules/Combat")
    pcall(makefolder, "WASOR_cache/Modules/Player")
    pcall(makefolder, "WASOR_cache/Modules/Movement")
    pcall(makefolder, "WASOR_cache/Modules/Render")
    pcall(makefolder, "WASOR_cache/Modules/World")
    pcall(makefolder, "WASOR_cache/Modules/Misc")
end

local latestSHA = nil
if hasFileSystem then
    local success, response = pcall(game.HttpGet, game, string.format("https://api.github.com/repos/%s/%s/commits/%s", GITHUB_USERNAME, GITHUB_REPO, GITHUB_BRANCH))
    if success and response then
        latestSHA = response:match('"sha"%s*:%s*"([^"]+)"')
    end
end

local useCache = false
if hasFileSystem and latestSHA then
    local cacheSHAPath = "WASOR_cache/commit_sha.txt"
    if isfile(cacheSHAPath) then
        local localSHA = readfile(cacheSHAPath)
        if localSHA == latestSHA then
            useCache = true
        end
    end
end

if useCache then
    print("[WASOR Loader] Loading WASOR from local cache (Commit: " .. latestSHA:sub(1, 7) .. ")")
else
    if hasFileSystem and latestSHA then
        print("[WASOR Loader] Changes detected or first run. Downloading WASOR from GitHub...")
        createFolders()
    else
        print("[WASOR Loader] Running in fallback network mode.")
    end
end

local downloadFailed = false

local function runFile(path)
    local content = nil
    local cachePath = "WASOR_cache/" .. path .. ".lua"
    
    if useCache and isfile(cachePath) then
        content = readfile(cachePath)
    else
        local url = BASE_URL .. path .. ".lua?t=" .. tostring(os.time())
        local success, result = pcall(game.HttpGet, game, url)
        if success and result then
            content = result
            if hasFileSystem and latestSHA then
                pcall(writefile, cachePath, result)
            end
        else
            downloadFailed = true
        end
    end
    
    if content then
        local func, err = loadstring(content, path)
        if func then
            local runSuccess, runErr = pcall(func)
            if not runSuccess then
                warn("[WASOR Loader] Runtime error in " .. path .. ": " .. tostring(runErr))
            end
        else
            warn("[WASOR Loader] Parse error in " .. path .. ": " .. tostring(err))
        end
    else
        warn("[WASOR Loader] Failed to load " .. path)
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

if not useCache and hasFileSystem and latestSHA and not downloadFailed then
    pcall(writefile, "WASOR_cache/commit_sha.txt", latestSHA)
    print("[WASOR Loader] All files downloaded. Cache updated to commit: " .. latestSHA:sub(1, 7))
end

print("[WASOR] Loaded")

local VH = _G.VoidHub
local Services = VH.Services
local State = VH.State
local S = State.S
local UI = VH.UI

local LP = Services.LP

local registerModule = UI.registerModule

local saveConfig = VH.Config.saveConfig

local REMOTE_URL = "https://raw.githubusercontent.com/VenezzaX/detection.lua/refs/heads/main/sigma.lua"
local CACHE_FILE = "chatroom_cache.lua"

local function tryLoadLocalOverride()
    if not (isfile and readfile and loadstring) then
        return false
    end

    local overrideCandidates = {
        "CompatibleScripts/Chathub.lua",
        "WASOR/CompatibleScripts/Chathub.lua",
        "WASORCLASSIC/CompatibleScripts/Chathub.lua",
        "Chathub.lua",
        "WASOR/Chathub.lua",
        "WASORCLASSIC/Chathub.lua"
    }

    for _, path in ipairs(overrideCandidates) do
        if isfile(path) then
            local code = readfile(path)
            if code and #code > 100 then
                local fn = loadstring(code, path)
                if fn then
                    task.spawn(fn)
                    return true
                end
            end
        end
    end

    return false
end

local function tryLoadCachedFallback()
    if not (isfile and readfile and loadstring) then
        return false
    end

    if isfile(CACHE_FILE) then
        local cachedCode = readfile(CACHE_FILE)
        if cachedCode and #cachedCode > 100 then
            local fn = loadstring(cachedCode, CACHE_FILE)
            if fn then
                task.spawn(fn)
                return true
            end
        end
    end

    return false
end

local function launchChatHub(forceReload)
    if forceReload then
        pcall(function()
            if _G.ChatHub_Cleanup then
                _G.ChatHub_Cleanup()
            end
        end)
        _G.ChatHub_Loaded = nil
        _G.ChatHub_Running = nil
    end

    if _G.ChatHub_Loaded and _G.ChatHub_SetVisible then
        _G.ChatHub_SetVisible(true)
        return
    end

    if tryLoadLocalOverride() then
        return
    end

    task.spawn(function()
        local freshUrl = REMOTE_URL .. "?t=" .. tostring(os.time())
        local success, remoteCode = pcall(function()
            return game:HttpGet(freshUrl, true)
        end)

        if success and remoteCode and #remoteCode > 100 then
            pcall(function()
                if writefile then
                    writefile(CACHE_FILE, remoteCode)
                end
            end)
            local fn = loadstring(remoteCode, "sigma.lua")
            if fn then
                task.spawn(fn)
                return
            end
        end

        tryLoadCachedFallback()
    end)
end

VH.launchNetworkChatHub = launchChatHub

registerModule("Misc", "Network Chat Hub", 720, 50, true, S.NetworkChat, function(v)
    S.NetworkChat = v
    if v then
        if _G.ChatHub_Loaded and _G.ChatHub_SetVisible then
            _G.ChatHub_SetVisible(true)
        else
            task.spawn(function()
                pcall(launchChatHub, false)
            end)
        end
    else
        if _G.ChatHub_SetVisible then
            _G.ChatHub_SetVisible(false)
        else
            local CoreGui = game:GetService("CoreGui")
            local oldChat = CoreGui:FindFirstChild("DiscordNetworkHub") or CoreGui:FindFirstChild("ChatRoom")
            if oldChat then
                local mw = oldChat:FindFirstChild("MainWindow")
                if mw then mw.Visible = false else oldChat:Destroy() end
            end
            local pg = LP:WaitForChild("PlayerGui", 2)
            if pg then
                local oldChatPg = pg:FindFirstChild("DiscordNetworkHub") or pg:FindFirstChild("ChatRoom")
                if oldChatPg then
                    local mw = oldChatPg:FindFirstChild("MainWindow")
                    if mw then mw.Visible = false else oldChatPg:Destroy() end
                end
            end
        end
    end
    saveConfig()
end)

local VH = _G.VoidHub
local State = VH.State
local S = State.S
local Utils = VH.Utils
local UI = VH.UI

local notify = Utils.notify
local registerModule = UI.registerModule

local addToggleOption = UI.addToggleOption
local addTextboxOption = UI.addTextboxOption
local addButtonOption = UI.addButtonOption
local addScrollFeedOption = UI.addScrollFeedOption

local saveConfig = VH.Config.saveConfig

registerModule("Misc", "Chat Logger", 720, 50, false, false, nil, function(drawer)
    local chatFeed = addScrollFeedOption(drawer, 185)
    State.activeChatFeed = chatFeed

    local filter = ""

    local function rebuildChat()
        chatFeed:Clear()
        local history = S.ChatHistory or {}
        local filterLower = filter:lower()

        for _, log in ipairs(history) do
            local matches = true
            if filterLower ~= "" then
                local spk = (log.Speaker or ""):lower()
                local msg = (log.Message or ""):lower()
                matches = spk:find(filterLower, 1, true) or msg:find(filterLower, 1, true)
            end
            if matches then
                local line = string.format("[%s] [%s]: %s", log.Timestamp or "--:--:--", log.Speaker or "Unknown", log.Message or "")
                chatFeed:AddEntry(line, log.Color or Color3.fromRGB(220, 220, 225))
            end
        end
    end

    addTextboxOption(drawer, "Filter Chat Logs", "Search player or message...", function(txt)
        filter = txt or ""
        rebuildChat()
    end)

    addButtonOption(drawer, "Copy Filtered Chat Logs", function()
        local text = ""
        local history = S.ChatHistory or {}
        local filterLower = filter:lower()

        for _, log in ipairs(history) do
            local matches = true
            if filterLower ~= "" then
                local spk = (log.Speaker or ""):lower()
                local msg = (log.Message or ""):lower()
                matches = spk:find(filterLower, 1, true) or msg:find(filterLower, 1, true)
            end
            if matches then
                text = text .. string.format("[%s] [%s]: %s\n", log.Timestamp or "--:--:--", log.Speaker or "Unknown", log.Message or "")
            end
        end

        local write = setclipboard or writeclipboard or toclipboard or print
        local s = pcall(function() write(text) end)
        if s then
            notify("Chat logs copied to clipboard!", Color3.fromRGB(50, 195, 75))
        else
            notify("Clipboard write failed", Color3.fromRGB(218, 38, 38))
        end
    end)

    addButtonOption(drawer, "Clear Chat History", function()
        S.ChatHistory = {}
        chatFeed:Clear()
        notify("Chat history cleared", Color3.fromRGB(240, 200, 50))
    end)

    addToggleOption(drawer, "Toast notifications on chat", S.ToastChatEnabled, function(v)
        S.ToastChatEnabled = v
        saveConfig()
    end)

    rebuildChat()
end, true, 380, 360)

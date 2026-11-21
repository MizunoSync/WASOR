local VH = _G.VoidHub
local State = VH.State
local S = State.S
local Utils = VH.Utils
local UI = VH.UI

local updateLocalNametag = Utils.updateLocalNametag
local registerModule = UI.registerModule

local addToggleOption = UI.addToggleOption
local addTextboxOption = UI.addTextboxOption
local addDropdownOption = UI.addDropdownOption
local addSliderOption = UI.addSliderOption
local addButtonOption = UI.addButtonOption

local saveConfig = VH.Config.saveConfig
local notify = Utils.notify

local colorStyles = {
    "Wasor Theme",
    "Rainbow / Chroma",
    "Gold Luxury",
    "Neon Crimson",
    "Cyan Neon",
    "Emerald Neon",
    "Pure White"
}

registerModule("Player", "Nametag Customizer", 160, 50, true, S.CustomNametag, function(v)
    S.CustomNametag = v
    updateLocalNametag()
    saveConfig()
end, function(drawer)
    addTextboxOption(drawer, "Custom Nametag Name", S.CustomNametagText or "WeAreSkidding", function(txt)
        S.CustomNametagText = txt
        updateLocalNametag()
        saveConfig()
    end)

    addTextboxOption(drawer, "Custom Subtitle / Tag", S.CustomNametagSubText or "[WASOR]", function(txt)
        S.CustomNametagSubText = txt
        updateLocalNametag()
        saveConfig()
    end)

    local curStyleIdx = table.find(colorStyles, S.NametagColorStyle) or 1
    addDropdownOption(drawer, "Nametag Color Style", colorStyles, curStyleIdx, function(idx, opt)
        S.NametagColorStyle = opt
        updateLocalNametag()
        saveConfig()
    end)

    addToggleOption(drawer, "Show Verified Badge Icon", S.NametagShowBadge ~= false, function(v)
        S.NametagShowBadge = v
        updateLocalNametag()
        saveConfig()
    end)

    addToggleOption(drawer, "Show Live Health in Nametag", S.NametagShowHealth or false, function(v)
        S.NametagShowHealth = v
        updateLocalNametag()
        saveConfig()
    end)

    addSliderOption(drawer, "Height Offset (Studs x10)", 15, 60, S.NametagOffsetY or 25, function(v)
        S.NametagOffsetY = v
        updateLocalNametag()
        saveConfig()
    end)

    addSliderOption(drawer, "Nametag Font Size", 14, 34, S.NametagTextSize or 22, function(v)
        S.NametagTextSize = v
        updateLocalNametag()
        saveConfig()
    end)

    addToggleOption(drawer, "Hide Default Roblox Nametag", S.HideDefaultNametag or false, function(v)
        S.HideDefaultNametag = v
        updateLocalNametag()
        saveConfig()
    end)

    addToggleOption(drawer, "Hide Other Players Nametags", S.HideNametags, function(v)
        S.HideNametags = v
        saveConfig()
    end)

    addButtonOption(drawer, "Force Refresh Nametag", function()
        updateLocalNametag()
        notify("Nametag refreshed!", Color3.fromRGB(50, 195, 75))
    end)
end, false)

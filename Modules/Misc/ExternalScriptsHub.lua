local VH = _G.VoidHub
local Utils = VH.Utils
local UI = VH.UI

local notify = Utils.notify
local registerModule = UI.registerModule

local addButtonOption = UI.addButtonOption
local addInfoRowOption = UI.addInfoRowOption

local runExternalScript = Utils.runExternalScript

registerModule("Misc", "ScriptHub", 720, 50, false, false, nil, function(drawer)
    addInfoRowOption(drawer, "Explorers & Hierarchy", "Dex / Vex")
    addButtonOption(drawer, "Load Dex++ Explorer", function()
        runExternalScript("Dex++", "https://github.com/AZYsGithub/DexPlusPlus/releases/latest/download/out.lua")
    end)
    addButtonOption(drawer, "Load Dex Explorer (Injected)", function()
        local s, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
        end)
        if s then
            notify("Dex Explorer loaded successfully!", Color3.fromRGB(50, 195, 75))
        else
            notify("Failed to load Dex: " .. tostring(err), Color3.fromRGB(218, 38, 38))
        end
    end)
    addButtonOption(drawer, "Load Vex Explorer", function()
        runExternalScript("Vex", "https://raw.githubusercontent.com/Vezise/2026/main/Vez/VexExplorer/VEXExplorer.lua")
    end)

    addInfoRowOption(drawer, "Admin & Frameworks", "IY / Cobalt")
    addButtonOption(drawer, "Load Infinite Yield Admin", function()
        local s, err = pcall(function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source', true))()
        end)
        if s then
            notify("Infinite Yield loaded successfully!", Color3.fromRGB(50, 195, 75))
        else
            notify("Failed to load Infinite Yield: " .. tostring(err), Color3.fromRGB(218, 38, 38))
        end
    end)
    addButtonOption(drawer, "Load Cobalt UI Wrapper", function()
        local s, err = pcall(function()
            loadstring(game:HttpGet("https://gitlab.com/upio/cobalt/-/releases/permalink/latest/downloads/Cobalt.luau"))()
        end)
        if s then
            notify("Cobalt UI loaded successfully!", Color3.fromRGB(50, 195, 75))
        else
            notify("Failed to load Cobalt UI: " .. tostring(err), Color3.fromRGB(218, 38, 38))
        end
    end)

    addInfoRowOption(drawer, "Network & Remotes", "Spy / Hydroxide")
    addButtonOption(drawer, "Load SimpleSpy V3 (Remote)", function()
        local s, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/SimpleSpyV3/main.lua"))()
        end)
        if s then
            notify("SimpleSpy V3 loaded successfully!", Color3.fromRGB(50, 195, 75))
        else
            notify("Failed to load SimpleSpy: " .. tostring(err), Color3.fromRGB(218, 38, 38))
        end
    end)
    addButtonOption(drawer, "Load Hydroxide", function()
        runExternalScript("Hydroxide", "https://raw.githubusercontent.com/Upbolt/Hydroxide/revision/init.lua")
    end)
end, true, 320, 270)

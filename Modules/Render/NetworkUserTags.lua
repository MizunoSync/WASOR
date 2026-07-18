local VH = _G.VoidHub
local State = VH.State
local S = State.S
local UI = VH.UI

local registerModule = UI.registerModule

local addToggleOption = UI.addToggleOption

local saveConfig = VH.Config.saveConfig

registerModule("Render", "Network User Tags", 440, 50, true, S.NetworkTags, function(v)
    S.NetworkTags = v
    if UI.networkUsersHUD then UI.networkUsersHUD.Visible = v and S.ShowNetworkUsersHUD end
    if not v then
        if VH.clearNetworkTags then VH.clearNetworkTags() end
    end
    saveConfig()
end, function(drawer)
    addToggleOption(drawer, "Show Network Users List HUD", S.ShowNetworkUsersHUD, function(v)
        S.ShowNetworkUsersHUD = v
        if UI.networkUsersHUD then UI.networkUsersHUD.Visible = S.NetworkTags and v end
        saveConfig()
    end)
end, false)

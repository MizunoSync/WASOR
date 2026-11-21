local VH = _G.VoidHub
local Services = VH.Services
local State = VH.State
local S = State.S
local Utils = VH.Utils
local UI = VH.UI

local HttpService = Services.HttpService
local robloxGet = Utils.robloxGet
local TeleportService = Services.TeleportService

local LP = Services.LP

local notify = Utils.notify
local registerModule = UI.registerModule

local addTextboxOption = UI.addTextboxOption
local addButtonOption = UI.addButtonOption
local addCustomFrameOption = UI.addCustomFrameOption

local saveFavorites = VH.Config.saveFavorites
local loadFavorites = VH.Config.loadFavorites

local activeScroll = nil
local currentFilter = ""

local function rebuildFavorites(scroll, filter)
    if not scroll then return end
    currentFilter = filter or currentFilter or ""
    for _, child in ipairs(scroll:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
    local filterLower = currentFilter:lower()

    for idx, map in ipairs(S.FavoriteMaps or {}) do
        local matches = true
        if filterLower ~= "" then
            matches = (map.name or ""):lower():find(filterLower, 1, true) or tostring(map.id):find(filterLower, 1, true)
        end
        if matches then
            local card = Instance.new("Frame")
            card.Size = UDim2.new(1, -2, 0, 32)
            card.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
            card.BorderSizePixel = 0
            card.Parent = scroll
            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 4)

            local nameL = Instance.new("TextLabel")
            nameL.Text = map.name or ("Place: " .. tostring(map.id))
            nameL.Font = Enum.Font.GothamBold
            nameL.TextSize = 10
            nameL.TextColor3 = Color3.fromRGB(240, 240, 245)
            nameL.BackgroundTransparency = 1
            nameL.Position = UDim2.new(0, 8, 0, 2)
            nameL.Size = UDim2.new(1, -85, 0, 14)
            nameL.TextXAlignment = Enum.TextXAlignment.Left
            nameL.TextTruncate = Enum.TextTruncate.AtEnd
            nameL.Parent = card

            local detailsL = Instance.new("TextLabel")
            detailsL.Text = string.format("ID: %s • %s", tostring(map.id), map.lastPlayed or "Never")
            detailsL.Font = Enum.Font.Gotham
            detailsL.TextSize = 8
            detailsL.TextColor3 = Color3.fromRGB(150, 150, 160)
            detailsL.BackgroundTransparency = 1
            detailsL.Position = UDim2.new(0, 8, 0, 16)
            detailsL.Size = UDim2.new(1, -85, 0, 12)
            detailsL.TextXAlignment = Enum.TextXAlignment.Left
            detailsL.TextTruncate = Enum.TextTruncate.AtEnd
            detailsL.Parent = card

            local jb = Instance.new("TextButton")
            jb.Text = "JOIN"
            jb.Font = Enum.Font.GothamBold
            jb.TextSize = 9
            jb.TextColor3 = Color3.fromRGB(255, 255, 255)
            jb.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
            jb.Size = UDim2.new(0, 44, 0, 20)
            jb.Position = UDim2.new(1, -74, 0.5, -10)
            jb.BorderSizePixel = 0
            jb.Parent = card
            Instance.new("UICorner", jb).CornerRadius = UDim.new(0, 4)
            jb.MouseButton1Click:Connect(function()
                notify("Joining favorite: " .. (map.name or tostring(map.id)), Color3.fromRGB(241, 196, 15))
                map.lastPlayed = os.date("%Y-%m-%d %H:%M")
                saveFavorites()
                rebuildFavorites(scroll, currentFilter)
                task.delay(0.3, function() TeleportService:Teleport(map.id, LP) end)
            end)

            local rb = Instance.new("TextButton")
            rb.Text = "X"
            rb.Font = Enum.Font.GothamBold
            rb.TextSize = 10
            rb.TextColor3 = Color3.fromRGB(240, 70, 70)
            rb.BackgroundColor3 = Color3.fromRGB(38, 38, 44)
            rb.Size = UDim2.new(0, 22, 0, 20)
            rb.Position = UDim2.new(1, -26, 0.5, -10)
            rb.BorderSizePixel = 0
            rb.Parent = card
            Instance.new("UICorner", rb).CornerRadius = UDim.new(0, 4)
            rb.MouseButton1Click:Connect(function()
                table.remove(S.FavoriteMaps, idx)
                saveFavorites()
                rebuildFavorites(scroll, currentFilter)
                notify("Experience removed from favorites", Color3.fromRGB(218, 38, 38))
            end)
        end
    end
end

local function addFavoriteById(pid)
    S.FavoriteMaps = S.FavoriteMaps or {}
    for _, item in ipairs(S.FavoriteMaps) do
        if item.id == pid then
            notify("Already in favorites!", Color3.fromRGB(241, 196, 15))
            return
        end
    end
    notify("Resolving Place ID info (" .. tostring(pid) .. ")...", Color3.fromRGB(241, 196, 15))
    task.spawn(function()
        local gameName = "Place: " .. pid
        local universeId = nil
        pcall(function()
            local res = HttpService:JSONDecode(robloxGet(("https://apis.roblox.com/universes/v1/places/%d/universe"):format(pid)))
            if res and res.universeId then
                universeId = res.universeId
                local resDetails = HttpService:JSONDecode(robloxGet(("https://games.roblox.com/v1/games?universeIds=%d"):format(universeId)))
                if resDetails and resDetails.data and resDetails.data[1] then
                    gameName = resDetails.data[1].name
                end
            end
        end)
        table.insert(S.FavoriteMaps, {
            id = pid,
            universeId = universeId,
            iconUrl = nil,
            name = gameName,
            lastPlayed = "Added: " .. os.date("%m-%d %H:%M")
        })
        saveFavorites()
        if activeScroll then
            rebuildFavorites(activeScroll, currentFilter)
        end
        notify("Saved to Favorites: " .. gameName, Color3.fromRGB(50, 195, 75))
    end)
end

registerModule("Misc", "Favorite games", 720, 50, false, false, nil, function(drawer)
    if loadFavorites then pcall(loadFavorites) end

    addTextboxOption(drawer, "Save Place ID to Favorites", "Place ID...", function(txt)
        local pid = tonumber(txt:match("%d+"))
        if not pid then notify("Enter a valid place ID", Color3.fromRGB(218, 38, 38)); return end
        addFavoriteById(pid)
    end)

    addButtonOption(drawer, "Add Current Game to Favorites", function()
        local curId = game.PlaceId
        if curId and curId > 0 then
            addFavoriteById(curId)
        else
            notify("Current Place ID not available", Color3.fromRGB(218, 38, 38))
        end
    end)

    addButtonOption(drawer, "Refresh Favorites List", function()
        if loadFavorites then pcall(loadFavorites) end
        if activeScroll then rebuildFavorites(activeScroll, currentFilter) end
        notify("Favorites refreshed", Color3.fromRGB(50, 195, 75))
    end)

    local frame = addCustomFrameOption(drawer, 185)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -8, 0, 24)
    box.Position = UDim2.new(0, 4, 0, 2)
    box.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
    box.BorderSizePixel = 0
    box.Font = Enum.Font.GothamMedium
    box.TextSize = 10
    box.TextColor3 = Color3.fromRGB(240, 240, 245)
    box.PlaceholderText = "Search favorites by name or ID..."
    box.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
    box.Text = ""
    box.ClearTextOnFocus = false
    box.Parent = frame
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
    local boxPad = Instance.new("UIPadding", box)
    boxPad.PaddingLeft = UDim.new(0, 8)
    boxPad.PaddingRight = UDim.new(0, 8)

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -8, 1, -30)
    scroll.Position = UDim2.new(0, 4, 0, 28)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 90)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = frame
    activeScroll = scroll

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 3)
    layout.Parent = scroll

    box:GetPropertyChangedSignal("Text"):Connect(function()
        rebuildFavorites(scroll, box.Text)
    end)

    rebuildFavorites(scroll)
end, true, 340, 380)

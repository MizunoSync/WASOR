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
local countLabelRef = nil

local function sanitizeFavorites()
    S.FavoriteMaps = S.FavoriteMaps or {}
    local seen = {}
    local unique = {}
    for _, map in ipairs(S.FavoriteMaps) do
        local pid = tonumber(map.id)
        if pid and not seen[pid] then
            seen[pid] = true
            table.insert(unique, map)
        end
    end
    S.FavoriteMaps = unique
end

local function rebuildFavorites(scroll, filter)
    if not scroll then return end
    currentFilter = filter or currentFilter or ""
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    local filterLower = currentFilter:lower()

    sanitizeFavorites()

    local favs = S.FavoriteMaps or {}
    if countLabelRef then
        countLabelRef.Text = string.format("FAVORITE EXPERIENCES (%d)", #favs)
    end

    if #favs == 0 then
        local empty = Instance.new("TextLabel")
        empty.Size = UDim2.new(1, 0, 0, 36)
        empty.BackgroundTransparency = 1
        empty.Font = Enum.Font.Gotham
        empty.TextSize = 10
        empty.TextColor3 = Color3.fromRGB(130, 130, 140)
        empty.Text = "No favorites saved yet. Add Place ID or current game above!"
        empty.Parent = scroll
        return
    end

    local foundAny = false
    for idx, map in ipairs(favs) do
        local matches = true
        if filterLower ~= "" then
            matches = (map.name or ""):lower():find(filterLower, 1, true) or tostring(map.id):find(filterLower, 1, true)
        end
        if matches then
            foundAny = true
            local card = Instance.new("Frame")
            card.Size = UDim2.new(1, -2, 0, 48)
            card.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
            card.BorderSizePixel = 0
            card.Parent = scroll
            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 5)

            local stroke = Instance.new("UIStroke")
            stroke.Color = Color3.fromRGB(38, 38, 46)
            stroke.Thickness = 1
            stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            stroke.Parent = card

            local gameIcon = Instance.new("ImageLabel")
            gameIcon.Size = UDim2.new(0, 38, 0, 38)
            gameIcon.Position = UDim2.new(0, 5, 0.5, -19)
            gameIcon.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
            gameIcon.BorderSizePixel = 0
            gameIcon.Image = "rbxthumb://type=GameIcon&id=" .. tostring(map.id) .. "&w=150&h=150"
            gameIcon.ScaleType = Enum.ScaleType.Fit
            gameIcon.Parent = card
            Instance.new("UICorner", gameIcon).CornerRadius = UDim.new(0, 4)

            local iconStroke = Instance.new("UIStroke")
            iconStroke.Color = Color3.fromRGB(48, 48, 56)
            iconStroke.Thickness = 1
            iconStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            iconStroke.Parent = gameIcon

            local infoFrame = Instance.new("Frame")
            infoFrame.Size = UDim2.new(1, -150, 1, -4)
            infoFrame.Position = UDim2.new(0, 48, 0, 2)
            infoFrame.BackgroundTransparency = 1
            infoFrame.BorderSizePixel = 0
            infoFrame.Parent = card

            local nameL = Instance.new("TextLabel")
            nameL.Text = map.name or ("Place: " .. tostring(map.id))
            nameL.Font = Enum.Font.GothamBold
            nameL.TextSize = 10
            nameL.TextColor3 = Color3.fromRGB(240, 240, 245)
            nameL.BackgroundTransparency = 1
            nameL.Position = UDim2.new(0, 0, 0, 4)
            nameL.Size = UDim2.new(1, 0, 0, 14)
            nameL.TextXAlignment = Enum.TextXAlignment.Left
            nameL.TextTruncate = Enum.TextTruncate.AtEnd
            nameL.Parent = infoFrame

            local detailsL = Instance.new("TextLabel")
            detailsL.Text = string.format("ID: %s • %s", tostring(map.id), map.lastPlayed or "Never")
            detailsL.Font = Enum.Font.Gotham
            detailsL.TextSize = 8
            detailsL.TextColor3 = Color3.fromRGB(150, 150, 160)
            detailsL.BackgroundTransparency = 1
            detailsL.Position = UDim2.new(0, 0, 0, 20)
            detailsL.Size = UDim2.new(1, 0, 0, 12)
            detailsL.TextXAlignment = Enum.TextXAlignment.Left
            detailsL.TextTruncate = Enum.TextTruncate.AtEnd
            detailsL.Parent = infoFrame

            local jb = Instance.new("TextButton")
            jb.Text = "JOIN"
            jb.Font = Enum.Font.GothamBold
            jb.TextSize = 9
            jb.TextColor3 = Color3.fromRGB(255, 255, 255)
            jb.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
            jb.Size = UDim2.new(0, 42, 0, 22)
            jb.Position = UDim2.new(1, -98, 0.5, -11)
            jb.BorderSizePixel = 0
            jb.Parent = card
            Instance.new("UICorner", jb).CornerRadius = UDim.new(0, 4)

            jb.MouseButton1Click:Connect(function()
                notify("Joining: " .. (map.name or tostring(map.id)), Color3.fromRGB(241, 196, 15))
                map.lastPlayed = os.date("%m-%d %H:%M")
                saveFavorites()
                rebuildFavorites(scroll, currentFilter)
                task.delay(0.3, function() TeleportService:Teleport(map.id, LP) end)
            end)

            local cp = Instance.new("TextButton")
            cp.Text = "ID"
            cp.Font = Enum.Font.GothamBold
            cp.TextSize = 8
            cp.TextColor3 = Color3.fromRGB(200, 200, 210)
            cp.BackgroundColor3 = Color3.fromRGB(36, 36, 44)
            cp.Size = UDim2.new(0, 26, 0, 22)
            cp.Position = UDim2.new(1, -52, 0.5, -11)
            cp.BorderSizePixel = 0
            cp.Parent = card
            Instance.new("UICorner", cp).CornerRadius = UDim.new(0, 4)
            local cpStroke = Instance.new("UIStroke")
            cpStroke.Color = Color3.fromRGB(48, 48, 56)
            cpStroke.Thickness = 1
            cpStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            cpStroke.Parent = cp

            cp.MouseButton1Click:Connect(function()
                if type(setclipboard) == "function" then
                    setclipboard(tostring(map.id))
                    notify("Copied Place ID: " .. tostring(map.id), Color3.fromRGB(46, 204, 113))
                end
            end)

            local rb = Instance.new("TextButton")
            rb.Text = "X"
            rb.Font = Enum.Font.GothamBold
            rb.TextSize = 10
            rb.TextColor3 = Color3.fromRGB(240, 70, 70)
            rb.BackgroundColor3 = Color3.fromRGB(36, 36, 44)
            rb.Size = UDim2.new(0, 22, 0, 22)
            rb.Position = UDim2.new(1, -24, 0.5, -11)
            rb.BorderSizePixel = 0
            rb.Parent = card
            Instance.new("UICorner", rb).CornerRadius = UDim.new(0, 4)
            local rbStroke = Instance.new("UIStroke")
            rbStroke.Color = Color3.fromRGB(48, 48, 56)
            rbStroke.Thickness = 1
            rbStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            rbStroke.Parent = rb

            rb.MouseButton1Click:Connect(function()
                table.remove(S.FavoriteMaps, idx)
                saveFavorites()
                rebuildFavorites(scroll, currentFilter)
                notify("Experience removed from favorites", Color3.fromRGB(218, 38, 38))
            end)
        end
    end

    if not foundAny and filterLower ~= "" then
        local noMatch = Instance.new("TextLabel")
        noMatch.Size = UDim2.new(1, 0, 0, 30)
        noMatch.BackgroundTransparency = 1
        noMatch.Font = Enum.Font.Gotham
        noMatch.TextSize = 10
        noMatch.TextColor3 = Color3.fromRGB(130, 130, 140)
        noMatch.Text = "No favorites match your search."
        noMatch.Parent = scroll
    end
end

local function addFavoriteById(pid)
    pid = tonumber(pid)
    if not pid or pid <= 0 then
        notify("Invalid Place ID!", Color3.fromRGB(218, 38, 38))
        return
    end

    S.FavoriteMaps = S.FavoriteMaps or {}
    for _, item in ipairs(S.FavoriteMaps) do
        if tonumber(item.id) == pid then
            notify("Already in favorites! (Only 1 save allowed)", Color3.fromRGB(241, 196, 15))
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

        for _, item in ipairs(S.FavoriteMaps) do
            if tonumber(item.id) == pid or (universeId and item.universeId == universeId) then
                notify("Already in favorites! (Only 1 save allowed)", Color3.fromRGB(241, 196, 15))
                return
            end
        end

        table.insert(S.FavoriteMaps, {
            id = pid,
            universeId = universeId,
            iconUrl = "rbxthumb://type=GameIcon&id=" .. tostring(pid) .. "&w=150&h=150",
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
    sanitizeFavorites()

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
        sanitizeFavorites()
        if activeScroll then rebuildFavorites(activeScroll, currentFilter) end
        notify("Favorites refreshed", Color3.fromRGB(50, 195, 75))
    end)

    local frame = addCustomFrameOption(drawer, 220)

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
    local boxStroke = Instance.new("UIStroke")
    boxStroke.Color = Color3.fromRGB(38, 38, 46)
    boxStroke.Thickness = 1
    boxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    boxStroke.Parent = box
    local boxPad = Instance.new("UIPadding", box)
    boxPad.PaddingLeft = UDim.new(0, 8)
    boxPad.PaddingRight = UDim.new(0, 8)

    local countLabel = Instance.new("TextLabel")
    countLabel.Size = UDim2.new(1, -8, 0, 16)
    countLabel.Position = UDim2.new(0, 4, 0, 28)
    countLabel.BackgroundTransparency = 1
    countLabel.Font = Enum.Font.GothamBold
    countLabel.TextSize = 10
    countLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
    countLabel.TextXAlignment = Enum.TextXAlignment.Left
    countLabel.Text = "FAVORITE EXPERIENCES (0)"
    countLabel.Parent = frame
    countLabelRef = countLabel

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -8, 1, -48)
    scroll.Position = UDim2.new(0, 4, 0, 46)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 90)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = frame
    activeScroll = scroll

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scroll

    box:GetPropertyChangedSignal("Text"):Connect(function()
        rebuildFavorites(scroll, box.Text)
    end)

    rebuildFavorites(scroll)
end, true, 340, 400)

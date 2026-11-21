local VH = _G.VoidHub
local Services = VH.Services
local State = VH.State
local Utils = VH.Utils
local UI = VH.UI

local LP = Services.LP
local TeleportService = Services.TeleportService
local TweenService = Services.TweenService
local themeHeaders = UI.themeHeaders

local notify = Utils.notify
local registerModule = UI.registerModule
local addCustomFrameOption = UI.addCustomFrameOption

local activeScroll = nil
local currentFilter = ""
local countHeaderLabel = nil

local function rebuildFriends(scroll, filter)
    if not scroll then return end
    currentFilter = filter or currentFilter or ""
    local filterLower = currentFilter:lower()

    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    local loadingLabel = Instance.new("TextLabel")
    loadingLabel.Size = UDim2.new(1, 0, 0, 24)
    loadingLabel.BackgroundTransparency = 1
    loadingLabel.Font = Enum.Font.GothamMedium
    loadingLabel.TextSize = 10
    loadingLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
    loadingLabel.Text = "Querying online friends..."
    loadingLabel.Parent = scroll

    task.spawn(function()
        local ok, onlineFriends = pcall(function()
            return LP:GetFriendsOnline(200)
        end)

        if not ok or not onlineFriends then
            loadingLabel.Text = "Failed to query friends."
            loadingLabel.TextColor3 = Color3.fromRGB(218, 38, 38)
            if countHeaderLabel then
                countHeaderLabel.Text = "ONLINE FRIENDS (0)"
            end
            return
        end

        local filteredList = {}
        for _, item in ipairs(onlineFriends) do
            local dName = item.DisplayName or item.UserName or ""
            local uName = item.UserName or ""
            if filterLower == "" or dName:lower():find(filterLower, 1, true) or uName:lower():find(filterLower, 1, true) then
                table.insert(filteredList, item)
            end
        end

        if countHeaderLabel then
            countHeaderLabel.Text = string.format("ONLINE FRIENDS (%d)", #onlineFriends)
        end

        loadingLabel:Destroy()

        if #filteredList == 0 then
            local empty = Instance.new("TextLabel")
            empty.Size = UDim2.new(1, 0, 0, 30)
            empty.BackgroundTransparency = 1
            empty.Font = Enum.Font.Gotham
            empty.TextSize = 10
            empty.TextColor3 = Color3.fromRGB(130, 130, 140)
            empty.Text = (filterLower ~= "") and "No friends match search." or "No friends are currently online."
            empty.Parent = scroll
            return
        end

        for _, item in ipairs(filteredList) do
            local card = Instance.new("Frame")
            card.Size = UDim2.new(1, -4, 0, 44)
            card.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
            card.BorderSizePixel = 0
            card.Parent = scroll
            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 5)

            local stroke = Instance.new("UIStroke")
            stroke.Color = Color3.fromRGB(38, 38, 46)
            stroke.Thickness = 1
            stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            stroke.Parent = card

            local avatar = Instance.new("ImageLabel")
            avatar.Size = UDim2.new(0, 34, 0, 34)
            avatar.Position = UDim2.new(0, 5, 0.5, -17)
            avatar.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
            avatar.BorderSizePixel = 0
            avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(item.VisitorId) .. "&w=150&h=150"
            avatar.ScaleType = Enum.ScaleType.Fit
            avatar.Parent = card
            Instance.new("UICorner", avatar).CornerRadius = UDim.new(0, 4)

            local avStroke = Instance.new("UIStroke")
            avStroke.Color = Color3.fromRGB(48, 48, 56)
            avStroke.Thickness = 1
            avStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            avStroke.Parent = avatar

            local infoContainer = Instance.new("Frame")
            infoContainer.Size = UDim2.new(1, -120, 1, -4)
            infoContainer.Position = UDim2.new(0, 44, 0, 2)
            infoContainer.BackgroundTransparency = 1
            infoContainer.BorderSizePixel = 0
            infoContainer.Parent = card

            local nameL = Instance.new("TextLabel")
            nameL.Size = UDim2.new(1, 0, 0, 14)
            nameL.Position = UDim2.new(0, 0, 0, 2)
            nameL.BackgroundTransparency = 1
            nameL.Font = Enum.Font.GothamBold
            nameL.Text = item.DisplayName or item.UserName
            nameL.TextSize = 11
            nameL.TextColor3 = Color3.fromRGB(240, 240, 245)
            nameL.TextXAlignment = Enum.TextXAlignment.Left
            nameL.TextTruncate = Enum.TextTruncate.AtEnd
            nameL.Parent = infoContainer

            local userL = Instance.new("TextLabel")
            userL.Size = UDim2.new(1, 0, 0, 12)
            userL.Position = UDim2.new(0, 0, 0, 15)
            userL.BackgroundTransparency = 1
            userL.Font = Enum.Font.Gotham
            userL.Text = "@" .. tostring(item.UserName)
            userL.TextSize = 9
            userL.TextColor3 = Color3.fromRGB(150, 150, 160)
            userL.TextXAlignment = Enum.TextXAlignment.Left
            userL.TextTruncate = Enum.TextTruncate.AtEnd
            userL.Parent = infoContainer

            local isInGame = false
            local statusText = "Online (Web)"
            local statusColor = Color3.fromRGB(0, 200, 255)

            if item.LocationType == 1 or item.LocationType == 4 or item.LocationType == 5 or (item.GameId and item.GameId ~= "") then
                if item.PlaceId and item.PlaceId > 0 then
                    isInGame = true
                    statusText = "Playing: " .. (item.LastLocation or "In-game")
                    statusColor = Color3.fromRGB(46, 204, 113)
                end
            elseif item.LocationType == 3 then
                statusText = "In Roblox Studio"
                statusColor = Color3.fromRGB(241, 196, 15)
            end

            local statusL = Instance.new("TextLabel")
            statusL.Size = UDim2.new(1, 0, 0, 11)
            statusL.Position = UDim2.new(0, 0, 0, 27)
            statusL.BackgroundTransparency = 1
            statusL.Font = Enum.Font.GothamMedium
            statusL.Text = statusText
            statusL.TextSize = 8
            statusL.TextColor3 = statusColor
            statusL.TextXAlignment = Enum.TextXAlignment.Left
            statusL.TextTruncate = Enum.TextTruncate.AtEnd
            statusL.Parent = infoContainer

            if isInGame then
                local joinBtn = Instance.new("TextButton")
                joinBtn.Size = UDim2.new(0, 38, 0, 22)
                joinBtn.Position = UDim2.new(1, -72, 0.5, -11)
                joinBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
                joinBtn.BorderSizePixel = 0
                joinBtn.Font = Enum.Font.GothamBold
                joinBtn.TextSize = 9
                joinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                joinBtn.Text = "JOIN"
                joinBtn.Parent = card
                Instance.new("UICorner", joinBtn).CornerRadius = UDim.new(0, 4)

                joinBtn.MouseButton1Click:Connect(function()
                    if item.GameId and item.GameId ~= "" then
                        notify("Connecting to friend...", Color3.fromRGB(46, 204, 113))
                        pcall(function()
                            TeleportService:TeleportToPlaceInstance(item.PlaceId, item.GameId, LP)
                        end)
                    else
                        notify("Warping to friend place...", Color3.fromRGB(46, 204, 113))
                        pcall(function()
                            TeleportService:Teleport(item.PlaceId, LP)
                        end)
                    end
                end)
            end

            local copyBtn = Instance.new("TextButton")
            copyBtn.Size = UDim2.new(0, 28, 0, 22)
            copyBtn.Position = UDim2.new(1, -32, 0.5, -11)
            copyBtn.BackgroundColor3 = Color3.fromRGB(36, 36, 44)
            copyBtn.BorderSizePixel = 0
            copyBtn.Font = Enum.Font.GothamBold
            copyBtn.TextSize = 8
            copyBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
            copyBtn.Text = "ID"
            copyBtn.Parent = card
            Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 4)
            local cpStroke = Instance.new("UIStroke")
            cpStroke.Color = Color3.fromRGB(48, 48, 56)
            cpStroke.Thickness = 1
            cpStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            cpStroke.Parent = copyBtn

            copyBtn.MouseButton1Click:Connect(function()
                if type(setclipboard) == "function" then
                    setclipboard(tostring(item.VisitorId))
                    notify("Copied friend ID: " .. tostring(item.VisitorId), Color3.fromRGB(46, 204, 113))
                end
            end)
        end
    end)
end

registerModule("Misc", "Online Friends", 720, 50, false, false, nil, function(drawer)
    local frame = addCustomFrameOption(drawer, 220)

    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, -8, 0, 26)
    topBar.Position = UDim2.new(0, 4, 0, 2)
    topBar.BackgroundTransparency = 1
    topBar.BorderSizePixel = 0
    topBar.Parent = frame

    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(1, -80, 1, 0)
    searchBox.Position = UDim2.new(0, 0, 0, 0)
    searchBox.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
    searchBox.BorderSizePixel = 0
    searchBox.Font = Enum.Font.GothamMedium
    searchBox.TextSize = 10
    searchBox.TextColor3 = Color3.fromRGB(240, 240, 245)
    searchBox.PlaceholderText = "Search friends..."
    searchBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
    searchBox.Text = ""
    searchBox.ClearTextOnFocus = false
    searchBox.Parent = topBar
    Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 4)
    local sbStroke = Instance.new("UIStroke")
    sbStroke.Color = Color3.fromRGB(38, 38, 46)
    sbStroke.Thickness = 1
    sbStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    sbStroke.Parent = searchBox
    local sbPad = Instance.new("UIPadding", searchBox)
    sbPad.PaddingLeft = UDim.new(0, 8)
    sbPad.PaddingRight = UDim.new(0, 8)

    local refreshBtn = Instance.new("TextButton")
    refreshBtn.Size = UDim2.new(0, 74, 1, 0)
    refreshBtn.Position = UDim2.new(1, -74, 0, 0)
    refreshBtn.BackgroundColor3 = State.currentThemeColor or Color3.fromRGB(141, 47, 196)
    refreshBtn.BorderSizePixel = 0
    refreshBtn.Font = Enum.Font.GothamBold
    refreshBtn.TextSize = 9
    refreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    refreshBtn.Text = "REFRESH"
    refreshBtn.AutoButtonColor = false
    refreshBtn.Parent = topBar
    Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0, 4)
    table.insert(themeHeaders, refreshBtn)

    local countLabel = Instance.new("TextLabel")
    countLabel.Size = UDim2.new(1, -8, 0, 16)
    countLabel.Position = UDim2.new(0, 4, 0, 32)
    countLabel.BackgroundTransparency = 1
    countLabel.Font = Enum.Font.GothamBold
    countLabel.TextSize = 10
    countLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
    countLabel.TextXAlignment = Enum.TextXAlignment.Left
    countLabel.Text = "ONLINE FRIENDS (0)"
    countLabel.Parent = frame
    countHeaderLabel = countLabel

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -8, 1, -52)
    scroll.Position = UDim2.new(0, 4, 0, 50)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = frame
    activeScroll = scroll

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scroll

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        rebuildFriends(scroll, searchBox.Text)
    end)

    refreshBtn.MouseButton1Click:Connect(function()
        rebuildFriends(scroll, searchBox.Text)
        notify("Refreshing online friends...", Color3.fromRGB(141, 47, 196))
    end)

    rebuildFriends(scroll, "")
end, true, 300, 340)

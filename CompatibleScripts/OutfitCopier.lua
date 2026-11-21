local Players = game:GetService("Players")
local AvatarEditorService = game:GetService("AvatarEditorService")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local FILE_NAME = "saved_outfit_data.json"
local MAP_LINK = "https://www.roblox.com/games/12104187655/Untitled-Catalog-Avatar-Creator"

local VH = _G.VoidHub
local isClassic = false
local isWasorModern = false
if VH and VH.UI then
    if (VH.UI.themeColors and VH.UI.themeColors["Studio Classic"]) or (_G.WASOR_ScreenGui and _G.WASOR_ScreenGui:FindFirstChild("StudioTopRibbon")) then
        isClassic = true
    else
        isWasorModern = true
    end
end

local Theme
if isWasorModern then
    local curAccent = (VH.State and VH.State.currentThemeColor) or (VH.UI and VH.UI.themeColors and VH.UI.themeColors["Red"]) or Color3.fromRGB(218, 38, 38)
    Theme = {
        isModern     = true,
        windowBg     = Color3.fromRGB(18, 18, 22),
        titleBg      = Color3.fromRGB(24, 24, 28),
        inputBg      = Color3.fromRGB(24, 24, 28),
        listBg       = Color3.fromRGB(14, 14, 16),
        cardBg       = Color3.fromRGB(26, 26, 30),
        cardHover    = Color3.fromRGB(36, 36, 42),
        border       = Color3.fromRGB(38, 38, 44),
        borderSize   = 0,
        cornerRadius = 8,
        cardCorner   = 6,
        btnCorner    = 4,
        accent       = curAccent,
        purple       = Color3.fromRGB(141, 47, 196),
        green        = Color3.fromRGB(46, 204, 113),
        red          = Color3.fromRGB(218, 38, 38),
        yellow       = Color3.fromRGB(241, 196, 15),
        btnBg        = Color3.fromRGB(32, 32, 36),
        text         = Color3.fromRGB(240, 240, 245),
        textMuted    = Color3.fromRGB(160, 160, 170),
        textDim      = Color3.fromRGB(115, 115, 125),
        font         = Enum.Font.Gotham,
        fontBold     = Enum.Font.GothamBold,
        fontSemibold = Enum.Font.GothamMedium,
    }
else
    Theme = {
        isModern     = false,
        windowBg     = Color3.fromRGB(37, 37, 38),
        titleBg      = Color3.fromRGB(45, 45, 48),
        inputBg      = Color3.fromRGB(26, 26, 28),
        listBg       = Color3.fromRGB(32, 32, 34),
        cardBg       = Color3.fromRGB(44, 44, 48),
        cardHover    = Color3.fromRGB(56, 56, 62),
        border       = Color3.fromRGB(20, 20, 22),
        borderSize   = 1,
        cornerRadius = 0,
        cardCorner   = 0,
        btnCorner    = 0,
        accent       = Color3.fromRGB(0, 122, 204),
        purple       = Color3.fromRGB(160, 120, 220),
        green        = Color3.fromRGB(76, 175, 80),
        red          = Color3.fromRGB(215, 60, 60),
        yellow       = Color3.fromRGB(220, 170, 50),
        btnBg        = Color3.fromRGB(50, 50, 54),
        text         = Color3.fromRGB(225, 225, 228),
        textMuted    = Color3.fromRGB(160, 160, 165),
        textDim      = Color3.fromRGB(115, 115, 120),
        font         = Enum.Font.SourceSans,
        fontBold     = Enum.Font.SourceSansBold,
        fontSemibold = Enum.Font.SourceSansSemibold,
    }
end

local guiParent = (gethui and gethui()) or (pcall(function() return CoreGui.Name end) and CoreGui) or LocalPlayer:WaitForChild("PlayerGui")

if guiParent:FindFirstChild("AvatarItemsHUD") then
    guiParent.AvatarItemsHUD:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AvatarItemsHUD"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = guiParent

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 400, 0, 560)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -280)
MainFrame.BackgroundColor3 = Theme.windowBg
MainFrame.BorderSizePixel = Theme.borderSize
MainFrame.BorderColor3 = Theme.border
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

if Theme.isModern then
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, Theme.cornerRadius)
    UICorner.Parent = MainFrame
    local stroke = Instance.new("UIStroke", MainFrame)
    stroke.Color = Theme.border
    stroke.Thickness = 1
end

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "Saved Outfit Viewer"
Title.TextColor3 = Theme.text
Title.TextSize = 16
Title.Font = Theme.fontBold
Title.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Theme.red
CloseBtn.TextSize = 16
CloseBtn.Font = Theme.fontBold
CloseBtn.Parent = MainFrame

local SearchFrame = Instance.new("Frame")
SearchFrame.Size = UDim2.new(1, -20, 0, 32)
SearchFrame.Position = UDim2.new(0, 10, 0, 45)
SearchFrame.BackgroundTransparency = 1
SearchFrame.Parent = MainFrame

local PlayerInput = Instance.new("TextBox")
PlayerInput.Size = UDim2.new(0.5, -5, 1, 0)
PlayerInput.BackgroundColor3 = Theme.inputBg
PlayerInput.TextColor3 = Theme.text
PlayerInput.PlaceholderColor3 = Theme.textDim
PlayerInput.PlaceholderText = "Enter Username..."
PlayerInput.Text = ""
PlayerInput.Font = Theme.font
PlayerInput.TextSize = 12
PlayerInput.BorderSizePixel = Theme.borderSize
PlayerInput.BorderColor3 = Theme.border
PlayerInput.Parent = SearchFrame
if Theme.isModern then
    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 6)
    InputCorner.Parent = PlayerInput
end

local SearchBtn = Instance.new("TextButton")
SearchBtn.Size = UDim2.new(0.25, -5, 1, 0)
SearchBtn.Position = UDim2.new(0.5, 5, 0, 0)
SearchBtn.BackgroundColor3 = Theme.accent
SearchBtn.Text = "Server"
SearchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBtn.Font = Theme.fontBold
SearchBtn.TextSize = 12
SearchBtn.BorderSizePixel = Theme.borderSize
SearchBtn.BorderColor3 = Theme.border
SearchBtn.Parent = SearchFrame
if Theme.isModern then
    local SearchCorner = Instance.new("UICorner")
    SearchCorner.CornerRadius = UDim.new(0, 6)
    SearchCorner.Parent = SearchBtn
end

local GlobalBtn = Instance.new("TextButton")
GlobalBtn.Size = UDim2.new(0.25, -5, 1, 0)
GlobalBtn.Position = UDim2.new(0.75, 5, 0, 0)
GlobalBtn.BackgroundColor3 = Theme.purple
GlobalBtn.Text = "Global"
GlobalBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GlobalBtn.Font = Theme.fontBold
GlobalBtn.TextSize = 12
GlobalBtn.BorderSizePixel = Theme.borderSize
GlobalBtn.BorderColor3 = Theme.border
GlobalBtn.Parent = SearchFrame
if Theme.isModern then
    local GlobalCorner = Instance.new("UICorner")
    GlobalCorner.CornerRadius = UDim.new(0, 6)
    GlobalCorner.Parent = GlobalBtn
end

local ScrollingList = Instance.new("ScrollingFrame")
ScrollingList.Size = UDim2.new(1, -20, 1, -250)
ScrollingList.Position = UDim2.new(0, 10, 0, 85)
ScrollingList.BackgroundColor3 = Theme.listBg
ScrollingList.BorderSizePixel = Theme.borderSize
ScrollingList.BorderColor3 = Theme.border
ScrollingList.ScrollBarThickness = 4
ScrollingList.Parent = MainFrame
if Theme.isModern then
    Instance.new("UICorner", ScrollingList).CornerRadius = UDim.new(0, 6)
end

local ListLayout = Instance.new("UIListLayout")
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 5)
ListLayout.Parent = ScrollingList

local ListPadding = Instance.new("UIPadding")
ListPadding.PaddingTop = UDim.new(0, 5)
ListPadding.PaddingBottom = UDim.new(0, 5)
ListPadding.PaddingLeft = UDim.new(0, 5)
ListPadding.PaddingRight = UDim.new(0, 5)
ListPadding.Parent = ScrollingList

local BottomFrame = Instance.new("Frame")
BottomFrame.Size = UDim2.new(1, -20, 0, 150)
BottomFrame.Position = UDim2.new(0, 10, 1, -155)
BottomFrame.BackgroundTransparency = 1
BottomFrame.Parent = MainFrame

local BottomLayout = Instance.new("UIListLayout")
BottomLayout.SortOrder = Enum.SortOrder.LayoutOrder
BottomLayout.Padding = UDim.new(0, 8)
BottomLayout.Parent = BottomFrame

local TotalLabel = Instance.new("TextLabel")
TotalLabel.Size = UDim2.new(1, 0, 0, 20)
TotalLabel.BackgroundTransparency = 1
TotalLabel.Text = "Calculating Total Value..."
TotalLabel.TextColor3 = Theme.green
TotalLabel.TextSize = 14
TotalLabel.Font = Theme.fontBold
TotalLabel.TextXAlignment = Enum.TextXAlignment.Center
TotalLabel.Parent = BottomFrame

local function createButton(text, color, parent)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Font = Theme.fontBold
    btn.BorderSizePixel = Theme.borderSize
    btn.BorderColor3 = Theme.border
    btn.Parent = parent
    if Theme.isModern then
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = btn
    end
    return btn
end

local CopyBtn = createButton("Copy IDs (Each on new line)", Theme.btnBg, BottomFrame)
local UpdateBtn = createButton("Save Viewed Outfit to JSON", Theme.btnBg, BottomFrame)
local CopyMapBtn = createButton("Copy Map Link", Theme.accent, BottomFrame)

local currentRenderedIDs = {}

local function extractIDs(description)
    local ids = {}
    local properties = {
        "HatAccessory", "HairAccessory", "FaceAccessory", "NeckAccessory", 
        "ShouldersAccessory", "FrontAccessory", "BackAccessory", "WaistAccessory",
        "Shirt", "Pants", "GraphicTShirt", "Face", "Head", "Torso", "LeftArm", 
        "RightArm", "LeftLeg", "RightLeg", "RunAnimation", "WalkAnimation", 
        "FallAnimation", "JumpAnimation", "IdleAnimation", "SwimAnimation", "ClimbAnimation"
    }

    for _, prop in ipairs(properties) do
        local success, val = pcall(function() return description[prop] end)
        if success then
            if type(val) == "string" and val ~= "" and val ~= "0" then
                for id in string.gmatch(val, "%d+") do
                    table.insert(ids, tonumber(id))
                end
            elseif type(val) == "number" and val > 0 then
                table.insert(ids, val)
            end
        end
    end
    return ids
end

local function getAvatarIDsFromPlayer(p)
    if not p or not p.Character then return {} end
    local humanoid = p.Character:FindFirstChild("Humanoid")
    if not humanoid then return {} end
    return extractIDs(humanoid:GetAppliedDescription())
end

local function getPlayerFromString(str)
    if not str or str == "" then return nil end
    str = string.lower(str)
    for _, p in ipairs(Players:GetPlayers()) do
        if string.lower(string.sub(p.Name, 1, #str)) == str or string.lower(string.sub(p.DisplayName, 1, #str)) == str then
            return p
        end
    end
    return nil
end

local function getSavedIDs()
    if isfile and isfile(FILE_NAME) then
        local success, content = pcall(readfile, FILE_NAME)
        if success then
            local s2, decoded = pcall(HttpService.JSONDecode, HttpService, content)
            if s2 and type(decoded) == "table" then return decoded end
        end
    end
    return nil
end

local function saveIDs(ids)
    if writefile then
        local success, encoded = pcall(HttpService.JSONEncode, HttpService, ids)
        if success then pcall(writefile, FILE_NAME, encoded) end
    end
end

local function renderItems(itemIDs)
    currentRenderedIDs = itemIDs
    
    for _, child in ipairs(ScrollingList:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    if #itemIDs == 0 then
        TotalLabel.Text = "No items found."
        TotalLabel.TextColor3 = Theme.red
        return
    end

    TotalLabel.Text = "Fetching Items via AvatarEditorService..."
    TotalLabel.TextColor3 = Theme.yellow
    local totalValue = 0
    
    task.spawn(function()
        local success, details = pcall(function()
            return AvatarEditorService:GetBatchItemDetails(itemIDs, Enum.AvatarItemType.Asset)
        end)
        
        if success and details then
            for _, info in ipairs(details) do
                local price = info.Price or 0
                local name = info.Name or "Unknown Item"
                local id = info.Id
                totalValue = totalValue + price
                
                local card = Instance.new("Frame")
                card.Size = UDim2.new(1, 0, 0, 50)
                card.BackgroundColor3 = Theme.cardBg
                card.BorderSizePixel = Theme.borderSize
                card.BorderColor3 = Theme.border
                card.Parent = ScrollingList
                
                if Theme.isModern then
                    local cCorner = Instance.new("UICorner")
                    cCorner.CornerRadius = UDim.new(0, Theme.cardCorner)
                    cCorner.Parent = card
                end
                
                local icon = Instance.new("ImageLabel")
                icon.Size = UDim2.new(0, 40, 0, 40)
                icon.Position = UDim2.new(0, 5, 0, 5)
                icon.BackgroundTransparency = 1
                icon.Image = "rbxthumb://type=Asset&id=" .. tostring(id) .. "&w=150&h=150"
                icon.Parent = card
                
                local nameLabel = Instance.new("TextLabel")
                nameLabel.Size = UDim2.new(0.5, -10, 0.5, 0)
                nameLabel.Position = UDim2.new(0, 55, 0, 5)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Text = name
                nameLabel.TextColor3 = Theme.text
                nameLabel.TextSize = 13
                nameLabel.Font = Theme.fontBold
                nameLabel.TextXAlignment = Enum.TextXAlignment.Left
                nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
                nameLabel.Parent = card
                
                local idLabel = Instance.new("TextLabel")
                idLabel.Size = UDim2.new(0.5, -10, 0.5, 0)
                idLabel.Position = UDim2.new(0, 55, 0.5, -5)
                idLabel.BackgroundTransparency = 1
                idLabel.Text = "ID: " .. tostring(id)
                idLabel.TextColor3 = Theme.textMuted
                idLabel.TextSize = 11
                idLabel.Font = Theme.font
                idLabel.TextXAlignment = Enum.TextXAlignment.Left
                idLabel.Parent = card
                
                local priceLabel = Instance.new("TextLabel")
                priceLabel.Size = UDim2.new(0.2, 0, 1, 0)
                priceLabel.Position = UDim2.new(0.55, 0, 0, 0)
                priceLabel.BackgroundTransparency = 1
                priceLabel.Text = price > 0 and ("R$" .. tostring(price)) or "Off-sale"
                priceLabel.TextColor3 = price > 0 and Theme.green or Theme.textDim
                priceLabel.TextSize = 13
                priceLabel.Font = Theme.fontBold
                priceLabel.TextXAlignment = Enum.TextXAlignment.Right
                priceLabel.Parent = card
                
                local singleBuyBtn = Instance.new("TextButton")
                singleBuyBtn.Size = UDim2.new(0, 55, 0, 26)
                singleBuyBtn.Position = UDim2.new(1, -65, 0.5, -13)
                singleBuyBtn.BackgroundColor3 = price > 0 and Theme.green or Theme.btnBg
                singleBuyBtn.Text = "Buy"
                singleBuyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                singleBuyBtn.Font = Theme.fontBold
                singleBuyBtn.TextSize = 12
                singleBuyBtn.BorderSizePixel = Theme.borderSize
                singleBuyBtn.BorderColor3 = Theme.border
                singleBuyBtn.Parent = card
                
                if Theme.isModern then
                    local btnCorner = Instance.new("UICorner")
                    btnCorner.CornerRadius = UDim.new(0, 4)
                    btnCorner.Parent = singleBuyBtn
                end
                
                singleBuyBtn.MouseButton1Click:Connect(function()
                    if price > 0 then
                        pcall(function()
                            MarketplaceService:PromptPurchase(LocalPlayer, id)
                        end)
                    end
                end)
            end
            
            ScrollingList.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
            TotalLabel.Text = "Total Value: R$ " .. tostring(totalValue)
            TotalLabel.TextColor3 = Theme.green
        else
            TotalLabel.Text = "Failed to load via AvatarEditorService."
            TotalLabel.TextColor3 = Theme.red
        end
    end)
end

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

CopyMapBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(MAP_LINK)
        CopyMapBtn.Text = "Link Copied!"
        CopyMapBtn.BackgroundColor3 = Theme.green
        task.wait(1.5)
        CopyMapBtn.Text = "Copy Map Link"
        CopyMapBtn.BackgroundColor3 = Theme.accent
    end
end)

SearchBtn.MouseButton1Click:Connect(function()
    local query = PlayerInput.Text
    if query == "" then
        Title.Text = "Viewing: Your Avatar"
        renderItems(getAvatarIDsFromPlayer(LocalPlayer) or {})
        return
    end

    local target = getPlayerFromString(query)
    if target then
        Title.Text = "Viewing (Server): " .. target.DisplayName
        local ids = getAvatarIDsFromPlayer(target)
        if #ids > 0 then
            renderItems(ids)
        else
            TotalLabel.Text = "Character not loaded for " .. target.Name
            TotalLabel.TextColor3 = Theme.red
            renderItems({})
        end
    else
        TotalLabel.Text = "Player not found in server!"
        TotalLabel.TextColor3 = Theme.red
    end
end)

GlobalBtn.MouseButton1Click:Connect(function()
    local query = PlayerInput.Text
    if query == "" then
        Title.Text = "Viewing: Your Avatar"
        renderItems(getAvatarIDsFromPlayer(LocalPlayer) or {})
        return
    end
    
    TotalLabel.Text = "Fetching Global User..."
    TotalLabel.TextColor3 = Theme.yellow
    
    task.spawn(function()
        local success, userId = pcall(function()
            return Players:GetUserIdFromNameAsync(query)
        end)
        
        if success and userId then
            local s2, desc = pcall(function()
                return Players:GetHumanoidDescriptionFromUserId(userId)
            end)
            
            if s2 and desc then
                Title.Text = "Viewing (Global): " .. query
                local ids = extractIDs(desc)
                if #ids > 0 then
                    renderItems(ids)
                else
                    TotalLabel.Text = "User has no items equipped."
                    TotalLabel.TextColor3 = Theme.red
                    renderItems({})
                end
            else
                TotalLabel.Text = "Failed to load global avatar."
                TotalLabel.TextColor3 = Theme.red
            end
        else
            TotalLabel.Text = "User not found!"
            TotalLabel.TextColor3 = Theme.red
        end
    end)
end)

CopyBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        local stringList = table.concat(currentRenderedIDs, "\n")
        setclipboard(stringList)
        CopyBtn.Text = "Copied to Clipboard!"
        CopyBtn.BackgroundColor3 = Theme.green
        task.wait(1.5)
        CopyBtn.Text = "Copy IDs (Each on new line)"
        CopyBtn.BackgroundColor3 = Theme.btnBg
    end
end)

UpdateBtn.MouseButton1Click:Connect(function()
    UpdateBtn.Text = "Updating Save File..."
    saveIDs(currentRenderedIDs)
    Title.Text = "Viewing: JSON Saved Outfit"
    task.wait(0.5)
    UpdateBtn.Text = "Save Viewed Outfit to JSON"
end)

local function init()
    local ids = getSavedIDs()
    if ids then
        Title.Text = "Viewing: JSON Saved Outfit"
        renderItems(ids)
    else
        Title.Text = "No Save Found - Grabbing Yours"
        local current = getAvatarIDsFromPlayer(LocalPlayer) or {}
        saveIDs(current)
        renderItems(current)
    end
end

init()

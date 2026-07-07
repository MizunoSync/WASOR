local VH = _G.VoidHub
local UI = {}

local Services = VH.Services
local State = VH.State

UI.tabButtons = {}
UI.windows = {}
UI.moduleButtons = {}
UI.floatingWindows = {}
UI.themeColors = {
    ["Purple"] = Color3.fromRGB(141, 47, 196), ["Red"] = Color3.fromRGB(218, 38, 38),
    ["Green"] = Color3.fromRGB(46, 204, 113), ["Blue"] = Color3.fromRGB(41, 128, 185),
    ["Yellow"] = Color3.fromRGB(241, 196, 15), ["Cyan"] = Color3.fromRGB(26, 188, 156),
    ["Pink"] = Color3.fromRGB(232, 44, 154), ["Orange"] = Color3.fromRGB(230, 126, 34)
}

local themeHeaders, themeTexts, themeFills, themeToggles = {}, {}, {}, {}
local activeTab = "Modules"
local menuBlur = nil
local screenGui = nil
local mainUIContainer = nil
local topBar = nil
local hudWatermark = nil
local hudCoords = nil
local hudServerAge = nil
local hudArrayListFrame = nil
local toastContainer = nil
local navBar = nil


local settingsPanel = nil
local settingsContent = nil

UI.showToast = function(message, color)
    local S = State.S
    if not S.ToastEnabled then return end
    if not toastContainer then return end
    
    local toast = Instance.new("Frame"); toast.Size = UDim2.new(1, 0, 0, 38)
    toast.BackgroundColor3 = Color3.fromRGB(20, 20, 20); toast.BorderSizePixel = 0; toast.Parent = toastContainer
    local stroke = Instance.new("UIStroke"); stroke.Color = color or State.currentThemeColor; stroke.Thickness = 1.2; stroke.Parent = toast
    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1, -16, 1, 0); lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundTransparency = 1; lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 10
    lbl.TextColor3 = Color3.fromRGB(245, 245, 245); lbl.Text = message; lbl.TextWrapped = true
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = toast
    toast.Size = UDim2.new(1, 0, 0, 0); lbl.TextTransparency = 1; stroke.Transparency = 1
    
    Services.TweenService:Create(toast, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 38)}):Play()
    Services.TweenService:Create(lbl, TweenInfo.new(0.2), {TextTransparency = 0}):Play()
    Services.TweenService:Create(stroke, TweenInfo.new(0.2), {Transparency = 0}):Play()
    
    task.delay(3.5, function()
        if toast and toast.Parent then
            local t1 = Services.TweenService:Create(toast, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 0)})
            local t2 = Services.TweenService:Create(lbl, TweenInfo.new(0.2), {TextTransparency = 1})
            local t3 = Services.TweenService:Create(stroke, TweenInfo.new(0.2), {Transparency = 1})
            t1:Play(); t2:Play(); t3:Play()
            t1.Completed:Connect(function() toast:Destroy() end)
        end
    end)
end

UI.updateHUDArrayList = function()
    if not hudArrayListFrame then return end
    for _, child in ipairs(hudArrayListFrame:GetChildren()) do if child:IsA("TextLabel") then child:Destroy() end end
    local S = State.S
    local isVisible = S.HUDArrayList
    if not State.uiVisible then isVisible = S.HUDArrayList and S.HUDArrayListOutside end
    if not isVisible then hudArrayListFrame.Visible = false return end
    
    local activeMods = {}
    for modName, item in pairs(UI.moduleButtons) do if item.IsActive and item.IsActive() then table.insert(activeMods, modName) end end
    table.sort(activeMods, function(a, b) return #a > #b end)
    
    if #activeMods == 0 then hudArrayListFrame.Visible = false
    else
        hudArrayListFrame.Visible = isVisible
        for _, modName in ipairs(activeMods) do
            local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1, 0, 0, 14); lbl.BackgroundTransparency = 1
            lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 9; lbl.TextColor3 = State.currentThemeColor
            lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Text = "  " .. modName; lbl.Parent = hudArrayListFrame
            local accent = Instance.new("Frame"); accent.Size = UDim2.new(0, 2, 1, 0); accent.Position = UDim2.new(0, 0, 0, 0)
            accent.BackgroundColor3 = State.currentThemeColor; accent.BorderSizePixel = 0; accent.Parent = lbl
        end
    end
end


local function protectUIFonts(gui)
    local function lockFont(obj)
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            local origFont = obj.Font
            obj:GetPropertyChangedSignal("Font"):Connect(function() if obj.Font ~= origFont then obj.Font = origFont end end)
        end
    end
    for _, desc in ipairs(gui:GetDescendants()) do lockFont(desc) end
    gui.DescendantAdded:Connect(lockFont)
end

local function updateMenuBlur()
    if not menuBlur then return end
    if not State.uiVisible then
        Services.TweenService:Create(menuBlur, TweenInfo.new(0.25), {Size = 0}):Play()
        task.delay(0.25, function() if not State.uiVisible then menuBlur.Enabled = false end end)
        return
    end
    if activeTab == "Settings" then
        menuBlur.Enabled = true; Services.TweenService:Create(menuBlur, TweenInfo.new(0.25), {Size = 16}):Play()
    else
        Services.TweenService:Create(menuBlur, TweenInfo.new(0.25), {Size = 0}):Play()
        task.delay(0.25, function() if activeTab == "Modules" or not State.uiVisible then menuBlur.Enabled = false end end)
    end
end

UI.applyThemeColor = function(colorName)
    local S = State.S
    local col = UI.themeColors[colorName] or UI.themeColors["Purple"]
    State.currentThemeColor = col; S.ThemeColor = colorName
    for _, obj in ipairs(themeHeaders) do pcall(function() obj.BackgroundColor3 = col end) end
    for _, obj in ipairs(themeTexts) do pcall(function() obj.TextColor3 = col end) end
    for _, obj in ipairs(themeFills) do pcall(function() obj.BackgroundColor3 = col end) end
    for _, updateFunc in ipairs(themeToggles) do pcall(updateFunc) end
    for name, btn in pairs(UI.tabButtons) do if name == activeTab then btn.TextColor3 = col end end
    if hudWatermark then hudWatermark.TextColor3 = col end
    task.defer(UI.updateHUDArrayList); task.defer(VH.Utils.updateLocalNametag)
end

local function makeDraggable(frame, handle)
    local dragging = false; local dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = frame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    handle.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
    Services.UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then update(input) end end)
end

local function formatVal(val)
    if type(val) == "number" then
        local str = string.format("%.2f", val):gsub("%.00$", "")
        if str:find("%.") then str = str:gsub("0+$", "") end
        return str
    end
    return tostring(val)
end

local function makeResizable(frame, handle)
    local dragging = false; local dragStart, startSize
    local function update(input)
        local delta = input.Position - dragStart
        local newWidth = math.max(120, startSize.X.Offset + delta.X)
        local newHeight = math.max(50, startSize.Y.Offset + delta.Y)
        frame.Size = UDim2.new(0, newWidth, 0, newHeight)
    end
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startSize = frame.Size
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    Services.UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then update(input) end end)
end

local function findWindowFrame(obj)
    local curr = obj
    while curr do if curr:IsA("Frame") and curr:GetAttribute("BaseWidth") then return curr end; curr = curr.Parent end
    return nil
end

local function scaleGuiObject(obj, scale)
    if not obj:IsA("GuiObject") then return end
    if obj:IsA("UIListLayout") or obj:IsA("UIPadding") or obj:IsA("UIStroke") or obj:IsA("UIGridLayout") then return end
    if obj.Name == "resizeHandle" then return end
    local baseSize = obj:GetAttribute("BaseSize") or obj.Size
    if not obj:GetAttribute("BaseSize") then obj:SetAttribute("BaseSize", baseSize) end
    local basePos = obj:GetAttribute("BasePos") or obj.Position
    if not obj:GetAttribute("BasePos") then obj:SetAttribute("BasePos", basePos) end
    obj.Size = UDim2.new(baseSize.X.Scale, baseSize.X.Offset * scale, baseSize.Y.Scale, baseSize.Y.Offset * scale)
    obj.Position = UDim2.new(basePos.X.Scale, basePos.X.Offset * scale, basePos.Y.Scale, basePos.Y.Offset * scale)
    if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
        local baseTextSize = obj:GetAttribute("BaseTextSize") or obj.TextSize
        if not obj:GetAttribute("BaseTextSize") then obj:SetAttribute("BaseTextSize", baseTextSize) end
        obj.TextSize = math.clamp(math.round(baseTextSize * scale), 7, 24)
    end
end

local function autoScaleContent(winFrame, scale)
    local contentFrame = winFrame:FindFirstChild("content") or winFrame:FindFirstChildOfClass("ScrollingFrame")
    if contentFrame then
        local listLayout = contentFrame:FindFirstChildOfClass("UIListLayout")
        if listLayout then
            local basePadding = listLayout:GetAttribute("BasePadding") or listLayout.Padding.Offset
            if not listLayout:GetAttribute("BasePadding") then listLayout:SetAttribute("BasePadding", basePadding) end
            listLayout.Padding = UDim.new(0, basePadding * scale)
        end
        local uiPadding = contentFrame:FindFirstChildOfClass("UIPadding")
        if uiPadding then
            local basePadT = uiPadding:GetAttribute("BasePadTop") or uiPadding.PaddingTop.Offset
            local basePadB = uiPadding:GetAttribute("BasePadBottom") or uiPadding.PaddingBottom.Offset
            local basePadL = uiPadding:GetAttribute("BasePadLeft") or uiPadding.PaddingLeft.Offset
            local basePadR = uiPadding:GetAttribute("BasePadRight") or uiPadding.PaddingRight.Offset
            if not uiPadding:GetAttribute("BasePadTop") then
                uiPadding:SetAttribute("BasePadTop", basePadT); uiPadding:SetAttribute("BasePadBottom", basePadB)
                uiPadding:SetAttribute("BasePadLeft", basePadL); uiPadding:SetAttribute("BasePadRight", basePadR)
            end
            uiPadding.PaddingTop = UDim.new(0, basePadT * scale); uiPadding.PaddingBottom = UDim.new(0, basePadB * scale)
            uiPadding.PaddingLeft = UDim.new(0, basePadL * scale); uiPadding.PaddingRight = UDim.new(0, basePadR * scale)
        end
    end
    for _, child in ipairs(winFrame:GetDescendants()) do scaleGuiObject(child, scale) end
end

local function adjustWindowSizeToContent(winFrame, contentFrame)
    local totalContentHeight, count = 0, 0
    for _, child in ipairs(contentFrame:GetChildren()) do
        if child:IsA("Frame") and child.Name ~= "resizeHandle" then
            local baseH = child:GetAttribute("BaseSize") and child:GetAttribute("BaseSize").Y.Offset or child.Size.Y.Offset
            totalContentHeight = totalContentHeight + baseH; count = count + 1
        end
    end
    local listLayout = contentFrame:FindFirstChildOfClass("UIListLayout")
    local paddingVal = listLayout and listLayout.Padding.Offset or 4
    local uiPadding = contentFrame:FindFirstChildOfClass("UIPadding")
    local padT = uiPadding and uiPadding.PaddingTop.Offset or 6
    local padB = uiPadding and uiPadding.PaddingBottom.Offset or 6
    local contentHeight = padT + padB + totalContentHeight + math.max(0, count - 1) * paddingVal
    local finalHeight = math.clamp(22 + contentHeight, 50, 300)
    local width = winFrame.Size.X.Offset
    winFrame.Size = UDim2.new(0, width, 0, finalHeight)
    winFrame:SetAttribute("BaseWidth", width); winFrame:SetAttribute("BaseHeight", finalHeight)
end

local function addHeaderGradient(obj)
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 160, 160))})
    grad.Rotation = 90; grad.Parent = obj
end


UI.addToggleOption = function(parent, name, defaultVal, callback)
    local row = Instance.new("Frame"); row.Size = UDim2.new(1, 0, 0, 18); row.BackgroundTransparency = 1; row.Parent = parent
    local label = Instance.new("TextLabel"); label.Size = UDim2.new(1, -34, 1, 0); label.Position = UDim2.new(0, 4, 0, 0)
    label.BackgroundTransparency = 1; label.Font = Enum.Font.Gotham; label.TextSize = 10; label.TextColor3 = Color3.fromRGB(180, 180, 180)
    label.TextXAlignment = Enum.TextXAlignment.Left; label.Text = name; label.Parent = row
    local btn = Instance.new("TextButton"); btn.Size = UDim2.new(0, 26, 0, 14); btn.Position = UDim2.new(1, -30, 0.5, -7)
    btn.BackgroundColor3 = defaultVal and State.currentThemeColor or Color3.fromRGB(55, 55, 55); btn.BorderSizePixel = 0; btn.Text = ""; btn.Parent = row
    local btnCorner = Instance.new("UICorner"); btnCorner.CornerRadius = UDim.new(0, 7); btnCorner.Parent = btn
    local btnStroke = Instance.new("UIStroke"); btnStroke.Thickness = 1; btnStroke.Color = defaultVal and State.currentThemeColor or Color3.fromRGB(80, 80, 80); btnStroke.Parent = btn
    local knob = Instance.new("Frame"); knob.Size = UDim2.new(0, 10, 0, 10)
    knob.Position = defaultVal and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255); knob.BorderSizePixel = 0; knob.Parent = btn
    local knobCorner = Instance.new("UICorner"); knobCorner.CornerRadius = UDim.new(0, 5); knobCorner.Parent = knob
    local active = defaultVal
    
    local function updateToggle(animate)
        local targetPos = active and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5)
        local targetCol = active and State.currentThemeColor or Color3.fromRGB(55, 55, 55)
        local targetStrokeCol = active and State.currentThemeColor or Color3.fromRGB(80, 80, 80)
        if animate then
            Services.TweenService:Create(knob, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPos}):Play()
            Services.TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = targetCol}):Play()
            Services.TweenService:Create(btnStroke, TweenInfo.new(0.15), {Color = targetStrokeCol}):Play()
        else knob.Position = targetPos; btn.BackgroundColor3 = targetCol; btnStroke.Color = targetStrokeCol end
    end
    table.insert(themeToggles, function() updateToggle(false) end)
    btn.MouseButton1Click:Connect(function() active = not active; updateToggle(true); callback(active) end)
    return { Set = function(val) active = val; updateToggle(false) end }
end

UI.addSliderOption = function(parent, name, min, max, defaultVal, callback)
    local row = Instance.new("Frame"); row.Size = UDim2.new(1, 0, 0, 24); row.BackgroundTransparency = 1; row.Parent = parent
    local label = Instance.new("TextLabel"); label.Size = UDim2.new(0.65, 0, 0, 12); label.Position = UDim2.new(0, 4, 0, 0)
    label.BackgroundTransparency = 1; label.Font = Enum.Font.Gotham; label.TextSize = 10; label.TextColor3 = Color3.fromRGB(180, 180, 180)
    label.TextXAlignment = Enum.TextXAlignment.Left; label.Text = name; label.Parent = row
    local valLabel = Instance.new("TextLabel"); valLabel.Size = UDim2.new(0.35, 0, 0, 12); valLabel.Position = UDim2.new(0.65, -4, 0, 0)
    valLabel.BackgroundTransparency = 1; valLabel.Font = Enum.Font.GothamBold; valLabel.TextSize = 10; valLabel.TextColor3 = State.currentThemeColor
    valLabel.TextXAlignment = Enum.TextXAlignment.Right; valLabel.Text = formatVal(defaultVal); valLabel.Parent = row; table.insert(themeTexts, valLabel)
    local slideBg = Instance.new("Frame"); slideBg.Size = UDim2.new(1, -8, 0, 5); slideBg.Position = UDim2.new(0, 4, 0, 15)
    slideBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50); slideBg.BorderSizePixel = 0; slideBg.Parent = row
    local bgCorner = Instance.new("UICorner"); bgCorner.CornerRadius = UDim.new(0, 2.5); bgCorner.Parent = slideBg
    local slideFill = Instance.new("Frame"); local startPct = math.clamp((defaultVal - min) / (max - min), 0, 1)
    slideFill.Size = UDim2.new(startPct, 0, 1, 0); slideFill.BackgroundColor3 = State.currentThemeColor; slideFill.BorderSizePixel = 0; slideFill.Parent = slideBg; table.insert(themeFills, slideFill)
    local fillCorner = Instance.new("UICorner"); fillCorner.CornerRadius = UDim.new(0, 2.5); fillCorner.Parent = slideFill
    local slideKnob = Instance.new("Frame"); slideKnob.Size = UDim2.new(0, 10, 0, 10); slideKnob.Position = UDim2.new(1, -5, 0.5, -5)
    slideKnob.BackgroundColor3 = Color3.fromRGB(240, 240, 240); slideKnob.BorderSizePixel = 0; slideKnob.Parent = slideFill
    local knobCorner = Instance.new("UICorner"); knobCorner.CornerRadius = UDim.new(0, 5); knobCorner.Parent = slideKnob
    local slideBtn = Instance.new("TextButton"); slideBtn.Size = UDim2.new(1, 0, 1, 0); slideBtn.BackgroundTransparency = 1; slideBtn.Text = ""; slideBtn.Parent = slideBg
    
    local function updateSlider(input)
        local sizeX = slideBg.AbsoluteSize.X; if sizeX <= 0 then sizeX = 112 end
        local posX = input.Position.X - slideBg.AbsolutePosition.X; local pct = math.clamp(posX / sizeX, 0, 1)
        slideFill.Size = UDim2.new(pct, 0, 1, 0); local val = math.floor(min + (max - min) * pct + 0.5)
        valLabel.Text = tostring(val); callback(val)
    end
    local dragging = false
    slideBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; updateSlider(input) end end)
    slideBtn.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
    local moveCon = Services.UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateSlider(input) end end)
    table.insert(State.S.Connections, moveCon)
    return { Set = function(val) local pct = math.clamp((val - min) / (max - min), 0, 1); slideFill.Size = UDim2.new(pct, 0, 1, 0); valLabel.Text = formatVal(val) end }
end

UI.addDropdownOption = function(parent, name, optionsList, defaultValIndex, callback)
    local row = Instance.new("Frame"); row.Size = UDim2.new(1, 0, 0, 30); row.BackgroundTransparency = 1; row.Parent = parent
    local label = Instance.new("TextLabel"); label.Size = UDim2.new(1, 0, 0, 12); label.Position = UDim2.new(0, 4, 0, 0)
    label.BackgroundTransparency = 1; label.Font = Enum.Font.Gotham; label.TextSize = 10; label.TextColor3 = Color3.fromRGB(180, 180, 180)
    label.TextXAlignment = Enum.TextXAlignment.Left; label.Text = name; label.Parent = row
    local dropBtn = Instance.new("TextButton"); dropBtn.Size = UDim2.new(1, -8, 0, 14); dropBtn.Position = UDim2.new(0, 4, 0, 12)
    dropBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); dropBtn.BorderSizePixel = 0; dropBtn.Font = Enum.Font.GothamBold; dropBtn.TextSize = 9
    dropBtn.TextColor3 = Color3.fromRGB(240, 240, 240); dropBtn.Text = optionsList[defaultValIndex] or "(none)"; dropBtn.Parent = row
    local dropCorner = Instance.new("UICorner"); dropCorner.CornerRadius = UDim.new(0, 4); dropCorner.Parent = dropBtn
    local stroke = Instance.new("UIStroke"); stroke.Color = Color3.fromRGB(50, 50, 50); stroke.Parent = dropBtn
    addHeaderGradient(dropBtn); local open = false; local listContainer = nil
    
    local function toggleDropdown()
        open = not open; local scale = 1.0; local winFrame = findWindowFrame(row)
        if winFrame then local baseW = winFrame:GetAttribute("BaseWidth") or winFrame.Size.X.Offset; if baseW > 0 then scale = winFrame.Size.X.Offset / baseW end end
        if open then
            listContainer = Instance.new("Frame"); listContainer.Size = UDim2.new(1, 0, 0, #optionsList * 14 * scale)
            listContainer:SetAttribute("BaseSize", UDim2.new(1, 0, 0, #optionsList * 14)); listContainer:SetAttribute("BasePos", UDim2.new(0, 0, 1, 0))
            listContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25); listContainer.BorderSizePixel = 0; listContainer.ZIndex = 20; listContainer.Parent = dropBtn
            local listCorner = Instance.new("UICorner"); listCorner.CornerRadius = UDim.new(0, 4); listCorner.Parent = listContainer
            local listStroke = Instance.new("UIStroke"); listStroke.Color = Color3.fromRGB(45, 45, 45); listStroke.Parent = listContainer
            local layout = Instance.new("UIListLayout"); layout.Parent = listContainer
            for i, opt in ipairs(optionsList) do
                local btn = Instance.new("TextButton"); btn.Size = UDim2.new(1, 0, 0, 14 * scale); btn:SetAttribute("BaseSize", UDim2.new(1, 0, 0, 14))
                btn:SetAttribute("BasePos", UDim2.new(0, 0, 0, 0)); btn:SetAttribute("BaseTextSize", 7); btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                btn.BorderSizePixel = 0; btn.Font = Enum.Font.Gotham; btn.TextSize = math.clamp(math.round(7 * scale), 7, 24)
                btn.TextColor3 = Color3.fromRGB(200, 200, 200); btn.Text = opt; btn.ZIndex = 20; btn.Parent = listContainer
                local itemCorner = Instance.new("UICorner"); itemCorner.CornerRadius = UDim.new(0, 3); itemCorner.Parent = btn
                btn.MouseButton1Click:Connect(function() dropBtn.Text = opt; callback(i, opt); toggleDropdown() end)
            end
            row.Size = UDim2.new(1, 0, 0, (30 + #optionsList * 14) * scale); row:SetAttribute("BaseSize", UDim2.new(1, 0, 0, 30 + #optionsList * 14))
        else
            if listContainer then listContainer:Destroy(); listContainer = nil end
            row.Size = UDim2.new(1, 0, 0, 30 * scale); row:SetAttribute("BaseSize", UDim2.new(1, 0, 0, 30))
        end
    end
    dropBtn.MouseButton1Click:Connect(toggleDropdown)
    return { Set = function(valText) dropBtn.Text = valText end, SetOptions = function(newList) optionsList = newList; if open then toggleDropdown(); toggleDropdown() end end }
end

local keybindRegistry = {}
UI.addKeybindOption = function(parent, name, defaultKey, callback)
    local row = Instance.new("Frame"); row.Size = UDim2.new(1, 0, 0, 18); row.BackgroundTransparency = 1; row.Parent = parent
    local label = Instance.new("TextLabel"); label.Size = UDim2.new(1, -60, 1, 0); label.Position = UDim2.new(0, 4, 0, 0)
    label.BackgroundTransparency = 1; label.Font = Enum.Font.Gotham; label.TextSize = 10; label.TextColor3 = Color3.fromRGB(180, 180, 180)
    label.TextXAlignment = Enum.TextXAlignment.Left; label.Text = name; label.Parent = row
    local bindBtn = Instance.new("TextButton"); bindBtn.Size = UDim2.new(0, 50, 0, 14); bindBtn.Position = UDim2.new(1, -54, 0.5, -7)
    bindBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); bindBtn.BorderSizePixel = 0; bindBtn.Font = Enum.Font.GothamBold; bindBtn.TextSize = 9
    bindBtn.TextColor3 = State.currentThemeColor; bindBtn.Text = (defaultKey and defaultKey ~= Enum.KeyCode.Unknown) and defaultKey.Name or "[none]"
    bindBtn.Parent = row; table.insert(themeTexts, bindBtn)
    local btnCorner = Instance.new("UICorner"); btnCorner.CornerRadius = UDim.new(0, 4); btnCorner.Parent = bindBtn
    local stroke = Instance.new("UIStroke"); stroke.Color = Color3.fromRGB(50, 50, 50); stroke.Parent = bindBtn; addHeaderGradient(bindBtn)
    local currentKey = defaultKey; local listening = false
    
    local optObj = {
        GetKey = function() return currentKey end,
        SetKey = function(key) currentKey = key; bindBtn.Text = (key and key ~= Enum.KeyCode.Unknown) and key.Name or "[none]" end,
        Set = function(key) currentKey = key; bindBtn.Text = (key and key ~= Enum.KeyCode.Unknown) and key.Name or "[none]" end,
        Callback = callback
    }
    keybindRegistry[name] = optObj
    bindBtn.MouseButton1Click:Connect(function() listening = true; bindBtn.Text = "..."; bindBtn.TextColor3 = Color3.fromRGB(255, 255, 255) end)
    
    local con = Services.UserInputService.InputBegan:Connect(function(input)
        if listening then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                local key = input.KeyCode
                if key == Enum.KeyCode.Escape then listening = false; bindBtn.Text = (currentKey and currentKey ~= Enum.KeyCode.Unknown) and currentKey.Name or "[none]"; bindBtn.TextColor3 = State.currentThemeColor; return
                elseif key == Enum.KeyCode.Backspace or key == Enum.KeyCode.Delete then listening = false; currentKey = Enum.KeyCode.Unknown; bindBtn.Text = "[none]"; bindBtn.TextColor3 = State.currentThemeColor; callback(Enum.KeyCode.Unknown); return end
                if Services.UserInputService:GetFocusedTextBox() then return end
                listening = false; currentKey = key; bindBtn.Text = (key and key ~= Enum.KeyCode.Unknown) and key.Name or "[none]"; bindBtn.TextColor3 = State.currentThemeColor
                if key ~= Enum.KeyCode.Unknown then
                    for otherName, otherBind in pairs(keybindRegistry) do
                        if otherName ~= name and otherBind.GetKey() == key then otherBind.SetKey(Enum.KeyCode.Unknown); otherBind.Callback(Enum.KeyCode.Unknown) end
                    end
                end
                callback(key)
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
                task.wait(0.05)
                if listening then listening = false; bindBtn.Text = (currentKey and currentKey ~= Enum.KeyCode.Unknown) and currentKey.Name or "[none]"; bindBtn.TextColor3 = State.currentThemeColor end
            end
        end
    end)
    table.insert(State.S.Connections, con)
    return optObj
end

UI.addTextboxOption = function(parent, name, placeholder, callback)
    local row = Instance.new("Frame"); row.Size = UDim2.new(1, 0, 0, 30); row.BackgroundTransparency = 1; row.Parent = parent
    local label = Instance.new("TextLabel"); label.Size = UDim2.new(1, 0, 0, 12); label.Position = UDim2.new(0, 4, 0, 0)
    label.BackgroundTransparency = 1; label.Font = Enum.Font.Gotham; label.TextSize = 10; label.TextColor3 = Color3.fromRGB(180, 180, 180)
    label.TextXAlignment = Enum.TextXAlignment.Left; label.Text = name; label.Parent = row
    local box = Instance.new("TextBox"); box.Size = UDim2.new(1, -8, 0, 14); box.Position = UDim2.new(0, 4, 0, 12)
    box.BackgroundColor3 = Color3.fromRGB(30, 30, 30); box.BorderSizePixel = 0; box.Font = Enum.Font.Gotham; box.TextSize = 9
    box.TextColor3 = Color3.fromRGB(240, 240, 240); box.PlaceholderText = placeholder; box.Text = ""; box.ClearTextOnFocus = false; box.Parent = row
    local boxCorner = Instance.new("UICorner"); boxCorner.CornerRadius = UDim.new(0, 4); boxCorner.Parent = box
    local stroke = Instance.new("UIStroke"); stroke.Color = Color3.fromRGB(50, 50, 50); stroke.Parent = box
    box.FocusLost:Connect(function() callback(box.Text) end)
    return { Set = function(valText) box.Text = valText end }
end

UI.addButtonOption = function(parent, name, callback)
    local row = Instance.new("Frame"); row.Size = UDim2.new(1, 0, 0, 18); row.BackgroundTransparency = 1; row.Parent = parent
    local btn = Instance.new("TextButton"); btn.Size = UDim2.new(1, -8, 0, 14); btn.Position = UDim2.new(0, 4, 0.5, -7)
    btn.BackgroundColor3 = State.currentThemeColor; btn.BorderSizePixel = 0; btn.Font = Enum.Font.GothamBold; btn.TextSize = 9
    btn.TextColor3 = Color3.fromRGB(255, 255, 255); btn.Text = name; btn.Parent = row; table.insert(themeHeaders, btn)
    local btnCorner = Instance.new("UICorner"); btnCorner.CornerRadius = UDim.new(0, 4); btnCorner.Parent = btn
    local btnStroke = Instance.new("UIStroke"); btnStroke.Color = Color3.fromRGB(255, 255, 255); btnStroke.Transparency = 0.85; btnStroke.Parent = btn
    addHeaderGradient(btn); btn.MouseButton1Click:Connect(callback)
end

UI.addSectionHeader = function(parent, title)
    local row = Instance.new("Frame"); row.Size = UDim2.new(1, 0, 0, 22); row.BackgroundTransparency = 1; row.Parent = parent
    local text = Instance.new("TextLabel"); text.Size = UDim2.new(1, -8, 1, 0); text.Position = UDim2.new(0, 4, 0, 0)
    text.BackgroundTransparency = 1; text.Font = Enum.Font.GothamBold; text.TextSize = 10; text.TextColor3 = State.currentThemeColor
    text.TextXAlignment = Enum.TextXAlignment.Left; text.Text = "── " .. title:upper() .. " ──"; text.Parent = row; table.insert(themeTexts, text)
end

UI.addInfoRowOption = function(parent, name, initialValue)
    local row = Instance.new("Frame"); row.Size = UDim2.new(1, 0, 0, 16); row.BackgroundTransparency = 1; row.Parent = parent
    local label = Instance.new("TextLabel"); label.Size = UDim2.new(0.5, 0, 1, 0); label.Position = UDim2.new(0, 4, 0, 0)
    label.BackgroundTransparency = 1; label.Font = Enum.Font.Gotham; label.TextSize = 10; label.TextColor3 = Color3.fromRGB(180, 180, 180)
    label.TextXAlignment = Enum.TextXAlignment.Left; label.Text = name; label.Parent = row
    local valLabel = Instance.new("TextLabel"); valLabel.Size = UDim2.new(0.5, -8, 1, 0); valLabel.Position = UDim2.new(0.5, 4, 0, 0)
    valLabel.BackgroundTransparency = 1; valLabel.Font = Enum.Font.GothamBold; valLabel.TextSize = 10; valLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    valLabel.TextXAlignment = Enum.TextXAlignment.Right; valLabel.Text = initialValue; valLabel.Parent = row
    return { Label = valLabel, SetValue = function(self, val) valLabel.Text = tostring(val) end, SetColor = function(self, color) valLabel.TextColor3 = color end }
end

UI.addCustomFrameOption = function(parent, height)
    local row = Instance.new("Frame"); row.Size = UDim2.new(1, 0, 0, height); row.BackgroundTransparency = 1; row.Parent = parent
    return row
end

UI.addScrollFeedOption = function(parent, height)
    local row = Instance.new("Frame"); row.Size = UDim2.new(1, -8, 0, height); row.Position = UDim2.new(0, 4, 0, 0)
    row.BackgroundColor3 = Color3.fromRGB(15, 15, 15); row.BorderSizePixel = 0; row.Parent = parent
    local stroke = Instance.new("UIStroke"); stroke.Color = Color3.fromRGB(30, 30, 30); stroke.Parent = row
    local scroll = Instance.new("ScrollingFrame"); scroll.Size = UDim2.new(1, -4, 1, -4); scroll.Position = UDim2.new(0, 2, 0, 2)
    scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0; scroll.ScrollBarThickness = 1
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0); scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; scroll.Parent = row
    local layout = Instance.new("UIListLayout"); layout.Padding = UDim.new(0, 1); layout.Parent = scroll
    local entriesMap, entryCount = {}, 0
    return {
        Clear = function() for _, c in ipairs(scroll:GetChildren()) do if c:IsA("TextLabel") then c:Destroy() end end; entriesMap = {}; entryCount = 0 end,
        AddEntry = function(self, text, color, count)
            local initialCount = count or 1; local existing = entriesMap[text]
            if existing then existing.count = existing.count + initialCount; existing.label.Text = string.format("%s (x%d)", text, existing.count); return end
            entryCount = entryCount + 1; local currentOrder = entryCount; local scale = 1.0
            local winFrame = findWindowFrame(row)
            if winFrame then local baseW = winFrame:GetAttribute("BaseWidth") or winFrame.Size.X.Offset; if baseW > 0 then scale = winFrame.Size.X.Offset / baseW end end
            local label = Instance.new("TextLabel"); label.Size = UDim2.new(1, 0, 0, 12 * scale); label:SetAttribute("BaseSize", UDim2.new(1, 0, 0, 12))
            label:SetAttribute("BasePos", UDim2.new(0, 0, 0, 0)); label:SetAttribute("BaseTextSize", 7); label.BackgroundTransparency = 1
            label.Font = Enum.Font.Code; label.TextSize = math.clamp(math.round(7 * scale), 7, 24); label.TextColor3 = color or Color3.fromRGB(200, 200, 200)
            label.TextXAlignment = Enum.TextXAlignment.Left; label.LayoutOrder = currentOrder
            local displayText = text; if initialCount > 1 then displayText = string.format("%s (x%d)", text, initialCount) end
            label.Text = displayText; label.TextWrapped = true; label.Parent = scroll
            entriesMap[text] = { label = label, count = initialCount }
            task.defer(function() scroll.CanvasPosition = Vector2.new(0, scroll.AbsoluteCanvasSize.Y) end)
        end
    }
end

local catPositions = { ["Combat"] = 20, ["Player"] = 210, ["Movement"] = 400, ["Render"] = 590, ["World"] = 780, ["Misc"] = 970, ["Search"] = 1160 }
UI.getOrCreateWindow = function(catName, defaultX, defaultY)
    if UI.windows[catName] then return UI.windows[catName] end
    local x = catPositions[catName] or defaultX; local y = defaultY
    local win = Instance.new("Frame"); win.Size = UDim2.new(0, 180, 0, 22); win.AutomaticSize = Enum.AutomaticSize.Y
    win.Position = UDim2.new(0, x, 0, y); win.BackgroundColor3 = Color3.fromRGB(20, 20, 20); win.BorderSizePixel = 0
    win.ClipsDescendants = true; win.Parent = mainUIContainer
    local winCorner = Instance.new("UICorner"); winCorner.CornerRadius = UDim.new(0, 6); winCorner.Parent = win
    local header = Instance.new("TextButton"); header.Size = UDim2.new(1, 0, 0, 22); header.BackgroundColor3 = State.currentThemeColor
    header.BorderSizePixel = 0; header.Font = Enum.Font.GothamBold; header.TextSize = 10; header.TextColor3 = Color3.fromRGB(255, 255, 255)
    header.TextXAlignment = Enum.TextXAlignment.Left; header.Text = "  " .. catName; header.Parent = win; table.insert(themeHeaders, header); addHeaderGradient(header)
    local collapseBtn = Instance.new("TextLabel"); collapseBtn.Size = UDim2.new(0, 22, 0, 22); collapseBtn.Position = UDim2.new(1, -22, 0, 0)
    collapseBtn.BackgroundTransparency = 1; collapseBtn.Font = Enum.Font.GothamBold; collapseBtn.TextSize = 9
    collapseBtn.TextColor3 = Color3.fromRGB(255, 255, 255); collapseBtn.Text = "▼"; collapseBtn.Parent = header
    local list = Instance.new("Frame"); list.Size = UDim2.new(1, 0, 0, 0); list.AutomaticSize = Enum.AutomaticSize.Y
    list.Position = UDim2.new(0, 0, 0, 22); list.BackgroundColor3 = Color3.fromRGB(20, 20, 20); list.BackgroundTransparency = 0.15
    list.BorderSizePixel = 0; list.Parent = win
    local listLayout = Instance.new("UIListLayout"); listLayout.Padding = UDim.new(0, 1); listLayout.Parent = list
    local stroke = Instance.new("UIStroke"); stroke.Color = Color3.fromRGB(30, 30, 30); stroke.Parent = win
    makeDraggable(win, header); local collapsed = false
    local function toggleCollapse() collapsed = not collapsed; list.Visible = not collapsed; collapseBtn.Text = collapsed and "▲" or "▼" end
    header.MouseButton1Click:Connect(toggleCollapse)
    UI.windows[catName] = { Frame = win, List = list, Layout = listLayout }; return UI.windows[catName]
end

UI.createFloatingWindow = function(title, width, height, defaultX, defaultY)
    local win = Instance.new("Frame"); win.Size = UDim2.new(0, width, 0, height); win.Position = UDim2.new(0, defaultX, 0, defaultY)
    win.BackgroundColor3 = Color3.fromRGB(20, 20, 20); win.BorderSizePixel = 0; win.ClipsDescendants = true; win.Visible = false
    win.ZIndex = 5; win.Parent = mainUIContainer
    local winCorner = Instance.new("UICorner"); winCorner.CornerRadius = UDim.new(0, 6); winCorner.Parent = win
    local header = Instance.new("TextButton"); header.Size = UDim2.new(1, 0, 0, 22); header.BackgroundColor3 = State.currentThemeColor
    header.BorderSizePixel = 0; header.Font = Enum.Font.GothamBold; header.TextSize = 10; header.TextColor3 = Color3.fromRGB(255, 255, 255)
    header.TextXAlignment = Enum.TextXAlignment.Left; header.Text = "  " .. title; header.Parent = win; table.insert(themeHeaders, header); addHeaderGradient(header)
    local collapsed = false; local baseHeight = height
    local collapseBtn = Instance.new("TextButton"); collapseBtn.Size = UDim2.new(0, 22, 0, 22); collapseBtn.Position = UDim2.new(1, -44, 0, 0)
    collapseBtn.BackgroundTransparency = 1; collapseBtn.Font = Enum.Font.GothamBold; collapseBtn.TextSize = 10
    collapseBtn.TextColor3 = Color3.fromRGB(255, 255, 255); collapseBtn.Text = "-"; collapseBtn.Parent = header
    local closeBtn = Instance.new("TextButton"); closeBtn.Size = UDim2.new(0, 22, 0, 22); closeBtn.Position = UDim2.new(1, -22, 0, 0)
    closeBtn.BackgroundTransparency = 1; closeBtn.Font = Enum.Font.GothamBold; closeBtn.TextSize = 10
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255); closeBtn.Text = "X"; closeBtn.Parent = header
    closeBtn.MouseButton1Click:Connect(function() win.Visible = false; win:SetAttribute("UserOpen", false) end)
    local content = Instance.new("ScrollingFrame"); content.Name = "content"; content.Size = UDim2.new(1, 0, 1, -22)
    content.Position = UDim2.new(0, 0, 0, 22); content.BackgroundColor3 = Color3.fromRGB(20, 20, 20); content.BackgroundTransparency = 0.15
    content.BorderSizePixel = 0; content.ScrollBarThickness = 2; content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y; content.Parent = win
    local listLayout = Instance.new("UIListLayout"); listLayout.Padding = UDim.new(0, 4); listLayout.Parent = content
    local padding = Instance.new("UIPadding"); padding.PaddingTop = UDim.new(0, 6); padding.PaddingBottom = UDim.new(0, 6)
    padding.PaddingLeft = UDim.new(0, 6); padding.PaddingRight = UDim.new(0, 6); padding.Parent = content
    local stroke = Instance.new("UIStroke"); stroke.Color = Color3.fromRGB(40, 40, 40); stroke.Thickness = 1.2; stroke.Parent = win
    local resizeHandle = Instance.new("Frame"); resizeHandle.Name = "resizeHandle"; resizeHandle.Size = UDim2.new(0, 6, 0, 6)
    resizeHandle.Position = UDim2.new(1, -6, 1, -6); resizeHandle.BackgroundColor3 = State.currentThemeColor; resizeHandle.BackgroundTransparency = 0.3
    resizeHandle.BorderSizePixel = 0; resizeHandle.ZIndex = 10; resizeHandle.Parent = win; table.insert(themeFills, resizeHandle)
    makeResizable(win, resizeHandle)
    collapseBtn.MouseButton1Click:Connect(function()
        collapsed = not collapsed; content.Visible = not collapsed; resizeHandle.Visible = not collapsed
        if collapsed then baseHeight = win.Size.Y.Offset; win.Size = UDim2.new(0, win.Size.X.Offset, 0, 22); collapseBtn.Text = "+"
        else win.Size = UDim2.new(0, win.Size.X.Offset, 0, baseHeight); collapseBtn.Text = "-" end
    end)
    makeDraggable(win, header); table.insert(UI.floatingWindows, win)
    win:SetAttribute("BaseWidth", width); win:SetAttribute("BaseHeight", height); local isScaling = false
    win:GetPropertyChangedSignal("Size"):Connect(function()
        if collapsed or isScaling then return end; isScaling = true
        local currentWidth = win.Size.X.Offset; local baseWidth = win:GetAttribute("BaseWidth") or width
        if baseWidth > 0 then
            local scale = currentWidth / baseWidth; autoScaleContent(win, scale)
            local totalContentHeight, count = 0, 0
            for _, child in ipairs(content:GetChildren()) do
                if child:IsA("Frame") and child.Name ~= "resizeHandle" then totalContentHeight = totalContentHeight + child.Size.Y.Offset; count = count + 1 end
            end
            local lL = content:FindFirstChildOfClass("UIListLayout"); local pV = lL and lL.Padding.Offset or (4 * scale)
            local uP = content:FindFirstChildOfClass("UIPadding"); local pT = uP and uP.PaddingTop.Offset or (6 * scale)
            local pB = uP and uP.PaddingBottom.Offset or (6 * scale)
            local contentHeight = pT + pB + totalContentHeight + math.max(0, count - 1) * pV + 2 * scale
            local finalHeight = math.clamp((22 * scale) + contentHeight, 50 * scale, 400 * scale)
            win.Size = UDim2.new(0, currentWidth, 0, finalHeight)
        end
        isScaling = false
    end)
    return win, content
end

UI.registerModule = function(catName, name, defaultX, defaultY, isToggle, defaultState, callback, populateOptionsFunc, useSeparateWindow, winWidth, winHeight)
    local win = UI.getOrCreateWindow(catName, defaultX, defaultY)
    local container = Instance.new("Frame"); container.Name = "Mod_" .. name; container.Size = UDim2.new(1, 0, 0, 20)
    container.AutomaticSize = Enum.AutomaticSize.Y; container.BackgroundTransparency = 1; container.BorderSizePixel = 0; container.Parent = win.List
    local btn = Instance.new("TextButton"); btn.Size = UDim2.new(1, 0, 0, 20); btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.BackgroundTransparency = 0.5; btn.BorderSizePixel = 0; btn.Font = Enum.Font.Gotham; btn.TextSize = 9
    btn.TextColor3 = (isToggle and defaultState) and Color3.fromRGB(100, 240, 100) or Color3.fromRGB(200, 200, 200)
    btn.Text = "  " .. name; btn.TextXAlignment = Enum.TextXAlignment.Left; btn.Parent = container
    local active = defaultState
    
    local function updateColor()
        btn.TextColor3 = (isToggle and active) and Color3.fromRGB(100, 240, 100) or Color3.fromRGB(200, 200, 200)
        task.defer(UI.updateHUDArrayList)
    end
    
    local drawer = nil; local floatingWin = nil; local gear = nil
    local function updateBg()
        local isOpened = false
        if useSeparateWindow and floatingWin then isOpened = floatingWin.Visible elseif drawer then isOpened = drawer.Visible end
        if isOpened then btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45); btn.BackgroundTransparency = 0.3
        else btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); btn.BackgroundTransparency = 0.5 end
    end
    
    local function toggleMenu()
        if useSeparateWindow then
            if not floatingWin then
                local w = winWidth or 160; local h = winHeight or 180
                floatingWin, drawer = UI.createFloatingWindow(name .. " Options", w, h, win.Frame.Position.X.Offset + 190, win.Frame.Position.Y.Offset)
                if populateOptionsFunc then populateOptionsFunc(drawer) end
                adjustWindowSizeToContent(floatingWin, drawer)
            end
            floatingWin.Visible = not floatingWin.Visible; floatingWin:SetAttribute("UserOpen", floatingWin.Visible); updateBg()
        else
            if not drawer then
                drawer = Instance.new("Frame"); drawer.Name = "drawer"; drawer.Size = UDim2.new(1, 0, 0, 0)
                drawer.AutomaticSize = Enum.AutomaticSize.Y; drawer.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
                drawer.BorderSizePixel = 0; drawer.Visible = false; drawer.Parent = container
                local layout = Instance.new("UIListLayout"); layout.Padding = UDim.new(0, 2); layout.Parent = drawer
                local pad = Instance.new("UIPadding"); pad.PaddingTop = UDim.new(0, 4); pad.PaddingBottom = UDim.new(0, 4); pad.PaddingLeft = UDim.new(0, 4); pad.PaddingRight = UDim.new(0, 4); pad.Parent = drawer
                local stroke = Instance.new("UIStroke"); stroke.Color = Color3.fromRGB(35, 35, 35); stroke.Parent = drawer
                if populateOptionsFunc then populateOptionsFunc(drawer) end
            end
            drawer.Visible = not drawer.Visible; updateBg()
        end
    end
    
    if populateOptionsFunc then
        gear = Instance.new("TextButton"); gear.Size = UDim2.new(0, 16, 0, 16); gear.Position = UDim2.new(1, -18, 0.5, -8)
        gear.BackgroundTransparency = 1; gear.Font = Enum.Font.GothamBold; gear.TextSize = 10; gear.TextColor3 = Color3.fromRGB(130, 130, 130)
        gear.Text = "*"; gear.Parent = btn
        gear.MouseButton1Click:Connect(toggleMenu)
        gear.MouseEnter:Connect(function() gear.TextColor3 = State.currentThemeColor end)
        gear.MouseLeave:Connect(function() gear.TextColor3 = Color3.fromRGB(130, 130, 130) end)
    end
    
    btn.MouseButton1Click:Connect(function()
        if isToggle then active = not active; updateColor(); callback(active) else callback() end
    end)
    
    local itemObj = {
        SetActive = function(val) active = val; updateColor() end,
        IsActive = function() return isToggle and active end,
        ToggleMenu = toggleMenu
    }
    UI.moduleButtons[name] = itemObj
    return itemObj
end

local function selectTab(tabName)
    activeTab = tabName
    for name, btn in pairs(UI.tabButtons) do
        if name == tabName then
            btn.TextColor3 = State.currentThemeColor; btn.Font = Enum.Font.GothamBold
        else
            btn.TextColor3 = Color3.fromRGB(200, 200, 200); btn.Font = Enum.Font.Gotham
        end
    end
    updateMenuBlur()
    if tabName == "Modules" then
        if settingsPanel then settingsPanel.Visible = false end
        for _, win in pairs(UI.windows) do
            win.Frame.Visible = true
        end
        for _, win in ipairs(UI.floatingWindows) do
            if win:GetAttribute("UserOpen") == true then win.Visible = true end
        end
    elseif tabName == "Settings" then
        for _, win in pairs(UI.windows) do win.Frame.Visible = false end
        for _, win in ipairs(UI.floatingWindows) do win.Visible = false end
        if settingsPanel then
            settingsPanel.Visible = true
            adjustWindowSizeToContent(settingsPanel, settingsContent)
        end
    end
end


UI.ResetAllToggles = function(self)
    for name, item in pairs(UI.moduleButtons) do
        if item.IsActive and item.IsActive() then
            item.SetActive(false)
        end
    end
end

local function createPanel(title, width, height)
    local win = Instance.new("Frame"); win.Size = UDim2.new(0, width, 0, height); win.Position = UDim2.new(0.5, -width/2, 0.5, -height/2)
    win.BackgroundColor3 = Color3.fromRGB(20, 20, 20); win.BorderSizePixel = 0; win.ClipsDescendants = true; win.Visible = false; win.Parent = mainUIContainer
    local winCorner = Instance.new("UICorner"); winCorner.CornerRadius = UDim.new(0, 6); winCorner.Parent = win
    local header = Instance.new("Frame"); header.Size = UDim2.new(1, 0, 0, 22); header.BackgroundColor3 = State.currentThemeColor; header.BorderSizePixel = 0; header.Parent = win
    table.insert(themeHeaders, header); addHeaderGradient(header)
    local titleLbl = Instance.new("TextLabel"); titleLbl.Size = UDim2.new(1, -30, 1, 0); titleLbl.Position = UDim2.new(0, 10, 0, 0)
    titleLbl.BackgroundTransparency = 1; titleLbl.Font = Enum.Font.GothamBold; titleLbl.TextSize = 10; titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left; titleLbl.Text = title; titleLbl.Parent = header
    local closeBtn = Instance.new("TextButton"); closeBtn.Size = UDim2.new(0, 22, 0, 22); closeBtn.Position = UDim2.new(1, -22, 0, 0)
    closeBtn.BackgroundTransparency = 1; closeBtn.Font = Enum.Font.GothamBold; closeBtn.TextSize = 10; closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Text = "X"; closeBtn.Parent = header; closeBtn.MouseButton1Click:Connect(function() win.Visible = false; selectTab("Modules") end)
    local content = Instance.new("ScrollingFrame"); content.Name = "content"; content.Size = UDim2.new(1, 0, 1, -22); content.Position = UDim2.new(0, 0, 0, 22)
    content.BackgroundColor3 = Color3.fromRGB(20, 20, 20); content.BackgroundTransparency = 0.15; content.BorderSizePixel = 0
    content.ScrollBarThickness = 2; content.CanvasSize = UDim2.new(0, 0, 0, 0); content.AutomaticCanvasSize = Enum.AutomaticSize.Y; content.Parent = win
    local listLayout = Instance.new("UIListLayout"); listLayout.Padding = UDim.new(0, 4); listLayout.Parent = content
    local padding = Instance.new("UIPadding"); padding.PaddingTop = UDim.new(0, 6); padding.PaddingBottom = UDim.new(0, 6)
    padding.PaddingLeft = UDim.new(0, 6); padding.PaddingRight = UDim.new(0, 6); padding.Parent = content
    local stroke = Instance.new("UIStroke"); stroke.Color = Color3.fromRGB(40, 40, 40); stroke.Thickness = 1.2; stroke.Parent = win
    local resizeHandle = Instance.new("Frame"); resizeHandle.Name = "resizeHandle"; resizeHandle.Size = UDim2.new(0, 6, 0, 6)
    resizeHandle.Position = UDim2.new(1, -6, 1, -6); resizeHandle.BackgroundColor3 = State.currentThemeColor; resizeHandle.BackgroundTransparency = 0.3
    resizeHandle.BorderSizePixel = 0; resizeHandle.ZIndex = 10; resizeHandle.Parent = win; table.insert(themeFills, resizeHandle)
    makeResizable(win, resizeHandle); makeDraggable(win, header)
    win:SetAttribute("BaseWidth", width); win:SetAttribute("BaseHeight", height); local isScaling = false
    win:GetPropertyChangedSignal("Size"):Connect(function()
        if isScaling then return end; isScaling = true
        local currentWidth = win.Size.X.Offset; local baseWidth = win:GetAttribute("BaseWidth") or width
        if baseWidth > 0 then
            local scale = currentWidth / baseWidth; autoScaleContent(win, scale)
            local totalContentHeight, count = 0, 0
            for _, child in ipairs(content:GetChildren()) do
                if child:IsA("Frame") and child.Name ~= "resizeHandle" then totalContentHeight = totalContentHeight + child.Size.Y.Offset; count = count + 1 end
            end
            local lL = content:FindFirstChildOfClass("UIListLayout"); local pV = lL and lL.Padding.Offset or (4 * scale)
            local uP = content:FindFirstChildOfClass("UIPadding"); local pT = uP and uP.PaddingTop.Offset or (6 * scale)
            local pB = uP and uP.PaddingBottom.Offset or (6 * scale)
            local contentHeight = pT + pB + totalContentHeight + math.max(0, count - 1) * pV + 2 * scale
            local finalHeight = math.clamp((22 * scale) + contentHeight, 50 * scale, 400 * scale)
            win.Size = UDim2.new(0, currentWidth, 0, finalHeight)
        end
        isScaling = false
    end)
    return win, content
end

UI.InitializeUI = function()
    local S = State.S
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MeteorRobloxGUI"; screenGui.ResetOnSpawn = false; screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() screenGui.Parent = Services.CoreGui end)
    if not screenGui.Parent then pcall(function() screenGui.Parent = Services.LP:WaitForChild("PlayerGui") end) end
    protectUIFonts(screenGui)
    
    mainUIContainer = Instance.new("Frame")
    mainUIContainer.Name = "MainUIContainer"; mainUIContainer.Size = UDim2.new(1, 0, 1, 0)
    mainUIContainer.BackgroundTransparency = 1; mainUIContainer.BorderSizePixel = 0
    mainUIContainer.Visible = true; mainUIContainer.Parent = screenGui
    
    State.currentThemeColor = UI.themeColors[S.ThemeColor or "Purple"] or UI.themeColors["Purple"]
    
    menuBlur = Services.Lighting:FindFirstChild("WeAreSkiddingBlur")
    if not menuBlur then menuBlur = Instance.new("BlurEffect"); menuBlur.Name = "WeAreSkiddingBlur"; menuBlur.Size = 0; menuBlur.Enabled = false; menuBlur.Parent = Services.Lighting end
    
    hudArrayListFrame = Instance.new("Frame")
    hudArrayListFrame.Size = UDim2.new(0, 120, 0, 0); hudArrayListFrame.AutomaticSize = Enum.AutomaticSize.Y
    hudArrayListFrame.Position = UDim2.new(0, S.HUDArrayListX or 10, 0, S.HUDArrayListY or 70)
    hudArrayListFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15); hudArrayListFrame.BackgroundTransparency = 0.3; hudArrayListFrame.BorderSizePixel = 0
    hudArrayListFrame.Visible = false; hudArrayListFrame.Parent = mainUIContainer
    
    local hudStroke = Instance.new("UIStroke"); hudStroke.Color = Color3.fromRGB(45, 45, 45); hudStroke.Thickness = 1; hudStroke.Parent = hudArrayListFrame
    local hudPadding = Instance.new("UIPadding"); hudPadding.PaddingTop = UDim.new(0, 4); hudPadding.PaddingBottom = UDim.new(0, 4)
    hudPadding.PaddingLeft = UDim.new(0, 4); hudPadding.PaddingRight = UDim.new(0, 4); hudPadding.Parent = hudArrayListFrame
    local arrayLayout = Instance.new("UIListLayout"); arrayLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    arrayLayout.VerticalAlignment = Enum.VerticalAlignment.Top; arrayLayout.Padding = UDim.new(0, 2); arrayLayout.Parent = hudArrayListFrame
    
    
    local arrayDragging, arrayDragStart, arrayStartPos = false, nil, nil
    hudArrayListFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            arrayDragging = true; arrayDragStart = input.Position; arrayStartPos = hudArrayListFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    arrayDragging = false; S.HUDArrayListX = hudArrayListFrame.Position.X.Offset; S.HUDArrayListY = hudArrayListFrame.Position.Y.Offset; VH.Config.saveConfig()
                end
            end)
        end
    end)
    Services.UserInputService.InputChanged:Connect(function(input)
        if arrayDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - arrayDragStart
            hudArrayListFrame.Position = UDim2.new(arrayStartPos.X.Scale, arrayStartPos.X.Offset + delta.X, arrayStartPos.Y.Scale, arrayStartPos.Y.Offset + delta.Y)
        end
    end)
    
    
    task.spawn(function() while true do task.wait(0.2); pcall(UI.updateHUDArrayList) end end)
    
    topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 24); topBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15); topBar.BorderSizePixel = 0; topBar.Parent = mainUIContainer
    local topStroke = Instance.new("UIStroke"); topStroke.Color = Color3.fromRGB(30, 30, 30); topStroke.Thickness = 1; topStroke.Parent = topBar
    
    local function getExecutorName()
        if identifyexecutor then local ok, name = pcall(identifyexecutor); if ok and name then return name end end
        if syn then return "Synapse" end; if krnl then return "Krnl" end; if fluxus then return "Fluxus" end
        return "Unknown"
    end
    local executorName = getExecutorName()
    
    local topTitle = Instance.new("TextLabel")
    topTitle.Size = UDim2.new(0, 450, 1, 0); topTitle.Position = UDim2.new(0, 10, 0, 0); topTitle.BackgroundTransparency = 1
    topTitle.Font = Enum.Font.GothamBold; topTitle.TextSize = 11; topTitle.TextColor3 = State.currentThemeColor
    topTitle.TextXAlignment = Enum.TextXAlignment.Left
    topTitle.Text = "WeAreSkidding <font color='#ffffff'>On Roblox v1.4</font> <font color='#888888'>(" .. executorName .. ")</font>"
    topTitle.RichText = true; topTitle.Parent = topBar; table.insert(themeTexts, topTitle)
    
    local hudTextLabel = Instance.new("TextLabel")
    hudTextLabel.Size = UDim2.new(0, 300, 1, 0); hudTextLabel.Position = UDim2.new(1, -310, 0, 0); hudTextLabel.BackgroundTransparency = 1
    hudTextLabel.Font = Enum.Font.Code; hudTextLabel.TextSize = 10; hudTextLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    hudTextLabel.TextXAlignment = Enum.TextXAlignment.Right; hudTextLabel.Text = "FPS: -- | PING: --"; hudTextLabel.Parent = topBar
    UI.HUDLabel = hudTextLabel
    
    toastContainer = Instance.new("Frame")
    toastContainer.Size = UDim2.new(0, 260, 0, 300); toastContainer.Position = UDim2.new(1, -270, 1, -325)
    toastContainer.BackgroundTransparency = 1; toastContainer.BorderSizePixel = 0; toastContainer.Parent = screenGui
    local toastLayout = Instance.new("UIListLayout"); toastLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom; toastLayout.Padding = UDim.new(0, 6); toastLayout.Parent = toastContainer
    
    hudWatermark = Instance.new("TextLabel")
    hudWatermark.Size = UDim2.new(0, 200, 0, 14); hudWatermark.Position = UDim2.new(0, 10, 0, 30); hudWatermark.BackgroundTransparency = 1
    hudWatermark.Font = Enum.Font.GothamBold; hudWatermark.TextSize = 10; hudWatermark.TextColor3 = State.currentThemeColor
    hudWatermark.TextXAlignment = Enum.TextXAlignment.Left; hudWatermark.Text = "Void Utility Hub v1.4"; hudWatermark.Visible = S.HUDWatermark; hudWatermark.Parent = mainUIContainer
    
    hudCoords = Instance.new("TextLabel")
    hudCoords.Size = UDim2.new(0, 250, 0, 14); hudCoords.Position = UDim2.new(0, 10, 0, 44); hudCoords.BackgroundTransparency = 1
    hudCoords.Font = Enum.Font.Code; hudCoords.TextSize = 9; hudCoords.TextColor3 = Color3.fromRGB(200, 200, 200)
    hudCoords.TextXAlignment = Enum.TextXAlignment.Left; hudCoords.Text = "XYZ: 0.0, 0.0, 0.0"; hudCoords.Visible = S.HUDCoords; hudCoords.Parent = mainUIContainer
    
    hudServerAge = Instance.new("TextLabel")
    hudServerAge.Size = UDim2.new(0, 250, 0, 14); hudServerAge.Position = UDim2.new(0, 10, 0, 58); hudServerAge.BackgroundTransparency = 1
    hudServerAge.Font = Enum.Font.Code; hudServerAge.TextSize = 9; hudServerAge.TextColor3 = Color3.fromRGB(150, 150, 150)
    hudServerAge.TextXAlignment = Enum.TextXAlignment.Left; hudServerAge.Text = "Server Age: 0h 0m 0s"; hudServerAge.Visible = S.ServerAgeHUD; hudServerAge.Parent = mainUIContainer
    
    
    settingsPanel, settingsContent = createPanel("Client Settings", 280, 350)
    
    UI.addSectionHeader(settingsContent, "Configuration Profiles")
    UI.addButtonOption(settingsContent, "Apply legit closet profile", function()
        UI:ResetAllToggles()
        S.WalkSpeed = 22; S.JumpPower = 55; S.ForceWalkSpeed = true; S.ESPBoxes = true; S.ESPTransparency = 0.9; S.AimbotActive = true; S.AimbotFOV = 40; S.AimbotSmooth = 15; S.ESPNames = true
        if UI.moduleButtons["Speed Modification"] then UI.moduleButtons["Speed Modification"].SetActive(true) end
        if UI.moduleButtons["ESP Box Outlines"] then UI.moduleButtons["ESP Box Outlines"].SetActive(true) end
        if UI.moduleButtons["Aimbot"] then UI.moduleButtons["Aimbot"].SetActive(true) end
        if UI.moduleButtons["Show Player Names"] then UI.moduleButtons["Show Player Names"].SetActive(true) end
        VH.Config.saveConfig(); VH.Utils.notify("Closet Legit profile applied!", Color3.fromRGB(46, 204, 113))
    end)
    UI.addButtonOption(settingsContent, "Apply blatant flight profile", function()
        UI:ResetAllToggles()
        S.Fly = true; S.NoClip = true; S.InfJump = true; S.WalkSpeed = 65; S.JumpPower = 80; S.ForceWalkSpeed = true; S.ForceJumpPower = true; S.ESPBoxes = true; S.ESPHealth = true; S.ESPNames = true; S.ESPDistances = true
        if UI.moduleButtons["Fly Mode"] then UI.moduleButtons["Fly Mode"].SetActive(true) end
        if UI.moduleButtons["NoClip Passes"] then UI.moduleButtons["NoClip Passes"].SetActive(true) end
        if UI.moduleButtons["Infinite Jump"] then UI.moduleButtons["Infinite Jump"].SetActive(true) end
        if UI.moduleButtons["Speed Modification"] then UI.moduleButtons["Speed Modification"].SetActive(true) end
        if UI.moduleButtons["Jump Hack Strength"] then UI.moduleButtons["Jump Hack Strength"].SetActive(true) end
        if UI.moduleButtons["ESP Box Outlines"] then UI.moduleButtons["ESP Box Outlines"].SetActive(true) end
        if UI.moduleButtons["Show Player Names"] then UI.moduleButtons["Show Player Names"].SetActive(true) end
        if UI.moduleButtons["Show Health Text"] then UI.moduleButtons["Show Health Text"].SetActive(true) end
        VH.Config.saveConfig(); VH.Utils.notify("Blatant profile applied!", Color3.fromRGB(241, 196, 15))
    end)
    UI.addButtonOption(settingsContent, "Apply rage combat profile", function()
        UI:ResetAllToggles()
        S.Fly = true; S.NoClip = true; S.KillAura = true; S.GodMode = true; S.AimbotActive = true; S.AimbotFOV = 600; S.AimbotSmooth = 1; S.InstantPrompts = true; S.AntiVoid = true
        if UI.moduleButtons["Fly Mode"] then UI.moduleButtons["Fly Mode"].SetActive(true) end
        if UI.moduleButtons["NoClip Passes"] then UI.moduleButtons["NoClip Passes"].SetActive(true) end
        if UI.moduleButtons["Kill Aura"] then UI.moduleButtons["Kill Aura"].SetActive(true) end
        if UI.moduleButtons["God Mode"] then UI.moduleButtons["God Mode"].SetActive(true) end
        if UI.moduleButtons["Aimbot"] then UI.moduleButtons["Aimbot"].SetActive(true) end
        if UI.moduleButtons["Instant Prompts"] then UI.moduleButtons["Instant Prompts"].SetActive(true) end
        if UI.moduleButtons["Anti-Void Net"] then UI.moduleButtons["Anti-Void Net"].SetActive(true) end
        VH.Config.saveConfig(); VH.Utils.notify("Rage profile applied!", Color3.fromRGB(218, 38, 38))
    end)
    
    UI.addSectionHeader(settingsContent, "UI & HUD Customization")
    UI.addDropdownOption(settingsContent, "Interface Theme Color", {"Purple", "Red", "Green", "Blue", "Yellow", "Cyan", "Pink", "Orange"}, table.find({"Purple", "Red", "Green", "Blue", "Yellow", "Cyan", "Pink", "Orange"}, S.ThemeColor) or 1, function(_, opt) UI.applyThemeColor(opt); VH.Config.saveConfig() end)
    UI.addKeybindOption(settingsContent, "Menu Toggle Keybind", S.UIToggleKey or Enum.KeyCode.RightControl, function(k) S.UIToggleKey = k; VH.Config.saveConfig(); VH.Utils.notify("UI Toggle Keybind set to: " .. k.Name, Color3.fromRGB(50, 195, 75)) end)
    UI.addToggleOption(settingsContent, "Show Toasts Enabled", S.ToastEnabled, function(v) S.ToastEnabled = v; VH.Config.saveConfig() end)
    UI.addToggleOption(settingsContent, "Display Client Watermark", S.HUDWatermark, function(v) S.HUDWatermark = v; hudWatermark.Visible = v; VH.Config.saveConfig() end)
    UI.addToggleOption(settingsContent, "Display Player Coordinates", S.HUDCoords, function(v) S.HUDCoords = v; hudCoords.Visible = v; VH.Config.saveConfig() end)
    UI.addToggleOption(settingsContent, "Display Server Age HUD", S.ServerAgeHUD, function(v) S.ServerAgeHUD = v; hudServerAge.Visible = v; VH.Config.saveConfig() end)
    UI.addToggleOption(settingsContent, "Display Active ArrayList", S.HUDArrayList, function(v) S.HUDArrayList = v; UI.updateHUDArrayList(); VH.Config.saveConfig() end)
    UI.addToggleOption(settingsContent, "Display active mods when outside of the main UI", S.HUDArrayListOutside, function(v) S.HUDArrayListOutside = v; UI.updateHUDArrayList(); VH.Config.saveConfig() end)
    
    UI.addSectionHeader(settingsContent, "Targets & Input Settings")
    UI.addTextboxOption(settingsContent, "Specify Target / Friend", "Username", function(txt) if txt == "" then return end; VH.Utils.notify("Target lock set to: " .. txt, Color3.fromRGB(50, 195, 75)) end)
    UI.addButtonOption(settingsContent, "Clear Current Friends Lists", function() VH.Utils.notify("Friends lists reset", Color3.fromRGB(218, 38, 38)) end)
    UI.addTextboxOption(settingsContent, "Configure Macro Text", "Say something...", function(txt) S.MacroText = txt; VH.Config.saveConfig(); VH.Utils.notify("Macro text configured!", Color3.fromRGB(50, 195, 75)) end)
    UI.addKeybindOption(settingsContent, "Trigger Macro Key", S.MacroKey or Enum.KeyCode.H, function(k) S.MacroKey = k; VH.Config.saveConfig(); VH.Utils.notify("Macro trigger set to: " .. k.Name, Color3.fromRGB(50, 195, 75)) end)
    UI.addKeybindOption(settingsContent, "Panic Button (Disable All)", S.PanicKey or Enum.KeyCode.End, function(k) S.PanicKey = k; VH.Config.saveConfig(); VH.Utils.notify("Panic Key set to: " .. k.Name, Color3.fromRGB(218, 38, 38)) end)
    UI.addKeybindOption(settingsContent, "Grab User ID (Hover Player)", S.UserIDGrabKey or Enum.KeyCode.K, function(k) S.UserIDGrabKey = k; VH.Config.saveConfig(); VH.Utils.notify("UserID Grab set to: " .. k.Name, Color3.fromRGB(50, 195, 75)) end)
    
    UI.addSectionHeader(settingsContent, "Executor Capabilities")
    local supportedFuncs = 0; local totalFuncs = 0
    local capsList = {
        {"setclipboard", setclipboard}, {"getgenv", getgenv}, {"Drawing.new", Drawing and Drawing.new},
        {"firetouchinterest", firetouchinterest}, {"fireclickdetector", fireclickdetector}, {"fireproximityprompt", fireproximityprompt},
        {"mouse1press", mouse1press}, {"getcustomasset", getcustomasset}, {"queue_on_teleport", queue_on_teleport or queueteleport}
    }
    for _, cap in ipairs(capsList) do totalFuncs = totalFuncs + 1; if cap[2] then supportedFuncs = supportedFuncs + 1 end end
    UI.addInfoRowOption(settingsContent, "Supported Functions", supportedFuncs .. " / " .. totalFuncs)
    UI.addInfoRowOption(settingsContent, "Executor Name", executorName)
    
    UI.addSectionHeader(settingsContent, "Config & Client Controls")
    UI.addTextboxOption(settingsContent, "Configuration Name", "utility_hub_config", function(txt) end)
    UI.addButtonOption(settingsContent, "Save Current Settings", function() VH.Config.saveConfig(); VH.Utils.notify("Configuration saved successfully!", Color3.fromRGB(50, 195, 75)) end)
    UI.addButtonOption(settingsContent, "Load Stored Settings", function() VH.Config.loadConfig(); VH.Utils.notify("Configuration loaded successfully!", Color3.fromRGB(50, 195, 75)) end)
    UI.addButtonOption(settingsContent, "Reset Settings to Default", function()
        UI:ResetAllToggles()
        S.WalkSpeed = 16; S.JumpPower = 50; S.InfJump = false; S.BHop = false; S.AirWalk = false; S.NoClip = false; S.Fly = false; S.FlySpeed = 60; S.ESPBoxes = false; S.ESPTracers = false; S.ESPNames = false; S.ESPHealth = false; S.ESPDistances = false; S.ESPTeamCheck = false; S.ESPIgnoreFriends = false; S.AimbotActive = false; S.AimbotIgnoreFriends = false; S.TriggerbotIgnoreFriends = false; S.AntiAFK = false; S.AutoRejoin = false; S.NetworkChat = true; S.NetworkTags = true; S.GravityEnabled = false; S.CustomGravity = 196.2; S.ThemeColor = "Purple"
        if UI.moduleButtons["Network Chat Hub"] then UI.moduleButtons["Network Chat Hub"].SetActive(true) end
        if UI.moduleButtons["Network User Tags"] then UI.moduleButtons["Network User Tags"].SetActive(true) end
        UI.applyThemeColor("Purple"); VH.Config.saveConfig(); VH.Utils.notify("All settings reset to default!", Color3.fromRGB(218, 38, 38))
    end)
    UI.addButtonOption(settingsContent, "Destruct Client GUI Completely", function() VH.Cleanup.cleanupAll() end)
    adjustWindowSizeToContent(settingsPanel, settingsContent)
    
    
    navBar = Instance.new("Frame")
    navBar.Size = UDim2.new(0, 190, 1, -24); navBar.Position = UDim2.new(0, 0, 0, 24); navBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15); navBar.BorderSizePixel = 0; navBar.Parent = mainUIContainer
    local navStroke = Instance.new("UIStroke"); navStroke.Color = Color3.fromRGB(30, 30, 30); navStroke.Thickness = 1; navStroke.Parent = navBar
    local navLayout = Instance.new("UIListLayout"); navLayout.Padding = UDim.new(0, 4); navLayout.Parent = navBar
    
    local tabs = {"Modules", "Settings"}
    for _, tabName in ipairs(tabs) do
        local btn = Instance.new("TextButton"); btn.Size = UDim2.new(0, 95, 1, 0); btn.BackgroundTransparency = 1
        btn.Font = Enum.Font.Gotham; btn.TextSize = 12; btn.TextColor3 = (tabName == activeTab) and State.currentThemeColor or Color3.fromRGB(200, 200, 200)
        if tabName == activeTab then btn.Font = Enum.Font.GothamBold end; btn.Text = tabName; btn.Parent = navBar
        btn.MouseEnter:Connect(function() if activeTab ~= tabName then btn.TextColor3 = Color3.fromRGB(255, 255, 255) end end)
        btn.MouseLeave:Connect(function() if activeTab ~= tabName then btn.TextColor3 = Color3.fromRGB(200, 200, 200) end end)
        btn.MouseButton1Click:Connect(function() selectTab(tabName) end); UI.tabButtons[tabName] = btn
    end
    
    
    navLayout.FillDirection = Enum.FillDirection.Horizontal
    navBar.Size = UDim2.new(1, 0, 0, 24); navBar.Position = UDim2.new(0, 0, 0, 24)
    
    
    catPositions = { ["Combat"] = 20, ["Player"] = 210, ["Movement"] = 400, ["Render"] = 590, ["World"] = 780, ["Misc"] = 970, ["Search"] = 1160 }
    
    selectTab("Modules")
    UI.applyThemeColor(S.ThemeColor or "Purple")
    
    UI.hudWatermark = hudWatermark
    UI.hudCoords = hudCoords
    UI.hudServerAge = hudServerAge
    UI.hudArrayListFrame = hudArrayListFrame
    UI.themeToggles = themeToggles
    UI.themeHeaders = themeHeaders
    UI.themeFills = themeFills
    UI.themeTexts = themeTexts
end


UI.GetScreenGui = function() return screenGui end
UI.GetMainContainer = function() return mainUIContainer end

VH.UI = UI
return UI

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local UserService = game:GetService("UserService")
local LocalizationService = game:GetService("LocalizationService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

local function getGuiParent()
	if type(gethui) == "function" then
		local ok, res = pcall(gethui)
		if ok and res then
			return res
		end
	end
	local ok, core = pcall(function()
		return game:GetService("CoreGui")
	end)
	if ok and core then
		return core
	end
	return LocalPlayer:WaitForChild("PlayerGui")
end

local GuiParent = getGuiParent()
local Existing = GuiParent:FindFirstChild("MizuAccountInspector") or GuiParent:FindFirstChild("WasorAccountInspector")
if Existing then
	Existing:Destroy()
end

local HttpRequest = (syn and syn.request) or (http and http.request) or http_request or request

local VH = _G.VoidHub

local function getWasorAccent()
	if VH and VH.State and VH.State.currentThemeColor then
		return VH.State.currentThemeColor
	end
	if VH and VH.UI and VH.UI.themeColors then
		return VH.UI.themeColors["Purple"] or VH.UI.themeColors["Galaxy"] or Color3.fromRGB(141, 47, 196)
	end
	return Color3.fromRGB(141, 47, 196)
end

local Palette = {
	Bg = Color3.fromRGB(20, 20, 24),
	TopBar = Color3.fromRGB(18, 18, 22),
	Surface = Color3.fromRGB(26, 26, 32),
	Inset = Color3.fromRGB(16, 16, 20),
	Hover = Color3.fromRGB(34, 34, 42),
	Selected = Color3.fromRGB(36, 36, 48),
	Border = Color3.fromRGB(38, 38, 46),
	BorderSubtle = Color3.fromRGB(48, 48, 56),
	Accent = getWasorAccent(),
	Text = Color3.fromRGB(240, 240, 245),
	Muted = Color3.fromRGB(160, 160, 170),
	Dim = Color3.fromRGB(115, 115, 125),
	Good = Color3.fromRGB(46, 204, 113),
	Warn = Color3.fromRGB(241, 196, 15),
	Bad = Color3.fromRGB(218, 38, 38),
}

local Connections = {}
local SelectedUserId = LocalPlayer.UserId
local SelectedPlayer = LocalPlayer
local InspectToken = 0
local Minimized = false
local LastExportText = ""
local SectionHeaders = {}

local function bind(signal, fn)
	local conn = signal:Connect(fn)
	table.insert(Connections, conn)
	return conn
end

local function create(className, props, parent)
	local inst = Instance.new(className)
	for k, v in pairs(props) do
		inst[k] = v
	end
	if parent then
		inst.Parent = parent
	end
	return inst
end

local function addCorner(parent, radius)
	return create("UICorner", {
		CornerRadius = UDim.new(0, radius or 6),
	}, parent)
end

local function addStroke(parent, color, thickness)
	return create("UIStroke", {
		Color = color or Palette.Border,
		Thickness = thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, parent)
end

local function addPadding(parent, top, bottom, left, right)
	return create("UIPadding", {
		PaddingTop = UDim.new(0, top or 0),
		PaddingBottom = UDim.new(0, bottom or top or 0),
		PaddingLeft = UDim.new(0, left or top or 0),
		PaddingRight = UDim.new(0, right or left or top or 0),
	}, parent)
end

local function setupHover(btn, normalColor, hoverColor)
	local norm = normalColor or btn.BackgroundColor3
	local hov = hoverColor or Palette.Hover
	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = hov }):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = norm }):Play()
	end)
end

local function formatNumber(n)
	if not n then return "-" end
	local str = tostring(math.floor(n))
	local formatted = str:reverse():gsub("(%d%d%d)", "%1,"):reverse()
	if formatted:sub(1, 1) == "," then
		formatted = formatted:sub(2)
	end
	return formatted
end

local function formatBreakdown(days)
	days = math.max(0, math.floor(days or 0))
	local years = math.floor(days / 365)
	local rem = days % 365
	local months = math.floor(rem / 30)
	local d = rem % 30
	return string.format("%d days (%dy %dm %dd)", days, years, months, d)
end

local function estimateCreationFromAge(accountAgeDays)
	local createdUnix = os.time() - (math.max(0, accountAgeDays) * 86400)
	local t = os.date("!*t", createdUnix)
	return string.format("%04d-%02d-%02d (Est. UTC)", t.year, t.month, t.day)
end

local function parseIsoCreation(isoString)
	local y, m, d, hr, min, sec = isoString:match("^(%d+)%-(%d+)%-(%d+)T(%d+):(%d+):(%d+)")
	if not y then
		return isoString, nil
	end
	local formatted = string.format("%s-%s-%s %s:%s:%s UTC", y, m, d, hr, min, sec)
	local ok, unix = pcall(function()
		return os.time({
			year = tonumber(y),
			month = tonumber(m),
			day = tonumber(d),
			hour = tonumber(hr),
			min = tonumber(min),
			sec = tonumber(sec),
		})
	end)
	local exactDays = nil
	if ok and unix then
		exactDays = math.floor(math.max(0, os.time() - unix) / 86400)
	end
	return formatted, exactDays
end

local function fetchWebUserInfo(userId)
	if not HttpRequest then
		return nil
	end
	local ok, response = pcall(function()
		return HttpRequest({
			Url = "https://users.roblox.com/v1/users/" .. tostring(userId),
			Method = "GET",
		})
	end)
	if not ok or not response or not response.Body then
		return nil
	end
	local decodedOk, data = pcall(function()
		return HttpService:JSONDecode(response.Body)
	end)
	if decodedOk and type(data) == "table" and data.id then
		return data
	end
	return nil
end

local ScreenGui = create("ScreenGui", {
	Name = "WasorAccountInspector",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 999,
}, GuiParent)

local MainFrame = create("Frame", {
	Name = "MainFrame",
	Size = UDim2.new(0, 660, 0, 440),
	Position = UDim2.new(0.5, -330, 0.5, -220),
	BackgroundColor3 = Palette.Bg,
	BorderSizePixel = 0,
	ClipsDescendants = true,
	Visible = false,
}, ScreenGui)
addCorner(MainFrame, 6)
addStroke(MainFrame, Palette.Border, 1)

local AnimScale = create("UIScale", {
	Scale = 1,
}, MainFrame)

local TopBar = create("Frame", {
	Name = "TopBar",
	Size = UDim2.new(1, 0, 0, 32),
	BackgroundColor3 = Palette.TopBar,
	BorderSizePixel = 0,
}, MainFrame)
addCorner(TopBar, 6)

local TopBarFill = create("Frame", {
	Size = UDim2.new(1, 0, 0, 8),
	Position = UDim2.new(0, 0, 1, -8),
	BackgroundColor3 = Palette.TopBar,
	BorderSizePixel = 0,
}, TopBar)

local TopAccentLine = create("Frame", {
	Size = UDim2.new(1, 0, 0, 2),
	Position = UDim2.new(0, 0, 1, -2),
	BackgroundColor3 = Palette.Accent,
	BorderSizePixel = 0,
}, TopBar)

local TitleIcon = create("Frame", {
	Size = UDim2.new(0, 3, 0, 14),
	Position = UDim2.new(0, 10, 0.5, -7),
	BackgroundColor3 = Palette.Accent,
	BorderSizePixel = 0,
}, TopBar)
addCorner(TitleIcon, 2)

create("TextLabel", {
	Size = UDim2.new(1, -160, 1, 0),
	Position = UDim2.new(0, 20, 0, 0),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Font = Enum.Font.GothamBold,
	Text = "WASOR // PLAYER CHECKER",
	TextColor3 = Palette.Text,
	TextSize = 12,
	TextXAlignment = Enum.TextXAlignment.Left,
}, TopBar)

local StatusTag = create("TextLabel", {
	Size = UDim2.new(0, 72, 0, 20),
	Position = UDim2.new(1, -140, 0.5, -10),
	BackgroundColor3 = Palette.Inset,
	BorderSizePixel = 0,
	Font = Enum.Font.GothamBold,
	Text = "[RShift]",
	TextColor3 = Palette.Muted,
	TextSize = 10,
}, TopBar)
addCorner(StatusTag, 4)
addStroke(StatusTag, Palette.Border, 1)

local MinBtn = create("TextButton", {
	Size = UDim2.new(0, 28, 0, 24),
	Position = UDim2.new(1, -62, 0.5, -12),
	BackgroundColor3 = Palette.Inset,
	BorderSizePixel = 0,
	Font = Enum.Font.GothamBold,
	Text = "-",
	TextColor3 = Palette.Text,
	TextSize = 13,
	AutoButtonColor = false,
}, TopBar)
addCorner(MinBtn, 4)
addStroke(MinBtn, Palette.Border, 1)
setupHover(MinBtn, Palette.Inset, Palette.Hover)

local CloseBtn = create("TextButton", {
	Size = UDim2.new(0, 28, 0, 24),
	Position = UDim2.new(1, -32, 0.5, -12),
	BackgroundColor3 = Palette.Inset,
	BorderSizePixel = 0,
	Font = Enum.Font.GothamBold,
	Text = "X",
	TextColor3 = Palette.Bad,
	TextSize = 11,
	AutoButtonColor = false,
}, TopBar)
addCorner(CloseBtn, 4)
addStroke(CloseBtn, Palette.Border, 1)

CloseBtn.MouseEnter:Connect(function()
	TweenService:Create(CloseBtn, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundColor3 = Color3.fromRGB(180, 40, 50),
		TextColor3 = Color3.fromRGB(255, 255, 255),
	}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
	TweenService:Create(CloseBtn, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundColor3 = Palette.Inset,
		TextColor3 = Palette.Bad,
	}):Play()
end)

local Content = create("Frame", {
	Name = "Content",
	Size = UDim2.new(1, 0, 1, -32),
	Position = UDim2.new(0, 0, 0, 32),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
}, MainFrame)

local Sidebar = create("Frame", {
	Name = "Sidebar",
	Size = UDim2.new(0, 195, 1, 0),
	BackgroundColor3 = Palette.Inset,
	BorderSizePixel = 0,
}, Content)
addCorner(Sidebar, 6)
addStroke(Sidebar, Palette.Border, 1)

local SearchContainer = create("Frame", {
	Size = UDim2.new(1, -12, 0, 28),
	Position = UDim2.new(0, 6, 0, 6),
	BackgroundColor3 = Palette.Surface,
	BorderSizePixel = 0,
}, Sidebar)
addCorner(SearchContainer, 4)
addStroke(SearchContainer, Palette.Border, 1)

local SearchBox = create("TextBox", {
	Size = UDim2.new(1, -34, 1, 0),
	Position = UDim2.new(0, 8, 0, 0),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Font = Enum.Font.GothamMedium,
	PlaceholderText = "User or ID...",
	PlaceholderColor3 = Palette.Muted,
	Text = "",
	TextColor3 = Palette.Text,
	TextSize = 11,
	ClearTextOnFocus = false,
	TextXAlignment = Enum.TextXAlignment.Left,
}, SearchContainer)

local SearchGo = create("TextButton", {
	Size = UDim2.new(0, 26, 0, 24),
	Position = UDim2.new(1, -27, 0.5, -12),
	BackgroundColor3 = Palette.Accent,
	BorderSizePixel = 0,
	Font = Enum.Font.GothamBold,
	Text = ">",
	TextColor3 = Color3.fromRGB(255, 255, 255),
	TextSize = 12,
	AutoButtonColor = false,
}, SearchContainer)
addCorner(SearchGo, 4)

local RosterHeader = create("TextLabel", {
	Size = UDim2.new(1, -12, 0, 20),
	Position = UDim2.new(0, 8, 0, 38),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Font = Enum.Font.GothamBold,
	Text = "ROSTER (0)",
	TextColor3 = Palette.Muted,
	TextSize = 10,
	TextXAlignment = Enum.TextXAlignment.Left,
}, Sidebar)

local RosterScroll = create("ScrollingFrame", {
	Size = UDim2.new(1, -12, 1, -66),
	Position = UDim2.new(0, 6, 0, 60),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ScrollBarThickness = 3,
	ScrollBarImageColor3 = Palette.BorderSubtle,
	CanvasSize = UDim2.new(0, 0, 0, 0),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, Sidebar)

create("UIListLayout", {
	SortOrder = Enum.SortOrder.LayoutOrder,
	Padding = UDim.new(0, 4),
}, RosterScroll)

local InspectorPane = create("ScrollingFrame", {
	Name = "InspectorPane",
	Size = UDim2.new(1, -195, 1, 0),
	Position = UDim2.new(0, 195, 0, 0),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ScrollBarThickness = 4,
	ScrollBarImageColor3 = Palette.BorderSubtle,
	CanvasSize = UDim2.new(0, 0, 0, 0),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, Content)
addPadding(InspectorPane, 10, 10, 10, 10)

create("UIListLayout", {
	SortOrder = Enum.SortOrder.LayoutOrder,
	Padding = UDim.new(0, 8),
}, InspectorPane)

local HeaderCard = create("Frame", {
	LayoutOrder = 1,
	Size = UDim2.new(1, 0, 0, 92),
	BackgroundColor3 = Palette.Surface,
	BorderSizePixel = 0,
}, InspectorPane)
addCorner(HeaderCard, 6)
addStroke(HeaderCard, Palette.Border, 1)
addPadding(HeaderCard, 8, 8, 8, 8)

local AvatarFrame = create("Frame", {
	Size = UDim2.new(0, 76, 0, 76),
	BackgroundColor3 = Palette.Inset,
	BorderSizePixel = 0,
}, HeaderCard)
addCorner(AvatarFrame, 6)
local AvatarStroke = addStroke(AvatarFrame, Palette.Accent, 1)

local AvatarImage = create("ImageLabel", {
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Image = "",
	ScaleType = Enum.ScaleType.Fit,
}, AvatarFrame)
addCorner(AvatarImage, 6)

local HeaderInfo = create("Frame", {
	Size = UDim2.new(1, -86, 1, 0),
	Position = UDim2.new(0, 86, 0, 0),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
}, HeaderCard)

local DisplayNameLabel = create("TextLabel", {
	Size = UDim2.new(1, -202, 0, 20),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Font = Enum.Font.GothamBold,
	Text = "Loading...",
	TextColor3 = Palette.Text,
	TextSize = 16,
	TextTruncate = Enum.TextTruncate.AtEnd,
	TextXAlignment = Enum.TextXAlignment.Left,
}, HeaderInfo)

local UsernameLabel = create("TextLabel", {
	Size = UDim2.new(1, -202, 0, 16),
	Position = UDim2.new(0, 0, 0, 20),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Font = Enum.Font.GothamMedium,
	Text = "@username",
	TextColor3 = Palette.Accent,
	TextSize = 12,
	TextTruncate = Enum.TextTruncate.AtEnd,
	TextXAlignment = Enum.TextXAlignment.Left,
}, HeaderInfo)

local BadgeRow = create("TextLabel", {
	Size = UDim2.new(1, 0, 0, 16),
	Position = UDim2.new(0, 0, 0, 40),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Font = Enum.Font.GothamMedium,
	Text = "ID: 0 | STATUS: IN-SERVER",
	TextColor3 = Palette.Muted,
	TextSize = 11,
	TextTruncate = Enum.TextTruncate.AtEnd,
	TextXAlignment = Enum.TextXAlignment.Left,
}, HeaderInfo)

local SourceNote = create("TextLabel", {
	Size = UDim2.new(1, 0, 0, 14),
	Position = UDim2.new(0, 0, 0, 60),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Font = Enum.Font.GothamBold,
	Text = "SOURCE: ENGINE",
	TextColor3 = Palette.Good,
	TextSize = 10,
	TextXAlignment = Enum.TextXAlignment.Left,
}, HeaderInfo)

local CopyIdBtn = create("TextButton", {
	Size = UDim2.new(0, 56, 0, 22),
	Position = UDim2.new(1, -196, 0, 0),
	BackgroundColor3 = Palette.Inset,
	BorderSizePixel = 0,
	Font = Enum.Font.GothamBold,
	Text = "COPY ID",
	TextColor3 = Palette.Text,
	TextSize = 10,
	AutoButtonColor = false,
}, HeaderInfo)
addCorner(CopyIdBtn, 4)
addStroke(CopyIdBtn, Palette.Border, 1)
setupHover(CopyIdBtn, Palette.Inset, Palette.Hover)

local CopyLinkBtn = create("TextButton", {
	Size = UDim2.new(0, 68, 0, 22),
	Position = UDim2.new(1, -136, 0, 0),
	BackgroundColor3 = Palette.Inset,
	BorderSizePixel = 0,
	Font = Enum.Font.GothamBold,
	Text = "COPY LINK",
	TextColor3 = Palette.Text,
	TextSize = 10,
	AutoButtonColor = false,
}, HeaderInfo)
addCorner(CopyLinkBtn, 4)
addStroke(CopyLinkBtn, Palette.Border, 1)
setupHover(CopyLinkBtn, Palette.Inset, Palette.Hover)

local CopyDumpBtn = create("TextButton", {
	Size = UDim2.new(0, 64, 0, 22),
	Position = UDim2.new(1, -64, 0, 0),
	BackgroundColor3 = Palette.Inset,
	BorderSizePixel = 0,
	Font = Enum.Font.GothamBold,
	Text = "COPY ALL",
	TextColor3 = Palette.Accent,
	TextSize = 10,
	AutoButtonColor = false,
}, HeaderInfo)
addCorner(CopyDumpBtn, 4)
addStroke(CopyDumpBtn, Palette.Border, 1)
setupHover(CopyDumpBtn, Palette.Inset, Palette.Hover)

local function createSection(order, titleText)
	local box = create("Frame", {
		LayoutOrder = order,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Palette.Surface,
		BorderSizePixel = 0,
	}, InspectorPane)
	addCorner(box, 6)
	addStroke(box, Palette.Border, 1)
	addPadding(box, 8, 8, 8, 8)

	create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 5),
	}, box)

	local headerRow = create("Frame", {
		LayoutOrder = 0,
		Size = UDim2.new(1, 0, 0, 16),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, box)

	local secDot = create("Frame", {
		Size = UDim2.new(0, 3, 0, 11),
		Position = UDim2.new(0, 0, 0.5, -5),
		BackgroundColor3 = Palette.Accent,
		BorderSizePixel = 0,
	}, headerRow)
	addCorner(secDot, 2)

	local secTitle = create("TextLabel", {
		Size = UDim2.new(1, -10, 1, 0),
		Position = UDim2.new(0, 8, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Text = titleText,
		TextColor3 = Palette.Accent,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, headerRow)

	table.insert(SectionHeaders, { Dot = secDot, Title = secTitle })

	return box
end

local function createRow(parent, order, keyText)
	local row = create("Frame", {
		LayoutOrder = order,
		Size = UDim2.new(1, 0, 0, 24),
		BackgroundColor3 = Palette.Inset,
		BorderSizePixel = 0,
	}, parent)
	addCorner(row, 4)
	addStroke(row, Palette.BorderSubtle, 1)

	create("TextLabel", {
		Size = UDim2.new(0, 145, 1, 0),
		Position = UDim2.new(0, 8, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamMedium,
		Text = keyText,
		TextColor3 = Palette.Muted,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, row)

	local val = create("TextLabel", {
		Size = UDim2.new(1, -160, 1, 0),
		Position = UDim2.new(0, 152, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Text = "-",
		TextColor3 = Palette.Text,
		TextSize = 11,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Right,
	}, row)

	return val
end

local IdentitySection = createSection(2, "// IDENTITY")
local ValCreated = createRow(IdentitySection, 1, "CREATED")
local ValAge = createRow(IdentitySection, 2, "AGE")
local ValFriends = createRow(IdentitySection, 3, "FRIENDS")
local ValFollowers = createRow(IdentitySection, 4, "FOLLOWERS")
local ValMembership = createRow(IdentitySection, 5, "MEMBERSHIP")
local ValVerified = createRow(IdentitySection, 6, "VERIFIED / BAN")
local ValLocale = createRow(IdentitySection, 7, "REGION")
local ValTeam = createRow(IdentitySection, 8, "TEAM")

local TelemetrySection = createSection(3, "// CHARACTER")
local ValState = createRow(TelemetrySection, 1, "STATE")
local ValRig = createRow(TelemetrySection, 2, "HEALTH & RIG")
local ValMovement = createRow(TelemetrySection, 3, "SPEED & JUMP")
local ValPosition = createRow(TelemetrySection, 4, "COORDINATES")

local BioSection = createSection(4, "// BIO")
local BioLabel = create("TextLabel", {
	LayoutOrder = 1,
	Size = UDim2.new(1, 0, 0, 0),
	AutomaticSize = Enum.AutomaticSize.Y,
	BackgroundColor3 = Palette.Inset,
	BorderSizePixel = 0,
	Font = Enum.Font.Gotham,
	Text = "No description available.",
	TextColor3 = Palette.Muted,
	TextSize = 11,
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,
}, BioSection)
addCorner(BioLabel, 4)
addStroke(BioLabel, Palette.BorderSubtle, 1)
addPadding(BioLabel, 6, 6, 8, 8)

local function buildExportString(info)
	return table.concat({
		"=== ROBLOX ACCOUNT REPORT ===",
		"Display Name : " .. tostring(info.displayName),
		"Username     : @" .. tostring(info.username),
		"UserId       : " .. tostring(info.userId),
		"Profile Link : https://www.roblox.com/users/" .. tostring(info.userId) .. "/profile",
		"Created      : " .. tostring(info.created),
		"Account Age  : " .. tostring(info.age),
		"Friends      : " .. tostring(info.friends or "-"),
		"Followers    : " .. tostring(info.followers or "-"),
		"Membership   : " .. tostring(info.membership),
		"Verified/Ban : " .. tostring(info.verifiedBan),
		"Region       : " .. tostring(info.locale),
		"Team         : " .. tostring(info.teamFollow),
		"Bio          : " .. tostring(info.bio),
	}, "\n")
end

local function inspectTarget(targetPlayer, targetUserId)
	InspectToken = InspectToken + 1
	local token = InspectToken

	SelectedPlayer = targetPlayer
	SelectedUserId = targetPlayer and targetPlayer.UserId or targetUserId

	local userId = SelectedUserId
	local username = targetPlayer and targetPlayer.Name or "Resolving..."
	local displayName = targetPlayer and targetPlayer.DisplayName or "Resolving..."

	DisplayNameLabel.Text = displayName
	UsernameLabel.Text = "@" .. username
	BadgeRow.Text = string.format("ID: %d | %s", userId, targetPlayer and "IN-SERVER" or "EXTERNAL")
	SourceNote.Text = HttpRequest and "SOURCE: ENGINE + WEB" or "SOURCE: ENGINE"
	SourceNote.TextColor3 = HttpRequest and Palette.Good or Palette.Warn
	AvatarImage.Image = ""

	local createdText = "Unavailable (External)"
	local ageText = "Unavailable (External)"
	local friendsText = HttpRequest and "Loading..." or "N/A"
	local followersText = HttpRequest and "Loading..." or "N/A"
	local membershipText = "N/A (External)"
	local verifiedText = "No"
	local banText = "Active"
	local localeText = "N/A (External)"
	local teamFollowText = "N/A"
	local bioText = HttpRequest and "Fetching profile bio..." or "Web API unavailable in this environment."

	if targetPlayer then
		local ageDays = targetPlayer.AccountAge
		createdText = estimateCreationFromAge(ageDays)
		ageText = formatBreakdown(ageDays)
		membershipText = tostring(targetPlayer.MembershipType):gsub("Enum%.MembershipType%.", "")
		verifiedText = targetPlayer.HasVerifiedBadge and "Verified" or "Standard"

		local country = "??"
		local okCountry, resCountry = pcall(function()
			return LocalizationService:GetCountryRegionForPlayerAsync(targetPlayer)
		end)
		if okCountry and resCountry then
			country = resCountry
		end
		localeText = string.format("%s (%s)", country, tostring(targetPlayer.LocaleId))

		local teamName = targetPlayer.Team and targetPlayer.Team.Name or "Neutral"
		local followId = targetPlayer.FollowUserId ~= 0 and tostring(targetPlayer.FollowUserId) or "None"
		teamFollowText = (followId == "None") and teamName or string.format("%s (Follow: %s)", teamName, followId)
	end

	ValCreated.Text = createdText
	ValAge.Text = ageText
	ValFriends.Text = friendsText
	ValFollowers.Text = followersText
	ValMembership.Text = membershipText
	ValVerified.Text = verifiedText .. " / " .. banText
	ValLocale.Text = localeText
	ValTeam.Text = teamFollowText
	BioLabel.Text = bioText
	BioLabel.TextColor3 = Palette.Muted

	local reportData = {
		displayName = displayName,
		username = username,
		userId = userId,
		created = createdText,
		age = ageText,
		friends = friendsText,
		followers = followersText,
		membership = membershipText,
		verifiedBan = verifiedText .. " / " .. banText,
		locale = localeText,
		teamFollow = teamFollowText,
		bio = bioText,
	}
	LastExportText = buildExportString(reportData)

	task.spawn(function()
		local okThumb, thumbUrl = pcall(function()
			return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
		end)
		if token == InspectToken and okThumb and thumbUrl then
			AvatarImage.Image = thumbUrl
		end
	end)

	task.spawn(function()
		local okInfo, infos = pcall(function()
			return UserService:GetUserInfosByUserIdsAsync({ userId })
		end)
		if token == InspectToken and okInfo and infos and infos[1] then
			local entry = infos[1]
			username = entry.Username or username
			displayName = entry.DisplayName or displayName
			verifiedText = entry.HasVerifiedBadge and "Verified" or "Standard"

			DisplayNameLabel.Text = displayName
			UsernameLabel.Text = "@" .. username
			ValVerified.Text = verifiedText .. " / " .. banText

			reportData.displayName = displayName
			reportData.username = username
			reportData.verifiedBan = verifiedText .. " / " .. banText
			LastExportText = buildExportString(reportData)
		end
	end)

	if HttpRequest then
		task.spawn(function()
			local okF, resF = pcall(function()
				return HttpRequest({
					Url = "https://friends.roblox.com/v1/users/" .. tostring(userId) .. "/friends/count",
					Method = "GET",
				})
			end)
			if token == InspectToken and okF and resF and resF.Body then
				local decOk, decData = pcall(function()
					return HttpService:JSONDecode(resF.Body)
				end)
				if decOk and decData and decData.count ~= nil then
					local str = formatNumber(decData.count)
					ValFriends.Text = str
					reportData.friends = str
					LastExportText = buildExportString(reportData)
				else
					ValFriends.Text = "N/A"
				end
			elseif token == InspectToken then
				ValFriends.Text = "N/A"
			end
		end)

		task.spawn(function()
			local okFol, resFol = pcall(function()
				return HttpRequest({
					Url = "https://friends.roblox.com/v1/users/" .. tostring(userId) .. "/followers/count",
					Method = "GET",
				})
			end)
			if token == InspectToken and okFol and resFol and resFol.Body then
				local decOk, decData = pcall(function()
					return HttpService:JSONDecode(resFol.Body)
				end)
				if decOk and decData and decData.count ~= nil then
					local str = formatNumber(decData.count)
					ValFollowers.Text = str
					reportData.followers = str
					LastExportText = buildExportString(reportData)
				else
					ValFollowers.Text = "N/A"
				end
			elseif token == InspectToken then
				ValFollowers.Text = "N/A"
			end
		end)

		task.spawn(function()
			local webData = fetchWebUserInfo(userId)
			if token ~= InspectToken then
				return
			end
			if not webData then
				if targetPlayer == nil then
					BioLabel.Text = "Failed to load external user data."
				else
					BioLabel.Text = "No description available."
				end
				return
			end

			if webData.name then
				username = webData.name
				UsernameLabel.Text = "@" .. username
			end
			if webData.displayName then
				displayName = webData.displayName
				DisplayNameLabel.Text = displayName
			end
			if type(webData.hasVerifiedBadge) == "boolean" then
				verifiedText = webData.hasVerifiedBadge and "Verified" or "Standard"
			end
			if type(webData.isBanned) == "boolean" then
				banText = webData.isBanned and "BANNED" or "Active"
			end
			ValVerified.Text = verifiedText .. " / " .. banText
			ValVerified.TextColor3 = webData.isBanned and Palette.Bad or Palette.Text

			if webData.created then
				local exactDate, exactDays = parseIsoCreation(webData.created)
				ValCreated.Text = exactDate
				reportData.created = exactDate
				if exactDays then
					local exactAge = formatBreakdown(exactDays)
					ValAge.Text = exactAge
					reportData.age = exactAge
				end
			end

			local cleanBio = (webData.description and webData.description ~= "") and webData.description or "No bio set."
			BioLabel.Text = cleanBio
			BioLabel.TextColor3 = (webData.description and webData.description ~= "") and Palette.Text or Palette.Muted

			reportData.displayName = displayName
			reportData.username = username
			reportData.verifiedBan = verifiedText .. " / " .. banText
			reportData.bio = cleanBio
			LastExportText = buildExportString(reportData)
		end)
	end
end

local RosterButtons = {}

local function refreshRoster()
	for _, btn in ipairs(RosterButtons) do
		btn:Destroy()
	end
	table.clear(RosterButtons)

	local list = Players:GetPlayers()
	RosterHeader.Text = string.format("ROSTER (%d)", #list)

	for i, plr in ipairs(list) do
		local isSelected = (plr.UserId == SelectedUserId)
		local item = create("TextButton", {
			LayoutOrder = i,
			Size = UDim2.new(1, 0, 0, 36),
			BackgroundColor3 = isSelected and Palette.Selected or Palette.Surface,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
		}, RosterScroll)
		item:SetAttribute("UserId", plr.UserId)
		addCorner(item, 4)
		addStroke(item, isSelected and Palette.Accent or Palette.Border, 1)

		local selBar = create("Frame", {
			Name = "SelBar",
			Size = UDim2.new(0, 3, 1, -8),
			Position = UDim2.new(0, 3, 0, 4),
			BackgroundColor3 = Palette.Accent,
			BorderSizePixel = 0,
			Visible = isSelected,
		}, item)
		addCorner(selBar, 2)

		create("TextLabel", {
			Size = UDim2.new(1, -16, 0, 16),
			Position = UDim2.new(0, 10, 0, 3),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamBold,
			Text = plr.DisplayName,
			TextColor3 = Palette.Text,
			TextSize = 12,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, item)

		create("TextLabel", {
			Size = UDim2.new(1, -16, 0, 14),
			Position = UDim2.new(0, 10, 0, 18),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = Enum.Font.Gotham,
			Text = string.format("@%s | %dd", plr.Name, plr.AccountAge),
			TextColor3 = isSelected and Palette.Accent or Palette.Muted,
			TextSize = 10,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, item)

		if not isSelected then
			setupHover(item, Palette.Surface, Palette.Hover)
		end

		bind(item.MouseButton1Click, function()
			inspectTarget(plr, plr.UserId)
			refreshRoster()
		end)

		table.insert(RosterButtons, item)
	end
end

local function executeLookup()
	local query = SearchBox.Text:gsub("^%s+", ""):gsub("%s+$", "")
	if query == "" then
		return
	end

	for _, plr in ipairs(Players:GetPlayers()) do
		if tostring(plr.UserId) == query or plr.Name:lower() == query:lower() then
			inspectTarget(plr, plr.UserId)
			refreshRoster()
			return
		end
	end

	task.spawn(function()
		local numericId = tonumber(query)
		if numericId then
			local inServer = Players:GetPlayerByUserId(numericId)
			inspectTarget(inServer, numericId)
			refreshRoster()
			return
		end

		local ok, resolvedId = pcall(function()
			return Players:GetUserIdFromNameAsync(query)
		end)
		if ok and resolvedId then
			local inServer = Players:GetPlayerByUserId(resolvedId)
			inspectTarget(inServer, resolvedId)
			refreshRoster()
		else
			SearchBox.Text = ""
			SearchBox.PlaceholderText = "Not found!"
			task.delay(1.5, function()
				if SearchBox and SearchBox.Parent then
					SearchBox.PlaceholderText = "User or ID..."
				end
			end)
		end
	end)
end

bind(SearchGo.MouseButton1Click, executeLookup)
bind(SearchBox.FocusLost, function(enterPressed)
	if enterPressed then
		executeLookup()
	end
end)

local function flashButton(btn, tempText)
	local orig = btn.Text
	btn.Text = tempText
	task.delay(1, function()
		if btn and btn.Parent then
			btn.Text = orig
		end
	end)
end

bind(CopyIdBtn.MouseButton1Click, function()
	if type(setclipboard) == "function" then
		setclipboard(tostring(SelectedUserId))
		flashButton(CopyIdBtn, "COPIED")
	else
		flashButton(CopyIdBtn, "NO CLIP")
	end
end)

bind(CopyLinkBtn.MouseButton1Click, function()
	if type(setclipboard) == "function" then
		setclipboard("https://www.roblox.com/users/" .. tostring(SelectedUserId) .. "/profile")
		flashButton(CopyLinkBtn, "COPIED")
	else
		flashButton(CopyLinkBtn, "NO CLIP")
	end
end)

bind(CopyDumpBtn.MouseButton1Click, function()
	if type(setclipboard) == "function" then
		setclipboard(LastExportText)
		flashButton(CopyDumpBtn, "COPIED")
	else
		flashButton(CopyDumpBtn, "NO CLIP")
	end
end)

local dragging = false
local dragStart, startPos

bind(TopBar.InputBegan, function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position
	end
end)

bind(UserInputService.InputChanged, function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		MainFrame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

bind(UserInputService.InputEnded, function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

local function toggleWindow(visible)
	if visible == nil then
		visible = not MainFrame.Visible
	end
	if visible then
		MainFrame.Visible = true
		AnimScale.Scale = 0.92
		TweenService:Create(AnimScale, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 1 }):Play()
	else
		local tw = TweenService:Create(AnimScale, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Scale = 0.92 })
		tw:Play()
		tw.Completed:Connect(function()
			if not MainFrame.Visible or AnimScale.Scale < 0.95 then
				MainFrame.Visible = false
				AnimScale.Scale = 1
			end
		end)
	end
end

bind(MinBtn.MouseButton1Click, function()
	Minimized = not Minimized
	if Minimized then
		TweenService:Create(MainFrame, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 660, 0, 32),
		}):Play()
		Content.Visible = false
		MinBtn.Text = "+"
	else
		Content.Visible = true
		TweenService:Create(MainFrame, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 660, 0, 440),
		}):Play()
		MinBtn.Text = "-"
	end
end)

bind(CloseBtn.MouseButton1Click, function()
	toggleWindow(false)
end)

bind(UserInputService.InputBegan, function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
		toggleWindow()
	end
end)

bind(Players.PlayerAdded, refreshRoster)
bind(Players.PlayerRemoving, function(plr)
	task.defer(refreshRoster)
	if SelectedPlayer == plr then
		SelectedPlayer = nil
		BadgeRow.Text = string.format("ID: %d | LEFT SERVER", plr.UserId)
	end
end)

local function updateDynamicTheme()
	local activeAccent = getWasorAccent()
	if Palette.Accent == activeAccent then
		return
	end
	Palette.Accent = activeAccent
	TopAccentLine.BackgroundColor3 = activeAccent
	TitleIcon.BackgroundColor3 = activeAccent
	SearchGo.BackgroundColor3 = activeAccent
	AvatarStroke.Color = activeAccent
	UsernameLabel.TextColor3 = activeAccent
	CopyDumpBtn.TextColor3 = activeAccent
	for _, sec in ipairs(SectionHeaders) do
		if sec.Dot then sec.Dot.BackgroundColor3 = activeAccent end
		if sec.Title then sec.Title.TextColor3 = activeAccent end
	end
	for _, btn in ipairs(RosterButtons) do
		if btn:GetAttribute("UserId") == SelectedUserId then
			local str = btn:FindFirstChildOfClass("UIStroke")
			if str then str.Color = activeAccent end
			local sbar = btn:FindFirstChild("SelBar")
			if sbar then sbar.BackgroundColor3 = activeAccent end
		end
	end
end

local themeTimer = 0
local telemetryAccum = 0
bind(RunService.Heartbeat, function(dt)
	themeTimer = themeTimer + dt
	if themeTimer >= 0.5 then
		themeTimer = 0
		updateDynamicTheme()
	end

	telemetryAccum = telemetryAccum + dt
	if telemetryAccum < 0.25 then
		return
	end
	telemetryAccum = 0

	local target = SelectedPlayer
	if not target or not target.Parent then
		ValState.Text = "Not in current server"
		ValState.TextColor3 = Palette.Muted
		ValRig.Text = "-"
		ValMovement.Text = "-"
		ValPosition.Text = "-"
		return
	end

	local char = target.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart")

	if not char or not hum then
		ValState.Text = "Spawning / No Character"
		ValState.TextColor3 = Palette.Warn
		ValRig.Text = "-"
		ValMovement.Text = "-"
		ValPosition.Text = "-"
		return
	end

	local alive = hum.Health > 0
	ValState.Text = alive and "Active / Spawned" or "Dead"
	ValState.TextColor3 = alive and Palette.Good or Palette.Bad

	local rigName = tostring(hum.RigType):gsub("Enum%.HumanoidRigType%.", "")
	ValRig.Text = string.format("%s | %.0f / %.0f HP", rigName, hum.Health, hum.MaxHealth)

	local jumpVal = hum.UseJumpPower and ("JP: " .. math.floor(hum.JumpPower)) or ("JH: " .. string.format("%.1f", hum.JumpHeight))
	ValMovement.Text = string.format("WS: %d | %s", math.floor(hum.WalkSpeed), jumpVal)

	if root then
		local p = root.Position
		ValPosition.Text = string.format("%.1f, %.1f, %.1f", p.X, p.Y, p.Z)
	else
		ValPosition.Text = "No RootPart"
	end
end)

if VH and VH.UI and VH.UI.registerModule then
	VH.UI.registerModule("Player", "Player Checker", 160, 50, false, false, nil, function(drawer)
		if VH.UI.addButtonOption then
			VH.UI.addButtonOption(drawer, "Open Account Inspector", function()
				toggleWindow(true)
			end)
			VH.UI.addButtonOption(drawer, "Inspect Self", function()
				inspectTarget(LocalPlayer, LocalPlayer.UserId)
				refreshRoster()
				toggleWindow(true)
			end)
			VH.UI.addButtonOption(drawer, "Refresh Roster", function()
				refreshRoster()
			end)
			VH.UI.addButtonOption(drawer, "Copy Profile Link", function()
				if type(setclipboard) == "function" then
					setclipboard("https://www.roblox.com/users/" .. tostring(SelectedUserId) .. "/profile")
					if VH.Utils and VH.Utils.notify then
						VH.Utils.notify("Profile link copied to clipboard!", Palette.Good)
					end
				end
			end)
			VH.UI.addButtonOption(drawer, "Copy Account Dump", function()
				if type(setclipboard) == "function" then
					setclipboard(LastExportText)
					if VH.Utils and VH.Utils.notify then
						VH.Utils.notify("Account dump copied to clipboard!", Palette.Good)
					end
				end
			end)
		end
	end)
end

inspectTarget(LocalPlayer, LocalPlayer.UserId)
refreshRoster()

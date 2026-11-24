--[[
    lowsime - Window Component
    Finestra principale Dark minimal con accento viola (#5A4078)
]]

local UserInputService = game:GetService("UserInputService")
local Theme = require(script.Parent.Parent.core.Theme)
local Animations = require(script.Parent.Parent.core.Animations)
local Utils = require(script.Parent.Parent.core.Utils)
local Tab = require(script.Parent.Tab)

local Window = {}
Window.__index = Window

function Window.new(config)
    config = config or {}
    local self = setmetatable({}, Window)

    local title = config.Title or "lowsime"
    local subTitle = config.SubTitle or "v1.0.0"
    local toggleKey = config.ToggleKey or Enum.KeyCode.RightControl
    local size = config.Size or UDim2.new(0, 560, 0, 380)

    self.Tabs = {}
    self.ActiveTab = nil
    self.IsOpen = true
    self.OriginalSize = size

    -- ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "lowsime_Gui"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = Utils:GetSafeGuiParent()
    self.ScreenGui = screenGui

    -- Main Container Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.BackgroundColor3 = Theme.Background
    mainFrame.Position = UDim2.new(0.5, -size.X.Offset / 2, 0.5, -size.Y.Offset / 2)
    mainFrame.Size = size
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    self.MainFrame = mainFrame

    -- Angoli arrotondati e bordo minimal
    local corner = Instance.new("UICorner")
    corner.CornerRadius = Theme.CornerRadius
    corner.Parent = mainFrame

    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = Theme.Border
    stroke.Thickness = 1
    stroke.Parent = mainFrame

    -- [[ TOPBAR ]]
    local topbar = Instance.new("Frame")
    topbar.Name = "Topbar"
    topbar.BackgroundColor3 = Theme.Sidebar
    topbar.BorderSizePixel = 0
    topbar.Size = UDim2.new(1, 0, 0, 38)
    topbar.Parent = mainFrame

    local topbarDivider = Instance.new("Frame")
    topbarDivider.Name = "Divider"
    topbarDivider.BackgroundColor3 = Theme.Separator
    topbarDivider.BorderSizePixel = 0
    topbarDivider.Position = UDim2.new(0, 0, 1, -1)
    topbarDivider.Size = UDim2.new(1, 0, 0, 1)
    topbarDivider.Parent = topbar

    -- Brand dot viola (#5A4078)
    local brandDot = Instance.new("Frame")
    brandDot.Name = "BrandDot"
    brandDot.BackgroundColor3 = Theme.Accent
    brandDot.Position = UDim2.new(0, 14, 0.5, -4)
    brandDot.Size = UDim2.new(0, 8, 0, 8)
    brandDot.Parent = topbar

    local brandDotCorner = Instance.new("UICorner")
    brandDotCorner.CornerRadius = UDim.new(1, 0)
    brandDotCorner.Parent = brandDot

    -- Titolo Principale
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 28, 0, 0)
    titleLabel.Size = UDim2.new(0, 120, 1, 0)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = title
    titleLabel.TextColor3 = Theme.Text
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = topbar

    -- Badge Sottotitolo Minimal
    local subBadge = Instance.new("TextLabel")
    subBadge.Name = "SubTitle"
    subBadge.BackgroundColor3 = Theme.AccentSubtle
    subBadge.Position = UDim2.new(0, 95, 0.5, -8)
    subBadge.Size = UDim2.new(0, 52, 0, 16)
    subBadge.Font = Enum.Font.GothamBold
    subBadge.Text = subTitle
    subBadge.TextColor3 = Theme.TextAccent
    subBadge.TextSize = 10
    subBadge.Parent = topbar

    local subBadgeCorner = Instance.new("UICorner")
    subBadgeCorner.CornerRadius = Theme.SmallCorner
    subBadgeCorner.Parent = subBadge

    -- Pulsante Chiudi
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.BackgroundTransparency = 1
    closeBtn.Position = UDim2.new(1, -32, 0, 0)
    closeBtn.Size = UDim2.new(0, 32, 1, 0)
    closeBtn.Font = Enum.Font.GothamMedium
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Theme.TextMuted
    closeBtn.TextSize = 13
    closeBtn.Parent = topbar

    closeBtn.MouseEnter:Connect(function()
        Animations:Tween(closeBtn, Animations.Speeds.Fast, Animations.Styles.Smooth, Enum.EasingDirection.Out, {
            TextColor3 = Color3.fromRGB(240, 90, 90)
        })
    end)
    closeBtn.MouseLeave:Connect(function()
        Animations:Tween(closeBtn, Animations.Speeds.Fast, Animations.Styles.Smooth, Enum.EasingDirection.Out, {
            TextColor3 = Theme.TextMuted
        })
    end)
    closeBtn.MouseButton1Click:Connect(function()
        self:Toggle()
    end)

    -- Trascinamento con Topbar
    Utils:MakeDraggable(topbar, mainFrame)

    -- [[ BODY / LAYOUT ]]
    -- Sidebar a sinistra per le Schede
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.BackgroundColor3 = Theme.Sidebar
    sidebar.BorderSizePixel = 0
    sidebar.Position = UDim2.new(0, 0, 0, 38)
    sidebar.Size = UDim2.new(0, 150, 1, -38)
    sidebar.Parent = mainFrame

    local sidebarDivider = Instance.new("Frame")
    sidebarDivider.Name = "Divider"
    sidebarDivider.BackgroundColor3 = Theme.Separator
    sidebarDivider.BorderSizePixel = 0
    sidebarDivider.Position = UDim2.new(1, -1, 0, 0)
    sidebarDivider.Size = UDim2.new(0, 1, 1, 0)
    sidebarDivider.Parent = sidebar

    local sidebarList = Instance.new("ScrollingFrame")
    sidebarList.Name = "List"
    sidebarList.BackgroundTransparency = 1
    sidebarList.BorderSizePixel = 0
    sidebarList.Position = UDim2.new(0, 0, 0, 0)
    sidebarList.Size = UDim2.new(1, -1, 1, 0)
    sidebarList.ScrollBarThickness = 0
    sidebarList.CanvasSize = UDim2.new(0, 0, 0, 0)
    sidebarList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sidebarList.Parent = sidebar
    self.SidebarList = sidebarList

    local sidebarLayout = Instance.new("UIListLayout")
    sidebarLayout.Padding = UDim.new(0, 4)
    sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sidebarLayout.Parent = sidebarList

    local sidebarPadding = Instance.new("UIPadding")
    sidebarPadding.PaddingTop = UDim.new(0, 10)
    sidebarPadding.PaddingLeft = UDim.new(0, 8)
    sidebarPadding.PaddingRight = UDim.new(0, 8)
    sidebarPadding.Parent = sidebarList

    -- Contenitore Pagine a destra
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.BackgroundTransparency = 1
    contentArea.Position = UDim2.new(0, 150, 0, 38)
    contentArea.Size = UDim2.new(1, -150, 1, -38)
    contentArea.Parent = mainFrame
    self.ContentArea = contentArea

    -- Gestione Tasto Toggle (Apertura/Chiusura)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == toggleKey then
            self:Toggle()
        end
    end)

    -- Animazione iniziale di comparsa
    Animations:OpenWindow(mainFrame, self.OriginalSize)

    return self
end

function Window:CreateTab(name, icon)
    local tab = Tab.new(name, icon, self)
    table.insert(self.Tabs, tab)

    if #self.Tabs == 1 then
        self:SelectTab(tab)
    end

    return tab
end

function Window:SelectTab(targetTab)
    if self.ActiveTab == targetTab then return end

    for _, tab in ipairs(self.Tabs) do
        if tab == targetTab then
            tab:Activate()
            self.ActiveTab = tab
        else
            tab:Deactivate()
        end
    end
end

function Window:Toggle()
    if self.IsOpen then
        Animations:CloseWindow(self.MainFrame, self.OriginalSize, function()
            self.IsOpen = false
        end)
    else
        Animations:OpenWindow(self.MainFrame, self.OriginalSize, function()
            self.IsOpen = true
        end)
    end
end

function Window:Destroy()
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
end

return Window


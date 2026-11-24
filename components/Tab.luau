--[[
    lowsime - Tab Component
    Gestione della scheda singola e del relativo pulsante nella sidebar
]]

local Theme = require(script.Parent.Parent.core.Theme)
local Animations = require(script.Parent.Parent.core.Animations)
local Elements = require(script.Parent.Elements)

local Tab = {}
Tab.__index = Tab

function Tab.new(name, icon, parentWindow)
    local self = setmetatable({}, Tab)
    self.Name = name
    self.Window = parentWindow
    self.Active = false

    -- Pulsante nella sidebar
    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = "TabBtn_" .. name
    tabBtn.BackgroundColor3 = Theme.Sidebar
    tabBtn.BackgroundTransparency = 1
    tabBtn.AutoButtonColor = false
    tabBtn.Size = UDim2.new(1, 0, 0, 34)
    tabBtn.Text = ""
    tabBtn.Parent = parentWindow.SidebarList

    local corner = Instance.new("UICorner")
    corner.CornerRadius = Theme.ElementCorner
    corner.Parent = tabBtn

    -- Indicatore verticale viola a sinistra
    local indicator = Instance.new("Frame")
    indicator.Name = "Indicator"
    indicator.BackgroundColor3 = Theme.Accent
    indicator.Position = UDim2.new(0, 0, 0.5, -7)
    indicator.Size = UDim2.new(0, 3, 0, 0)
    indicator.Visible = false
    indicator.Parent = tabBtn

    local indCorner = Instance.new("UICorner")
    indCorner.CornerRadius = UDim.new(1, 0)
    indCorner.Parent = indicator

    -- Titolo scheda
    local tabTitle = Instance.new("TextLabel")
    tabTitle.Name = "Title"
    tabTitle.BackgroundTransparency = 1
    tabTitle.Position = UDim2.new(0, 14, 0, 0)
    tabTitle.Size = UDim2.new(1, -20, 1, 0)
    tabTitle.Font = Enum.Font.GothamMedium
    tabTitle.Text = name
    tabTitle.TextColor3 = Theme.TextMuted
    tabTitle.TextSize = 13
    tabTitle.TextXAlignment = Enum.TextXAlignment.Left
    tabTitle.Parent = tabBtn

    -- Contenitore pagina (ScrollingFrame per gli elementi)
    local pageScroll = Instance.new("ScrollingFrame")
    pageScroll.Name = "Page_" .. name
    pageScroll.BackgroundTransparency = 1
    pageScroll.BorderSizePixel = 0
    pageScroll.Position = UDim2.new(0, 0, 0, 0)
    pageScroll.Size = UDim2.new(1, 0, 1, 0)
    pageScroll.ScrollBarThickness = 2
    pageScroll.ScrollBarImageColor3 = Theme.Accent
    pageScroll.ScrollBarImageTransparency = 0.5
    pageScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    pageScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    pageScroll.Visible = false
    pageScroll.Parent = parentWindow.ContentArea

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 8)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = pageScroll

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 12)
    padding.PaddingBottom = UDim.new(0, 16)
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)
    padding.Parent = pageScroll

    self.TabButton = tabBtn
    self.Indicator = indicator
    self.TitleLabel = tabTitle
    self.PageFrame = pageScroll

    -- Hover effect sul pulsante tab
    tabBtn.MouseEnter:Connect(function()
        if not self.Active then
            Animations:Tween(tabBtn, Animations.Speeds.Fast, Animations.Styles.Smooth, Enum.EasingDirection.Out, {
                BackgroundTransparency = 0.8,
                BackgroundColor3 = Theme.Container
            })
            Animations:Tween(tabTitle, Animations.Speeds.Fast, Animations.Styles.Smooth, Enum.EasingDirection.Out, {
                TextColor3 = Theme.Text
            })
        end
    end)

    tabBtn.MouseLeave:Connect(function()
        if not self.Active then
            Animations:Tween(tabBtn, Animations.Speeds.Fast, Animations.Styles.Smooth, Enum.EasingDirection.Out, {
                BackgroundTransparency = 1
            })
            Animations:Tween(tabTitle, Animations.Speeds.Fast, Animations.Styles.Smooth, Enum.EasingDirection.Out, {
                TextColor3 = Theme.TextMuted
            })
        end
    end)

    tabBtn.MouseButton1Click:Connect(function()
        parentWindow:SelectTab(self)
    end)

    return self
end

function Tab:Activate()
    self.Active = true
    self.PageFrame.Visible = true

    -- Fade in pagina
    self.PageFrame.CanvasPosition = Vector2.new(0, 0)

    -- Animazione pulsante attivo
    Animations:Tween(self.TabButton, Animations.Speeds.Fast, Animations.Styles.Smooth, Enum.EasingDirection.Out, {
        BackgroundTransparency = 0.4,
        BackgroundColor3 = Theme.Container
    })
    Animations:Tween(self.TitleLabel, Animations.Speeds.Fast, Animations.Styles.Smooth, Enum.EasingDirection.Out, {
        TextColor3 = Theme.Text
    })

    self.Indicator.Visible = true
    Animations:Tween(self.Indicator, Animations.Speeds.Normal, Animations.Styles.Bounce, Enum.EasingDirection.Out, {
        Size = UDim2.new(0, 3, 0, 16),
        Position = UDim2.new(0, 0, 0.5, -8)
    })
end

function Tab:Deactivate()
    self.Active = false
    self.PageFrame.Visible = false

    Animations:Tween(self.TabButton, Animations.Speeds.Fast, Animations.Styles.Smooth, Enum.EasingDirection.Out, {
        BackgroundTransparency = 1
    })
    Animations:Tween(self.TitleLabel, Animations.Speeds.Fast, Animations.Styles.Smooth, Enum.EasingDirection.Out, {
        TextColor3 = Theme.TextMuted
    })
    Animations:Tween(self.Indicator, Animations.Speeds.Fast, Animations.Styles.Smooth, Enum.EasingDirection.Out, {
        Size = UDim2.new(0, 3, 0, 0),
        Position = UDim2.new(0, 0, 0.5, 0)
    })
end

-- Costruttori per elementi all'interno del Tab
function Tab:AddSection(title)
    return Elements:CreateSection(self.PageFrame, title)
end

function Tab:AddButton(config)
    return Elements:CreateButton(self.PageFrame, config)
end

function Tab:AddToggle(config)
    return Elements:CreateToggle(self.PageFrame, config)
end

function Tab:AddSlider(config)
    return Elements:CreateSlider(self.PageFrame, config)
end

return Tab


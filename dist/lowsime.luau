--[[
    ══════════════════════════════════════════════════════════════════
    lowsime UI Library (Standalone Version for Solara & Roblox Luau)
    Design: Dark UI minimalista, viola #5A4078, transizioni fluide
    ══════════════════════════════════════════════════════════════════
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local Lowsime = {
    _VERSION = "1.0.0"
}

-- [[ THEME ]]
local Theme = {
    Accent = Color3.fromRGB(90, 64, 120),        -- #5A4078 Viola Principale
    AccentHover = Color3.fromRGB(115, 82, 153),   -- Viola chiaro hover
    AccentActive = Color3.fromRGB(75, 52, 100),   -- Viola attivo
    AccentSubtle = Color3.fromRGB(45, 32, 60),    -- Viola scuro per badge/dettagli
    Background = Color3.fromRGB(14, 14, 18),      -- Finestra principale
    Sidebar = Color3.fromRGB(18, 18, 23),         -- Sidebar per schede
    Container = Color3.fromRGB(22, 22, 28),       -- Card ed elementi
    ContainerHover = Color3.fromRGB(28, 27, 36),  -- Elemento in hover
    Input = Color3.fromRGB(18, 18, 23),           -- Slider track e input
    Border = Color3.fromRGB(36, 35, 45),          -- Bordo discreto
    BorderHover = Color3.fromRGB(90, 64, 120),    -- Bordo viola hover
    Separator = Color3.fromRGB(28, 28, 36),       -- Divisore
    Text = Color3.fromRGB(240, 240, 245),         -- Testo principale
    TextMuted = Color3.fromRGB(145, 143, 160),    -- Testo secondario
    TextAccent = Color3.fromRGB(175, 140, 220),   -- Testo viola
    CornerRadius = UDim.new(0, 8),
    ElementCorner = UDim.new(0, 6),
    SmallCorner = UDim.new(0, 4)
}

Lowsime.Theme = Theme

-- [[ ANIMATIONS ENGINE ]]
local Animations = {
    Speeds = {
        Fast = 0.15,
        Normal = 0.25,
        Slow = 0.4,
        OpenClose = 0.32,
    },
    Styles = {
        Smooth = Enum.EasingStyle.Quad,
        Bounce = Enum.EasingStyle.Back,
        Crisp = Enum.EasingStyle.Quart,
        Expo = Enum.EasingStyle.Exponential,
    }
}

function Animations:Tween(instance, duration, style, direction, properties)
    local tweenInfo = TweenInfo.new(
        duration or Animations.Speeds.Normal,
        style or Animations.Styles.Smooth,
        direction or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

function Animations:OpenWindow(frame, originalSize, callback)
    frame.Visible = true
    frame.Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset * 0.94, originalSize.Y.Scale, originalSize.Y.Offset * 0.94)
    local tween = Animations:Tween(frame, Animations.Speeds.OpenClose, Animations.Styles.Crisp, Enum.EasingDirection.Out, {
        Size = originalSize
    })
    if callback then tween.Completed:Connect(callback) end
end

function Animations:CloseWindow(frame, originalSize, callback)
    local targetSize = UDim2.new(originalSize.X.Scale, originalSize.X.Offset * 0.94, originalSize.Y.Scale, originalSize.Y.Offset * 0.94)
    local tween = Animations:Tween(frame, Animations.Speeds.Fast, Animations.Styles.Smooth, Enum.EasingDirection.In, {
        Size = targetSize
    })
    tween.Completed:Connect(function()
        frame.Visible = false
        frame.Size = originalSize
        if callback then callback() end
    end)
end

Lowsime.Animations = Animations

-- [[ UTILS ]]
local Utils = {}

function Utils:GetSafeGuiParent()
    local success, result = pcall(function()
        if typeof(gethui) == "function" then
            return gethui()
        end
        return CoreGui
    end)

    if success and result then return result end

    local localPlayer = Players.LocalPlayer
    if localPlayer then
        return localPlayer:WaitForChild("PlayerGui")
    end
    return CoreGui
end

function Utils:MakeDraggable(topbar, mainFrame)
    local dragging = false
    local dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        local targetPosition = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
        TweenService:Create(
            mainFrame,
            TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { Position = targetPosition }
        ):Play()
    end

    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- [[ ELEMENTS ]]
local Elements = {}

function Elements:CreateSection(container, title)
    local sectionFrame = Instance.new("Frame")
    sectionFrame.Name = "Section_" .. title
    sectionFrame.BackgroundTransparency = 1
    sectionFrame.Size = UDim2.new(1, 0, 0, 26)
    sectionFrame.Parent = container

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, 0, 1, 0)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = string.upper(title)
    titleLabel.TextColor3 = Theme.AccentHover
    titleLabel.TextSize = 11
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = sectionFrame

    local divider = Instance.new("Frame")
    divider.Name = "Divider"
    divider.BackgroundColor3 = Theme.Separator
    divider.BorderSizePixel = 0
    divider.Position = UDim2.new(0, 0, 1, -2)
    divider.Size = UDim2.new(1, 0, 0, 1)
    divider.Parent = sectionFrame

    return sectionFrame
end

function Elements:CreateButton(container, config)
    config = config or {}
    local text = config.Title or "Button"
    local desc = config.Description
    local callback = config.Callback or function() end
    local height = desc and 44 or 36

    local btnFrame = Instance.new("TextButton")
    btnFrame.Name = "Button_" .. text
    btnFrame.BackgroundColor3 = Theme.Container
    btnFrame.AutoButtonColor = false
    btnFrame.Size = UDim2.new(1, 0, 0, height)
    btnFrame.Text = ""
    btnFrame.Parent = container

    local corner = Instance.new("UICorner")
    corner.CornerRadius = Theme.ElementCorner
    corner.Parent = btnFrame

    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = Theme.Border
    stroke.Thickness = 1
    stroke.Parent = btnFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = desc and UDim2.new(0, 12, 0, 6) or UDim2.new(0, 12, 0, 0)
    titleLabel.Size = desc and UDim2.new(1, -24, 0, 18) or UDim2.new(1, -24, 1, 0)
    titleLabel.Font = Enum.Font.GothamMedium
    titleLabel.Text = text
    titleLabel.TextColor3 = Theme.Text
    titleLabel.TextSize = 13
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = btnFrame

    if desc then
        local descLabel = Instance.new("TextLabel")
        descLabel.Name = "Description"
        descLabel.BackgroundTransparency = 1
        descLabel.Position = UDim2.new(0, 12, 0, 24)
        descLabel.Size = UDim2.new(1, -24, 0, 14)
        descLabel.Font = Enum.Font.Gotham
        descLabel.Text = desc
        descLabel.TextColor3 = Theme.TextMuted
        descLabel.TextSize = 11
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.Parent = btnFrame
    end

    local arrow = Instance.new("TextLabel")
    arrow.Name = "Arrow"
    arrow.BackgroundTransparency = 1
    arrow.Position = UDim2.new(1, -26, 0.5, -8)
    arrow.Size = UDim2.new(0, 16, 0, 16)
    arrow.Font = Enum.Font.GothamBold
    arrow.Text = ">"
    arrow.TextColor3 = Theme.TextMuted
    arrow.TextSize = 12
    arrow.Parent = btnFrame

    btnFrame.MouseEnter:Connect(function()
        Animations:Tween(btnFrame, Animations.Speeds.Fast, Animations.Styles.Smooth, Enum.EasingDirection.Out, {
            BackgroundColor3 = Theme.ContainerHover
        })
        Animations:Tween(stroke, Animations.Speeds.Fast, Animations.Styles.Smooth, Enum.EasingDirection.Out, {
            Color = Theme.BorderHover
        })
        Animations:Tween(arrow, Animations.Speeds.Fast, Animations.Styles.Smooth, Enum.EasingDirection.Out, {
            TextColor3 = Theme.AccentHover,
            Position = UDim2.new(1, -22, 0.5, -8)
        })
    end)

    btnFrame.MouseLeave:Connect(function()
        Animations:Tween(btnFrame, Animations.Speeds.Fast, Animations.Styles.Smooth, Enum.EasingDirection.Out, {
            BackgroundColor3 = Theme.Container
        })
        Animations:Tween(stroke, Animations.Speeds.Fast, Animations.Styles.Smooth, Enum.EasingDirection.Out, {
            Color = Theme.Border
        })
        Animations:Tween(arrow, Animations.Speeds.Fast, Animations.Styles.Smooth, Enum.EasingDirection.Out, {
            TextColor3 = Theme.TextMuted,
            Position = UDim2.new(1, -26, 0.5, -8)
        })
    end)

    btnFrame.MouseButton1Down:Connect(function()
        Animations:Tween(btnFrame, 0.08, Animations.Styles.Smooth, Enum.EasingDirection.Out, {
            BackgroundColor3 = Theme.AccentSubtle
        })
    end)

    btnFrame.MouseButton1Up:Connect(function()
        Animations:Tween(btnFrame, 0.12, Animations.Styles.Smooth, Enum.EasingDirection.Out, {
            BackgroundColor3 = Theme.ContainerHover
        })
        pcall(callback)
    end)

    return btnFrame
end

function Elements:CreateToggle(container, config)
    config = config or {}
    local text = config.Title or "Toggle"
    local desc = config.Description
    local state = config.Default or false
    local callback = config.Callback or function() end
    local height = desc and 44 or 38

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "Toggle_" .. text
    toggleBtn.BackgroundColor3 = Theme.Container
    toggleBtn.AutoButtonColor = false
    toggleBtn.Size = UDim2.new(1, 0, 0, height)
    toggleBtn.Text = ""
    toggleBtn.Parent = container

    local corner = Instance.new("UICorner")
    corner.CornerRadius = Theme.ElementCorner
    corner.Parent = toggleBtn

    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = Theme.Border
    stroke.Thickness = 1
    stroke.Parent = toggleBtn

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = desc and UDim2.new(0, 12, 0, 6) or UDim2.new(0, 12, 0, 0)
    titleLabel.Size = desc and UDim2.new(1, -65, 0, 18) or UDim2.new(1, -65, 1, 0)
    titleLabel.Font = Enum.Font.GothamMedium
    titleLabel.Text = text
    titleLabel.TextColor3 = Theme.Text
    titleLabel.TextSize = 13
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = toggleBtn

    if desc then
        local descLabel = Instance.new("TextLabel")
        descLabel.Name = "Description"
        descLabel.BackgroundTransparency = 1
        descLabel.Position = UDim2.new(0, 12, 0, 24)
        descLabel.Size = UDim2.new(1, -65, 0, 14)
        descLabel.Font = Enum.Font.Gotham
        descLabel.Text = desc
        descLabel.TextColor3 = Theme.TextMuted
        descLabel.TextSize = 11
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.Parent = toggleBtn
    end

    local switch = Instance.new("Frame")
    switch.Name = "Switch"
    switch.BackgroundColor3 = state and Theme.Accent or Theme.Input
    switch.Position = UDim2.new(1, -48, 0.5, -10)
    switch.Size = UDim2.new(0, 36, 0, 20)
    switch.Parent = toggleBtn

    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(1, 0)
    switchCorner.Parent = switch

    local switchStroke = Instance.new("UIStroke")
    switchStroke.Color = state and Theme.AccentHover or Theme.Border
    switchStroke.Thickness = 1
    switchStroke.Parent = switch

    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.BackgroundColor3 = Theme.Text
    knob.Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Parent = switch

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local function updateState(newState)
        state = newState
        local targetKnobPos = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        local targetSwitchBg = state and Theme.Accent or Theme.Input
        local targetStrokeColor = state and Theme.AccentHover or Theme.Border

        Animations:Tween(knob, Animations.Speeds.Fast, Animations.Styles.Crisp, Enum.EasingDirection.Out, {
            Position = targetKnobPos
        })
        Animations:Tween(switch, Animations.Speeds.Fast, Animations.Styles.Smooth, Enum.EasingDirection.Out, {
            BackgroundColor3 = targetSwitchBg
        })
        Animations:Tween(switchStroke, Animations.Speeds.Fast, Animations.Styles.Smooth, Enum.EasingDirection.Out, {
            Color = targetStrokeColor
        })

        pcall(callback, state)
    end

    toggleBtn.MouseEnter:Connect(function()
        Animations:Tween(toggleBtn, Animations.Speeds.Fast, Animations.Styles.Smooth, Enum.EasingDirection.Out, {
            BackgroundColor3 = Theme.ContainerHover
        })
    end)
    toggleBtn.MouseLeave:Connect(function()
        Animations:Tween(toggleBtn, Animations.Speeds.Fast, Animations.Styles.Smooth, Enum.EasingDirection.Out, {
            BackgroundColor3 = Theme.Container
        })
    end)
    toggleBtn.MouseButton1Click:Connect(function()
        updateState(not state)
    end)

    return {
        Instance = toggleBtn,
        SetValue = function(self, val) updateState(val) end,
        GetValue = function(self) return state end,
    }
end

function Elements:CreateSlider(container, config)
    config = config or {}
    local text = config.Title or "Slider"
    local min = config.Min or 0
    local max = config.Max or 100
    local default = math.clamp(config.Default or min, min, max)
    local precise = config.Precise or false
    local callback = config.Callback or function() end

    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = "Slider_" .. text
    sliderFrame.BackgroundColor3 = Theme.Container
    sliderFrame.Size = UDim2.new(1, 0, 0, 48)
    sliderFrame.Parent = container

    local corner = Instance.new("UICorner")
    corner.CornerRadius = Theme.ElementCorner
    corner.Parent = sliderFrame

    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = Theme.Border
    stroke.Thickness = 1
    stroke.Parent = sliderFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 12, 0, 6)
    titleLabel.Size = UDim2.new(1, -70, 0, 18)
    titleLabel.Font = Enum.Font.GothamMedium
    titleLabel.Text = text
    titleLabel.TextColor3 = Theme.Text
    titleLabel.TextSize = 13
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = sliderFrame

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "Value"
    valueLabel.BackgroundTransparency = 1
    valueLabel.Position = UDim2.new(1, -60, 0, 6)
    valueLabel.Size = UDim2.new(0, 48, 0, 18)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Theme.TextAccent
    valueLabel.TextSize = 12
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = sliderFrame

    local track = Instance.new("TextButton")
    track.Name = "Track"
    track.BackgroundColor3 = Theme.Input
    track.AutoButtonColor = false
    track.Text = ""
    track.Position = UDim2.new(0, 12, 0, 32)
    track.Size = UDim2.new(1, -24, 0, 6)
    track.Parent = sliderFrame

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.BackgroundColor3 = Theme.Accent
    local initRatio = (default - min) / (max - min)
    fill.Size = UDim2.new(initRatio, 0, 1, 0)
    fill.BorderSizePixel = 0
    fill.Parent = track

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local dragging = false
    local currentValue = default

    local function setValue(val, skipCallback)
        currentValue = math.clamp(val, min, max)
        if not precise then
            currentValue = math.floor(currentValue + 0.5)
        else
            currentValue = math.floor(currentValue * 100) / 100
        end

        local ratio = (currentValue - min) / (max - min)
        Animations:Tween(fill, 0.08, Animations.Styles.Smooth, Enum.EasingDirection.Out, {
            Size = UDim2.new(ratio, 0, 1, 0)
        })
        valueLabel.Text = tostring(currentValue)

        if not skipCallback then
            pcall(callback, currentValue)
        end
    end

    local function updateFromInput(input)
        local absPos = track.AbsolutePosition.X
        local absSize = track.AbsoluteSize.X
        local mouseX = input.Position.X
        local relative = math.clamp((mouseX - absPos) / absSize, 0, 1)
        local targetVal = min + (max - min) * relative
        setValue(targetVal)
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromInput(input)
            Animations:Tween(fill, 0.1, Animations.Styles.Smooth, Enum.EasingDirection.Out, {
                BackgroundColor3 = Theme.AccentHover
            })
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                dragging = false
                Animations:Tween(fill, 0.15, Animations.Styles.Smooth, Enum.EasingDirection.Out, {
                    BackgroundColor3 = Theme.Accent
                })
            end
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromInput(input)
        end
    end)

    return {
        Instance = sliderFrame,
        SetValue = function(self, val) setValue(val) end,
        GetValue = function(self) return currentValue end,
    }
end

-- [[ TAB CLASS ]]
local Tab = {}
Tab.__index = Tab

function Tab.new(name, parentWindow)
    local self = setmetatable({}, Tab)
    self.Name = name
    self.Window = parentWindow
    self.Active = false

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
    self.PageFrame.CanvasPosition = Vector2.new(0, 0)

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

-- [[ WINDOW CLASS ]]
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

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "lowsime_Gui"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = Utils:GetSafeGuiParent()
    self.ScreenGui = screenGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.BackgroundColor3 = Theme.Background
    mainFrame.Position = UDim2.new(0.5, -size.X.Offset / 2, 0.5, -size.Y.Offset / 2)
    mainFrame.Size = size
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    self.MainFrame = mainFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = Theme.CornerRadius
    corner.Parent = mainFrame

    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = Theme.Border
    stroke.Thickness = 1
    stroke.Parent = mainFrame

    -- Topbar
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

    local brandDot = Instance.new("Frame")
    brandDot.Name = "BrandDot"
    brandDot.BackgroundColor3 = Theme.Accent
    brandDot.Position = UDim2.new(0, 14, 0.5, -4)
    brandDot.Size = UDim2.new(0, 8, 0, 8)
    brandDot.Parent = topbar

    local brandDotCorner = Instance.new("UICorner")
    brandDotCorner.CornerRadius = UDim.new(1, 0)
    brandDotCorner.Parent = brandDot

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

    Utils:MakeDraggable(topbar, mainFrame)

    -- Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.BackgroundColor3 = Theme.Sidebar
    sidebar.BorderSizePixel = 0
    sidebar.Position = UDim2.new(0, 0, 0, 38)
    sidebar.Size = UDim2.new(0, 140, 1, -38)
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

    -- Content Area
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.BackgroundTransparency = 1
    contentArea.Position = UDim2.new(0, 140, 0, 38)
    contentArea.Size = UDim2.new(1, -140, 1, -38)
    contentArea.Parent = mainFrame
    self.ContentArea = contentArea

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == toggleKey then
            self:Toggle()
        end
    end)

    Animations:OpenWindow(mainFrame, self.OriginalSize)
    return self
end

function Window:CreateTab(name)
    local tab = Tab.new(name, self)
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

function Lowsime:CreateWindow(config)
    return Window.new(config)
end

return Lowsime


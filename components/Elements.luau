--[[
    lowsime - Elements Library
    Componenti minimali: Button, Toggle, Slider, Dropdown, Textbox, Keybind, Section
]]

local UserInputService = game:GetService("UserInputService")
local Theme = require(script.Parent.Parent.core.Theme)
local Animations = require(script.Parent.Parent.core.Animations)

local Elements = {}

-- [[ SECTION HEADER ]]
function Elements:CreateSection(container, title)
    local sectionFrame = Instance.new("Frame")
    sectionFrame.Name = "Section_" .. title
    sectionFrame.BackgroundTransparency = 1
    sectionFrame.Size = UDim2.new(1, 0, 0, 28)
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

-- [[ BUTTON COMPONENT ]]
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

    -- Icona click minimal
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

    -- Animazioni Hover & Click
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
        callback()
    end)

    return btnFrame
end

-- [[ TOGGLE COMPONENT ]]
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

    -- Switch Box
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

    -- Switch Knob
    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.BackgroundColor3 = Theme.Text
    knob.Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Parent = switch

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local function updateState(newState, skipAnim)
        state = newState
        local targetKnobPos = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        local targetSwitchBg = state and Theme.Accent or Theme.Input
        local targetStrokeColor = state and Theme.AccentHover or Theme.Border

        if skipAnim then
            knob.Position = targetKnobPos
            switch.BackgroundColor3 = targetSwitchBg
            switchStroke.Color = targetStrokeColor
        else
            Animations:Tween(knob, Animations.Speeds.Fast, Animations.Styles.Crisp, Enum.EasingDirection.Out, {
                Position = targetKnobPos
            })
            Animations:Tween(switch, Animations.Speeds.Fast, Animations.Styles.Smooth, Enum.EasingDirection.Out, {
                BackgroundColor3 = targetSwitchBg
            })
            Animations:Tween(switchStroke, Animations.Speeds.Fast, Animations.Styles.Smooth, Enum.EasingDirection.Out, {
                Color = targetStrokeColor
            })
        end
        callback(state)
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

-- [[ SLIDER COMPONENT ]]
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

    -- Slider Track Bar
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
            callback(currentValue)
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

return Elements


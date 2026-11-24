--[[
    lowsime - UI Context
    Gestisce finestre, notifiche e dialoghi per un'esperienza Roblox.
]]

local Theme = require(script.Parent.Parent.core.Theme)
local Animations = require(script.Parent.Parent.core.Animations)
local Utils = require(script.Parent.Parent.core.Utils)
local Window = require(script.Parent.Window)

local Context = {}
Context.__index = Context

local NOTIFICATION_LIMIT = 4
local NOTIFICATION_DURATION = 4

local function addCorner(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or Theme.ElementCorner
    corner.Parent = instance
    return corner
end

local function addStroke(instance, color)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Border
    stroke.Thickness = 1
    stroke.Parent = instance
    return stroke
end

function Context.new(config)
    config = config or {}

    local self = setmetatable({}, Context)
    self.Name = config.Name or "lowsime"
    self.Parent = Utils:GetSafeGuiParent(config.Parent)
    self._windows = {}
    self._notifications = {}
    self._alerts = {}
    self._notificationOrder = 0
    self._alertOrder = 0
    self._overlayGui = nil
    self._destroyed = false

    return self
end

function Context:_assertAlive()
    assert(not self._destroyed, "Cannot use a destroyed lowsime context")
end

function Context:_getOverlayGui()
    self:_assertAlive()
    if self._overlayGui and self._overlayGui.Parent then
        return self._overlayGui
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = self.Name .. "_Overlays"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 20
    gui.Parent = self.Parent
    self._overlayGui = gui
    return gui
end

function Context:CreateWindow(config)
    self:_assertAlive()
    local windowConfig = table.clone(config or {})
    windowConfig.Parent = windowConfig.Parent or self.Parent

    local window = Window.new(windowConfig)
    table.insert(self._windows, window)
    window._onDestroy = function(destroyedWindow)
        for index, current in ipairs(self._windows) do
            if current == destroyedWindow then
                table.remove(self._windows, index)
                break
            end
        end
    end
    return window
end

function Context:_getNotificationContainer()
    local gui = self:_getOverlayGui()
    local container = gui:FindFirstChild("Notifications")
    if container then
        return container
    end

    container = Instance.new("Frame")
    container.Name = "Notifications"
    container.AnchorPoint = Vector2.new(1, 0)
    container.BackgroundTransparency = 1
    container.Position = UDim2.new(1, -18, 0, 18)
    container.Size = UDim2.new(0, 320, 0, 0)
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.Parent = gui

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = container

    return container
end

function Context:Notify(config)
    self:_assertAlive()
    config = config or {}

    local title = config.Title or "Notification"
    local description = config.Description
    local duration = config.Duration or NOTIFICATION_DURATION
    assert(type(duration) == "number" and duration >= 0, "Notification Duration must be a non-negative number")
    assert(type(config.Type or "info") == "string", "Notification Type must be a string")

    while #self._notifications >= NOTIFICATION_LIMIT do
        self._notifications[1]:Destroy()
    end

    local toast = Instance.new("Frame")
    toast.Name = "Notification"
    toast.BackgroundColor3 = Theme.Container
    toast.BackgroundTransparency = 1
    toast.BorderSizePixel = 0
    toast.Size = UDim2.new(1, 0, 0, description and 70 or 52)
    self._notificationOrder += 1
    toast.LayoutOrder = -self._notificationOrder
    toast.Parent = self:_getNotificationContainer()
    addCorner(toast)

    local kind = string.lower(config.Type or "info")
    local accentColor = Theme.Accent
    if kind == "success" then
        accentColor = Color3.fromRGB(82, 178, 120)
    elseif kind == "warning" then
        accentColor = Color3.fromRGB(224, 172, 72)
    elseif kind == "error" then
        accentColor = Color3.fromRGB(220, 92, 92)
    end
    addStroke(toast, Theme.Border)

    local accent = Instance.new("Frame")
    accent.Name = "Accent"
    accent.BackgroundColor3 = accentColor
    accent.BorderSizePixel = 0
    accent.Position = UDim2.new(0, 0, 0, 8)
    accent.Size = UDim2.new(0, 3, 1, -16)
    accent.Parent = toast
    addCorner(accent, UDim.new(1, 0))

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 14, 0, 8)
    titleLabel.Size = UDim2.new(1, -26, 0, 18)
    titleLabel.Font = Enum.Font.GothamSemibold
    titleLabel.Text = title
    titleLabel.TextColor3 = Theme.Text
    titleLabel.TextSize = 13
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = toast

    if description then
        local descriptionLabel = Instance.new("TextLabel")
        descriptionLabel.Name = "Description"
        descriptionLabel.BackgroundTransparency = 1
        descriptionLabel.Position = UDim2.new(0, 14, 0, 30)
        descriptionLabel.Size = UDim2.new(1, -26, 0, 30)
        descriptionLabel.Font = Enum.Font.Gotham
        descriptionLabel.Text = description
        descriptionLabel.TextColor3 = Theme.TextMuted
        descriptionLabel.TextSize = 11
        descriptionLabel.TextWrapped = true
        descriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
        descriptionLabel.TextYAlignment = Enum.TextYAlignment.Top
        descriptionLabel.Parent = toast
    end

    local handle = {
        Instance = toast,
        _destroyed = false,
    }

    function handle:Destroy()
        if self._destroyed then
            return
        end
        self._destroyed = true
        for index, current in ipairs(self.Context._notifications) do
            if current == self then
                table.remove(self.Context._notifications, index)
                break
            end
        end
        if self.Instance then
            self.Instance:Destroy()
            self.Instance = nil
        end
    end
    handle.Context = self

    table.insert(self._notifications, handle)
    Animations:Tween(toast, Animations.Speeds.Normal, Animations.Styles.Smooth, Enum.EasingDirection.Out, {
        BackgroundTransparency = 0,
    })

    if duration > 0 then
        task.delay(duration, function()
            handle:Destroy()
        end)
    end

    return handle
end

function Context:Alert(config)
    self:_assertAlive()
    config = config or {}

    local title = config.Title or "Alert"
    local description = config.Description or ""
    local actions = config.Actions or {
        { Text = "OK", Primary = true },
    }
    assert(type(actions) == "table" and #actions > 0, "Alert Actions must contain at least one action")
    for _, action in ipairs(actions) do
        assert(type(action) == "table", "Each Alert action must be a table")
        assert(action.Callback == nil or type(action.Callback) == "function", "Alert action Callback must be a function")
    end
    assert(#actions <= 3, "Alert supports at most three actions")

    local gui = self:_getOverlayGui()
    self._alertOrder += 1
    local shade = Instance.new("TextButton")
    shade.Name = "AlertOverlay"
    shade.AutoButtonColor = false
    shade.BackgroundColor3 = Color3.new(0, 0, 0)
    shade.BackgroundTransparency = 0.4
    shade.BorderSizePixel = 0
    shade.Size = UDim2.fromScale(1, 1)
    shade.Text = ""
    shade.ZIndex = 10 + self._alertOrder * 10
    shade.Parent = gui

    local card = Instance.new("Frame")
    card.Name = "Dialog"
    card.AnchorPoint = Vector2.new(0.5, 0.5)
    card.BackgroundColor3 = Theme.Background
    card.BorderSizePixel = 0
    card.Active = true
    card.Position = UDim2.fromScale(0.5, 0.5)
    card.Size = UDim2.new(0.9, 0, 0, description == "" and 142 or 176)
    card.ZIndex = shade.ZIndex + 1
    card.Parent = shade
    addCorner(card, Theme.CornerRadius)
    addStroke(card)

    local sizeConstraint = Instance.new("UISizeConstraint")
    sizeConstraint.MaxSize = Vector2.new(420, 240)
    sizeConstraint.Parent = card

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 20, 0, 18)
    titleLabel.Size = UDim2.new(1, -40, 0, 22)
    titleLabel.Font = Enum.Font.GothamSemibold
    titleLabel.Text = title
    titleLabel.TextColor3 = Theme.Text
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = card.ZIndex + 1
    titleLabel.Parent = card

    if description ~= "" then
        local descriptionLabel = Instance.new("TextLabel")
        descriptionLabel.Name = "Description"
        descriptionLabel.BackgroundTransparency = 1
        descriptionLabel.Position = UDim2.new(0, 20, 0, 48)
        descriptionLabel.Size = UDim2.new(1, -40, 0, 42)
        descriptionLabel.Font = Enum.Font.Gotham
        descriptionLabel.Text = description
        descriptionLabel.TextColor3 = Theme.TextMuted
        descriptionLabel.TextSize = 12
        descriptionLabel.TextWrapped = true
        descriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
        descriptionLabel.TextYAlignment = Enum.TextYAlignment.Top
        descriptionLabel.ZIndex = card.ZIndex + 1
        descriptionLabel.Parent = card
    end

    local actionContainer = Instance.new("Frame")
    actionContainer.Name = "Actions"
    actionContainer.AnchorPoint = Vector2.new(1, 1)
    actionContainer.BackgroundTransparency = 1
    actionContainer.Position = UDim2.new(1, -20, 1, -16)
    actionContainer.Size = UDim2.new(1, -40, 0, 34)
    actionContainer.ZIndex = card.ZIndex + 1
    actionContainer.Parent = card

    local actionLayout = Instance.new("UIListLayout")
    actionLayout.FillDirection = Enum.FillDirection.Horizontal
    actionLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    actionLayout.Padding = UDim.new(0, 8)
    actionLayout.SortOrder = Enum.SortOrder.LayoutOrder
    actionLayout.Parent = actionContainer

    local handle = {
        Instance = shade,
        _destroyed = false,
    }

    function handle:Close()
        if self._destroyed then
            return
        end
        self._destroyed = true
        for index, current in ipairs(self.Context._alerts) do
            if current == self then
                table.remove(self.Context._alerts, index)
                break
            end
        end
        if self.Instance then
            self.Instance:Destroy()
            self.Instance = nil
        end
    end
    handle.Destroy = handle.Close
    handle.Context = self

    table.insert(self._alerts, handle)
    shade.MouseButton1Click:Connect(function()
        if config.Cancelable then
            handle:Close()
        end
    end)

    for index, action in ipairs(actions) do
        local button = Instance.new("TextButton")
        button.Name = "Action_" .. index
        button.AutoButtonColor = false
        button.BackgroundColor3 = action.Primary and Theme.Accent or Theme.Container
        button.BorderSizePixel = 0
        button.Size = UDim2.new(0, 96, 1, 0)
        button.Font = Enum.Font.GothamMedium
        button.Text = action.Text or "OK"
        button.TextColor3 = Theme.Text
        button.TextSize = 12
        button.ZIndex = actionContainer.ZIndex + 1
        button.Parent = actionContainer
        addCorner(button, Theme.SmallCorner)

        button.MouseButton1Click:Connect(function()
            handle:Close()
            if action.Callback then
                action.Callback()
            end
        end)
    end

    return handle
end

function Context:Destroy()
    if self._destroyed then
        return
    end
    self._destroyed = true

    for _, window in ipairs(table.clone(self._windows)) do
        window:Destroy()
    end
    for _, notification in ipairs(table.clone(self._notifications)) do
        notification:Destroy()
    end
    for _, alert in ipairs(table.clone(self._alerts)) do
        alert:Close()
    end

    if self._overlayGui then
        self._overlayGui:Destroy()
        self._overlayGui = nil
    end
end

Context.createWindow = Context.CreateWindow
Context.notify = Context.Notify
Context.alert = Context.Alert
Context.destroy = Context.Destroy

return Context

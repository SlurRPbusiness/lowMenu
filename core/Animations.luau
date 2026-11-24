--[[
    lowsime - Animations Engine
    Gestione animazioni fluide con TweenService (apertura, chiusura, hover, ripple)
]]

local TweenService = game:GetService("TweenService")

local Animations = {}

-- Configurazioni predefinite per transizioni fluide
Animations.Speeds = {
    Fast = 0.15,
    Normal = 0.25,
    Slow = 0.4,
    OpenClose = 0.35,
}

Animations.Styles = {
    Smooth = Enum.EasingStyle.Quad,
    Bounce = Enum.EasingStyle.Back,
    Crisp = Enum.EasingStyle.Quart,
    Expo = Enum.EasingStyle.Exponential,
}

-- Funzione generica per creare ed eseguire un tween
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

-- Animazione Hover per pulsanti e card
function Animations:AttachHover(instance, normalProps, hoverProps, duration)
    duration = duration or Animations.Speeds.Fast

    instance.MouseEnter:Connect(function()
        Animations:Tween(instance, duration, Animations.Styles.Smooth, Enum.EasingDirection.Out, hoverProps)
    end)

    instance.MouseLeave:Connect(function()
        Animations:Tween(instance, duration, Animations.Styles.Smooth, Enum.EasingDirection.Out, normalProps)
    end)
end

-- Animazione Apertura Finestra (Fade + Scale In)
function Animations:OpenWindow(frame, originalSize, callback)
    frame.Visible = true
    frame.Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset * 0.92, originalSize.Y.Scale, originalSize.Y.Offset * 0.92)
    
    local canvasGroup = frame:FindFirstChildOfClass("CanvasGroup")
    if canvasGroup then
        canvasGroup.GroupTransparency = 1
        Animations:Tween(canvasGroup, Animations.Speeds.OpenClose, Animations.Styles.Expo, Enum.EasingDirection.Out, {
            GroupTransparency = 0
        })
    end

    local tween = Animations:Tween(frame, Animations.Speeds.OpenClose, Animations.Styles.Crisp, Enum.EasingDirection.Out, {
        Size = originalSize
    })

    if callback then
        tween.Completed:Connect(callback)
    end
end

-- Animazione Chiusura Finestra (Fade + Scale Out)
function Animations:CloseWindow(frame, originalSize, callback)
    local canvasGroup = frame:FindFirstChildOfClass("CanvasGroup")
    if canvasGroup then
        Animations:Tween(canvasGroup, Animations.Speeds.Fast, Animations.Styles.Smooth, Enum.EasingDirection.In, {
            GroupTransparency = 1
        })
    end

    local targetSize = UDim2.new(originalSize.X.Scale, originalSize.X.Offset * 0.94, originalSize.Y.Scale, originalSize.Y.Offset * 0.94)
    local tween = Animations:Tween(frame, Animations.Speeds.Fast, Animations.Styles.Smooth, Enum.EasingDirection.In, {
        Size = targetSize
    })

    tween.Completed:Connect(function()
        frame.Visible = false
        frame.Size = originalSize
        if callback then
            callback()
        end
    end)
end

return Animations


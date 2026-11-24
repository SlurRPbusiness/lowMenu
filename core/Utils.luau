--[[
    lowsime - Utilities
    Funzioni di supporto per l'interfaccia Roblox Studio
]]

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Utils = {}

function Utils:GetSafeGuiParent(parent)
    if parent ~= nil then
        assert(typeof(parent) == "Instance" and parent:IsA("PlayerGui"), "Parent must be a PlayerGui")
        return parent
    end

    local localPlayer = Players.LocalPlayer
    if not localPlayer then
        error("lowsime UI must be created from a client LocalScript", 2)
    end

    return localPlayer:WaitForChild("PlayerGui")
end

-- Rende un frame trascinabile con inerzia fluida (Smooth Drag)
function Utils:MakeDraggable(topbar, mainFrame)
    local dragging = false
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        local targetPosition = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )

        -- Transizione fluida della posizione
        game:GetService("TweenService"):Create(
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

return Utils


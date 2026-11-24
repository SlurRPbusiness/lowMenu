--[[
    lowsime - Utilities
    Funzioni di supporto, trascinamento finestra (Smooth Drag), supporto Solara/Executor
]]

local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local Utils = {}

-- Rileva il genitore UI sicuro compatibile con Solara / Executor
function Utils:GetSafeGuiParent()
    local success, result = pcall(function()
        -- Supporto per gethui (Roblox exploit standard: Solara, Wave, Synapse, etc.)
        if typeof(gethui) == "function" then
            return gethui()
        end
        return CoreGui
    end)

    if success and result then
        return result
    end

    -- Fallback per ambiente Studio o Player standard
    local localPlayer = Players.LocalPlayer
    if localPlayer then
        return localPlayer:WaitForChild("PlayerGui")
    end

    return CoreGui
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


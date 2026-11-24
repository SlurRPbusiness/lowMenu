--[[
    lowsime UI Library
    Libreria UI dark minimal con accento viola (#5A4078) per Luau & Solara Executor
]]

local Window = require(script.components.Window)
local Theme = require(script.core.Theme)
local Animations = require(script.core.Animations)

local Lowsime = {
    _VERSION = "1.0.0",
    Theme = Theme,
    Animations = Animations,
}

function Lowsime:CreateWindow(config)
    return Window.new(config)
end

return Lowsime


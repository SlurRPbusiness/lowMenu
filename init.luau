--[[
    lowsime UI Library
    Libreria UI dark minimal per esperienze Roblox create in Studio
]]

local Window = require(script.components.Window)
local Context = require(script.components.Context)
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

function Lowsime.createContext(contextOrConfig, config)
    if contextOrConfig == Lowsime then
        config = config or {}
    else
        config = contextOrConfig
    end
    return Context.new(config)
end

Lowsime.CreateContext = Lowsime.createContext

return Lowsime


--[[
    lowsime - Theme Configuration
    Dark UI minimalista con accento viola (#5A4078)
]]

local Theme = {
    -- Colori Principali
    Accent = Color3.fromRGB(90, 64, 120),        -- #5A4078 Viola Principale
    AccentHover = Color3.fromRGB(115, 82, 153),   -- Viola più chiaro per interazioni
    AccentActive = Color3.fromRGB(75, 52, 100),   -- Viola premuto/attivo
    AccentSubtle = Color3.fromRGB(45, 32, 60),    -- Viola scuro per sfondi accento

    -- Superfici e Sfondi Dark
    Background = Color3.fromRGB(14, 14, 18),      -- Finestra principale
    Sidebar = Color3.fromRGB(18, 18, 23),         -- Sidebar per schede
    Container = Color3.fromRGB(22, 22, 28),       -- Riquadri ed elementi
    ContainerHover = Color3.fromRGB(28, 27, 36),  -- Elemento in hover
    Input = Color3.fromRGB(18, 18, 23),           -- Campi input e slider track

    -- Bordi e Separatori Minimal
    Border = Color3.fromRGB(36, 35, 45),          -- Bordo discreto
    BorderHover = Color3.fromRGB(90, 64, 120),    -- Bordo in evidenza (viola)
    Separator = Color3.fromRGB(28, 28, 36),

    -- Testi
    Text = Color3.fromRGB(240, 240, 245),         -- Testo principale
    TextMuted = Color3.fromRGB(145, 143, 160),    -- Testo secondario / descrizioni
    TextDisabled = Color3.fromRGB(90, 88, 102),   -- Testo disabilitato
    TextAccent = Color3.fromRGB(175, 140, 220),   -- Testo evidenziato viola

    -- Tipografia e Misure
    Font = Font.fromEnum(Enum.Font.GothamMedium),
    FontBold = Font.fromEnum(Enum.Font.GothamBold),
    FontSemiBold = Font.fromEnum(Enum.Font.GothamSemibold),
    CornerRadius = UDim.new(0, 8),
    ElementCorner = UDim.new(0, 6),
    SmallCorner = UDim.new(0, 4),
}

return Theme


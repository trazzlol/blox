local VibeUI, Tabs = ...

local Section = Tabs.Scripts:Section({ Name = "Fun Scripts", Side = 1 })
local Section2 = Tabs.Scripts:Section({ Name = "Utility Scripts", Side = 2 })

local row1 = Section:Button()
row1:Add("FE Fling", function()
    loadstring(game:HttpGet("https://hellohellohell0.com/scripts-raw/kawaii-freaky-fling/main.lua", true))()
end)
Section:Label("Player Collision must be enabled")
Section:Divider()

local row2 = Section:Button()
row2:Add("Infinite Yield", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end)

local row3 = Section:Button()
row3:Add("Universal Portal Gun", function()
    loadstring(game:HttpGet("https://loadstring.net/raw/efwKdLGoEu"))()
end)

-- Utility Scripts (Side 2)

local row4 = Section2:Button()
row4:Add("Cobalt", function()
    loadstring(game:HttpGet("https://gitlab.com/upio/cobalt/-/releases/permalink/latest/downloads/Cobalt.luau"))()
end)

local row5 = Section2:Button()
row5:Add("Vex Explorer", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Vezise/2026/main/Vez/VexExplorer/VEXExplorer.lua"))()
end)
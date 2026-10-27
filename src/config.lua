--[[
    Hub Config
]]

local VibeUI = ...

local Config = {
    Title = "BloxxerHub - V2.1.8",

    -- News Ticker Settings
    Ticker = {
        Enabled = false,
        Tag = "NEWS",
        Side = "Top",                      -- "Top" or "Bottom"
        Speed = 80,                        -- Scroll speed (pixels per second)
        Width = 480,                       -- Width of the ticker bar
        Margin = 14,                       -- Screen margin
        Separator = "   |   ",             -- Separator between messages
        Messages = {
            "Welcome to BloxxerHub!",
            "Update 2.1.4: Added numerous legit options + revamped recoil + Fixed config bugs",
            "More planned soon!",
            "have fun!",
        }
    }
}

if VibeUI and Config.Ticker and Config.Ticker.Enabled and #Config.Ticker.Messages > 0 then
    Config.Instance = VibeUI:Ticker(Config.Ticker)
end

return Config

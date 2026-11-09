--[[
    LD TimeDisplay - configuration

    Shows the real time and date on screen. The clock ticks on the player's PC every second, so the
    server sends nothing while it runs.
]]

Config = {}

----------------------------------------------------------------------------------------------------
-- General
----------------------------------------------------------------------------------------------------
Config.Locale = 'en'            -- language for day and month names. Any code works: en, nl, de, fr, es,
                                -- pt-BR, pl, tr, it, ja ... Messages of /clock: en, nl, de, fr, es, pt, pl, tr
Config.VersionCheck = true      -- tell you in the server console when a new version is available

----------------------------------------------------------------------------------------------------
-- Time
----------------------------------------------------------------------------------------------------
-- 'server' = everyone sees the same time: the time zone of your server (+ TimezoneOffset).
--            Synced with the server when a player joins, so a wrong PC clock doesn't matter.
-- 'player' = every player sees their own local time.
Config.TimeSource = 'server'
Config.TimezoneOffset = 0       -- hours added to the server time zone ('server' only), e.g. -5 or 5.5

Config.Clock = '24h'            -- '24h' (15:42) or '12h' (3:42 PM)
Config.ShowSeconds = false
Config.DateFormat = 'DD-MM-YYYY' -- {date}: use DD, MM, YYYY, YY in any order, e.g. 'MM/DD/YYYY' or 'YYYY-MM-DD'

----------------------------------------------------------------------------------------------------
-- What is shown
--   One line per entry. Placeholders:
--     {time} {date} {weekday} {wd} {day} {month} {mon} {year}
--     {server} {player} {id} {players} {maxplayers} {gametime}
--   {wd} and {mon} are the short names (Mon, Nov). {gametime} is the clock inside GTA.
--   Lines whose placeholders are all empty are hidden.
----------------------------------------------------------------------------------------------------
Config.Lines = {
    '{date} · {time}',
    '© {server}',
    -- '{weekday} {day} {month}',
    -- '{player} ({id}) · {players}/{maxplayers} online',
}

Config.ServerName = nil         -- nil = your sv_projectName (or sv_hostname)

----------------------------------------------------------------------------------------------------
-- Look
----------------------------------------------------------------------------------------------------
Config.Position = 'top-right'   -- top-left, top-center, top-right, bottom-left, bottom-center, bottom-right
Config.Offset = { x = 1.2, y = 1.2 } -- distance from the screen edge, in % of the screen
Config.Theme = 'shadow'         -- 'shadow' (text with shadow), 'plain', 'pill' (dark rounded box), 'glass'
Config.FontSize = 1.4           -- in % of the screen height (scales with resolution); first line, the rest is smaller
Config.Color = '#ffffff'
Config.AccentColor = '#5ec8ff'  -- colour of the first line in 'pill' and 'glass'
Config.Font = 'Segoe UI, Roboto, Arial, sans-serif'
Config.Bold = true

----------------------------------------------------------------------------------------------------
-- Hiding
----------------------------------------------------------------------------------------------------
Config.Hide = {
    PauseMenu = true,           -- hide while the pause menu (ESC map) is open
    HudHidden = true,           -- hide when the HUD is hidden (screenshots, cinematic scripts, /hud off)
}

-- Players can turn the clock off and on for themselves; the choice is remembered. nil = no command.
Config.Command = 'clock'

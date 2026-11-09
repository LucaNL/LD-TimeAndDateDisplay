-- LD TimeDisplay (server): shares server name, player count and time zone, syncs the clock, checks for updates.

local RESOURCE = GetCurrentResourceName()
local VERSION = GetResourceMetadata(RESOURCE, 'version', 0) or '0.0.0'
local PREFIX = '^5LD TimeDisplay^7'

local function log(tag, fmt, ...) print(('%s %s %s^0'):format(PREFIX, tag, fmt:format(...))) end
local function ok(...) log('^2  OK ^7', ...) end
local function warn(...) log('^3 WARN^7', ...) end
local function hint(...) log('^6 HINT^7', ...) end

----------------------------------------------------------------------------------------------------
-- Shared state (one GlobalState write each, read by every client; no events per player)
----------------------------------------------------------------------------------------------------
local function serverName()
    local name = Config.ServerName
    if not name or name == '' then name = GetConvar('sv_projectName', '') end
    if name == '' then name = GetConvar('sv_hostname', '') end
    return (tostring(name):gsub('%^%d', ''))   -- strip ^1 colour codes
end

--- Seconds to add to UTC for the server's time zone, including daylight saving and Config.TimezoneOffset.
local function timezoneOffset()
    local now = os.time()
    local offset = now - os.time(os.date('!*t', now))
    if os.date('*t', now).isdst then offset = offset + 3600 end
    return offset + math.floor((tonumber(Config.TimezoneOffset) or 0) * 3600 + 0.5)
end

local function countPlayers()
    GlobalState.ldtd_players = #GetPlayers()
end

local function publish()
    GlobalState.ldtd_server = serverName()
    GlobalState.ldtd_max = GetConvarInt('sv_maxclients', 32)
    GlobalState.ldtd_tz = timezoneOffset()
    countPlayers()
end

AddEventHandler('playerJoining', countPlayers)
AddEventHandler('playerDropped', function() SetTimeout(500, countPlayers) end) -- the leaving player still counts during the event

-- The client asks once after joining; the answer is the server's clock, so a wrong PC clock doesn't matter.
RegisterNetEvent('ld_timedisplay:sync', function()
    TriggerClientEvent('ld_timedisplay:sync', source, os.time())
end)

----------------------------------------------------------------------------------------------------
-- Update check: reads the latest release from GitHub once a day. Nothing about your server is sent.
----------------------------------------------------------------------------------------------------
local RELEASES = 'https://api.github.com/repos/LucaNL/LD-TimeAndDateDisplay/releases/latest'
local DOWNLOAD = 'https://github.com/LucaNL/LD-TimeAndDateDisplay/releases/latest'
local announced

local function parse(v)
    local a, b, c = tostring(v or ''):match('^v?(%d+)%.(%d+)%.?(%d*)')
    if a then return { tonumber(a), tonumber(b), tonumber(c) or 0 } end
end

local function newer(latest, current)
    local x, y = parse(latest), parse(current)
    if not x or not y then return false end
    for i = 1, 3 do if x[i] ~= y[i] then return x[i] > y[i] end end
    return false
end

local function checkVersion()
    PerformHttpRequest(RELEASES, function(status, body)
        if status ~= 200 or type(body) ~= 'string' then return end
        local okDecode, data = pcall(json.decode, body)
        local latest = okDecode and type(data) == 'table' and data.tag_name
        if latest and newer(latest, VERSION) and announced ~= latest then
            announced = latest
            warn('Update available: v%s → %s', VERSION, latest)
            hint('Download: %s (keep your config.lua).', DOWNLOAD)
        end
    end, 'GET', '', { ['Accept'] = 'application/vnd.github+json', ['User-Agent'] = RESOURCE })
end

----------------------------------------------------------------------------------------------------
-- Startup
----------------------------------------------------------------------------------------------------
CreateThread(function()
    publish()
    local source = Config.TimeSource == 'player' and 'player time' or ('server time, UTC%+.1f'):format(GlobalState.ldtd_tz / 3600)
    ok('v%s started: %s · %d line(s) · %s', VERSION, source, #(Config.Lines or {}), tostring(Config.Position))
    if Config.TimeSource ~= 'server' and Config.TimeSource ~= 'player' then
        warn('Config.TimeSource must be \'server\' or \'player\', using \'server\'.')
    end

    local ticks = 0
    while true do
        Wait(60000)
        ticks = ticks + 1
        publish() -- keeps the count right and follows daylight saving changes
        if Config.VersionCheck ~= false and ticks % 1440 == 0 then checkVersion() end -- once a day
    end
end)

if Config.VersionCheck ~= false then SetTimeout(5000, checkVersion) end

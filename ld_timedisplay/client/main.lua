-- LD TimeDisplay (client): feeds the on-screen clock. The clock itself ticks inside the NUI page.

local KVP_HIDDEN = 'hidden'

local ready = false
local userHidden = GetResourceKvpInt(KVP_HIDDEN) == 1   -- the player's own /clock choice (remembered)
local scriptHidden = false                              -- set by other resources through the exports
local sent = {}                                         -- last values sent to the page

local function send(data) SendNUIMessage(data) end

--- Send a field only when it changed.
local function update(key, value)
    if sent[key] == value then return end
    sent[key] = value
    send({ type = 'set', key = key, value = value })
end

local function visible()
    if userHidden or scriptHidden then return false end
    if Config.Hide and Config.Hide.PauseMenu ~= false and IsPauseMenuActive() then return false end
    if Config.Hide and Config.Hide.HudHidden ~= false and IsHudHidden() then return false end
    return true
end

local function gameTime()
    return ('%02d:%02d'):format(GetClockHours(), GetClockMinutes())
end

local function lines()
    if type(Config.Lines) == 'table' and #Config.Lines > 0 then return Config.Lines end
    if type(Config.Lines) == 'string' then return { Config.Lines } end
    return { '{date} · {time}' }
end

-- Server clock: asked until the server answers (the first request can get lost while joining).
local serverNow, receivedAt

local function sendSync()
    if ready and serverNow then
        send({ type = 'sync', serverNow = serverNow + (GetGameTimer() - receivedAt) / 1000 })
    end
end

RegisterNetEvent('ld_timedisplay:sync', function(now)
    serverNow, receivedAt = tonumber(now), GetGameTimer()
    sendSync()
end)

CreateThread(function()
    while not NetworkIsSessionStarted() do Wait(500) end
    while not serverNow do
        TriggerServerEvent('ld_timedisplay:sync')
        Wait(5000)
    end
end)

local function sendInit()
    send({
        type = 'init',
        visible = visible(),
        config = {
            lines = lines(),
            locale = Config.Locale or 'en',
            source = Config.TimeSource == 'player' and 'player' or 'server',
            clock = Config.Clock == '12h' and '12h' or '24h',
            seconds = Config.ShowSeconds == true,
            dateFormat = Config.DateFormat or 'DD-MM-YYYY',
            position = Config.Position or 'top-right',
            offset = Config.Offset or { x = 1.2, y = 1.2 },
            theme = Config.Theme or 'shadow',
            fontSize = tonumber(Config.FontSize) or 1.4,
            -- offsets go through as numbers so 0 (flush to the edge) is kept
            color = Config.Color or '#ffffff',
            accent = Config.AccentColor or '#5ec8ff',
            font = Config.Font,
            bold = Config.Bold ~= false,
        },
    })
    sent = { visible = visible() }
end

-- The page says hello (again after a resource restart); answer with everything it needs.
RegisterNUICallback('ready', function(_, cb)
    ready = true
    sendInit()
    sendSync()
    cb('ok')
end)

CreateThread(function()
    while true do
        if ready then
            update('visible', visible())
            update('tz', GlobalState.ldtd_tz or 0)
            update('server', GlobalState.ldtd_server or '')
            update('players', GlobalState.ldtd_players or 0)
            update('maxplayers', GlobalState.ldtd_max or 0)
            update('player', GetPlayerName(PlayerId()) or '')
            update('id', GetPlayerServerId(PlayerId()))
            update('gametime', gameTime())
        end
        Wait(500)
    end
end)

----------------------------------------------------------------------------------------------------
-- /clock and exports
----------------------------------------------------------------------------------------------------
if Config.Command and Config.Command ~= '' then
    RegisterCommand(Config.Command, function()
        userHidden = not userHidden
        SetResourceKvpInt(KVP_HIDDEN, userHidden and 1 or 0)
        TriggerEvent('chat:addMessage', {
            color = { 94, 200, 255 },
            args = { 'Clock', userHidden and LDTDText('hidden', Config.Command) or LDTDText('shown') },
        })
    end, false)

    local function suggest() TriggerEvent('chat:addSuggestion', '/' .. Config.Command, 'Show or hide the clock') end
    suggest()
    AddEventHandler('onClientResourceStart', function(res) if res == 'chat' then suggest() end end)
end

--- exports.ld_timedisplay:hide() / show() / setVisible(bool) / isVisible()
--- For cinematic cameras, photo modes, character creators. Separate from the player's own /clock choice.
exports('hide', function() scriptHidden = true end)
exports('show', function() scriptHidden = false end)
exports('setVisible', function(state) scriptHidden = not state end)
exports('isVisible', function() return visible() end)

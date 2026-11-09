# LD TimeDisplay

**Free real-life clock for FiveM.** Shows the time and date on screen, in your server's time zone or each player's own, with your own layout: server name, player name and ID, players online, the in-game time and more.

Standalone. Works with any framework.

## Features

- **Ticks every second on the player's PC.** The server sends nothing while it runs.
- **Server time or player time:** everyone sees the server's time zone (synced on join, so a wrong PC clock doesn't matter), or every player sees their own local time.
- **Your own layout** with placeholders, one line each:
  ```lua
  Config.Lines = {
      '{weekday} {day} {month} · {time}',          -- Monday 9 November · 15:42
      '{player} ({id}) · {players}/{maxplayers}',  -- Luca (12) · 87/128
  }
  ```
  `{time} {date} {weekday} {wd} {day} {month} {mon} {year} {server} {player} {id} {players} {maxplayers} {gametime}`
- **Day and month names in any language** (`Config.Locale = 'nl'`, `'de'`, `'pt-BR'`, `'ja'` ...), 12h or 24h, any date format (`DD-MM-YYYY`, `MM/DD/YYYY`, `YYYY-MM-DD`).
- **6 positions and 4 themes:** shadow, plain, pill and glass. Plus size, colours and font. Scales with the screen resolution.
- **Hides itself** in the pause menu and when the HUD is hidden (screenshots, cinematic scripts).
- **`/clock`** lets players turn it off for themselves, and their choice is remembered.
- **Exports** to hide it from your own scripts (character creator, photo mode).
- Update check in the server console.

## Install

1. Download the latest release and put the `ld_timedisplay` folder in your `resources` folder.
2. Add to `server.cfg`:
   ```cfg
   ensure ld_timedisplay
   ```
3. Restart the server. Change the layout and look in `config.lua`.

## For developers

```lua
-- client side
exports.ld_timedisplay:hide()
exports.ld_timedisplay:show()
exports.ld_timedisplay:setVisible(false)
local shown = exports.ld_timedisplay:isVisible()
```

These are separate from the player's own `/clock` choice. Hiding from a script never turns the clock back on for a player who turned it off.

## Support

Questions or ideas: open an issue, or join the LD Scripts Discord: https://discord.ldscripts.com

## More from LD Scripts

- **LD Queue**: a reliable, fair connection queue with priority, restart protection and a live queue card.
- **LD Refunds**: refunds and compensation for players, with a Discord bot and web dashboard.
- **LD CarWipe**: free automatic vehicle cleanup with warnings and smart filters.

See https://store.ldscripts.com

## License

MIT. Free to use and change on your server.

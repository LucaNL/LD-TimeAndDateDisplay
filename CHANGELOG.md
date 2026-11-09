# Changelog

## 3.0.0 (rewrite)

Completely rewritten as **LD TimeDisplay** (resource `ld_timedisplay`). Remove the old `TimeAndDateDisplay-FiveM` resource before installing.

- The clock ticks on the player's PC every second. Before, the server sent the time every 30 seconds, so the clock could run up to half a minute behind.
- New `Config.TimeSource`: the server's time zone for everyone (synced on join), or each player's own local time.
- Your own layout with placeholders, instead of on/off switches: weekday, month names, players online, in-game time and more.
- Day and month names in any language, 12h/24h, any date format.
- 6 positions, 4 themes, size and colours that scale with the resolution.
- Hidden in the pause menu and when the HUD is hidden.
- `/clock` lets each player turn the clock off (remembered), and exports let other scripts hide it.

## 2.0.1 and older

The original TimeAndDateDisplay. Still available as the `v1-legacy` tag.

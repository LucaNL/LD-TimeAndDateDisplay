fx_version 'cerulean'
game 'gta5'

name 'ld_timedisplay'
author 'LD Scripts'
version '3.0.0'
description 'Real time and date on screen: server or player time zone, your own layout, players online'
repository 'https://github.com/LucaNL/LD-TimeAndDateDisplay'

lua54 'yes'

shared_scripts {
    'config.lua',
    'locales.lua',
}

server_script 'server/main.lua'
client_script 'client/main.lua'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js',
}

fx_version 'cerulean'
games { 'rdr3' }

author 'Bellacharge'
description 'Fully Configurable NPC Shop'
version '1.3'

shared_scripts {
    'config.lua'
}

server_scripts {
    '@vorp_core/server/server.lua',
    '@mysql-async/lib/MySQL.lua',
    'server.lua'
}

client_scripts {
    '@vorp_core/client/client.lua',
    'client.lua'
}

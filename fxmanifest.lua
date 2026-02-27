fx_version 'cerulean'
game 'gta5'

author 'Flitcher'
description 'A vehicle rental script'
version '1.0.0'


shared_scripts {
    'config.lua',
    '@ox_lib/init.lua'
}

client_scripts {
    'client.lua',
}

server_script {
    'server.lua'
}

escrow_ignore {
    'config.lua',
    'client.lua',
    'server.lua'
}

dependencies {
    'ox_lib',
}

optionalDependencies {
    'ox_inventory',
    'qs_inventory',
}

lua54 'yes'

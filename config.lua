config = {}


-- Discord Webhook Configuration
config.webhook = {
    enabled = true, -- true to enable Discord logs, false to disable
    url = 'YOUR_URL_WEBHOOK_HERE', -- Your Discord webhook URL
    botName = 'Rentals - Logs', -- Name of the bot in Discord
    botAvatar = 'https://image.noelshack.com/fichiers/2026/09/5/1772232196-mylogo.jpg', -- Avatar URL for the bot
    color = 3447003, -- Embed color (decimal format)
    role = '<@&YOUR_ROLE_ID_HERE>', -- Discord role ID to ping on suspicious activity
}

-- Target & Inventory rescources
config.target = 'qb' --  Choose between 'qb' for qb-target | 'ox' for ox-target
config.inventory = 'qs' -- Choose between 'qs' for qs-inventory | 'ox' for ox-inventory | 'qb' for qb-inventory
config.keys = 'qs' -- Choose between 'qs' for qs-vehiclekeys | 'qb' for qb-vehiclekeys

config.WhitelistVehicles = { -- This list of vehicles won't have keys.
    'bmx',
    'cruiser',
    'enduro',
    'fixter',
    'scorcher',
    'tribike',
    'tribike2',
    'tribike3',
}

-------------------------------------------------------

-- Ped & Scenario Configuration
config.pedmodel = 'a_m_m_prolhost_01' -- ped model hash
config.scenario = 'WORLD_HUMAN_CLIPBOARD' -- scenario for ped to play, false to disable

--Main configuration of location and vehicle type
config.locations = {
    ['airport'] = {
        ped = true, -- if false uses boxzone (below)
        coords = vector4(-1037.694, -2738.156, 20.169, 330.012),
        -------- boxzone (only used if ped is false) --------
        length = 1.0,  
        width = 1.0,   
        minZ = 30.81,  
        maxZ = 30.81,  
        debug = false, 
        -----------------------------------------------------
        vehicles = {
            ['panto']        = {     -- vehicle model name
                price = 1500,        -- vehicle price
                image = 'https://image.noelshack.com/fichiers/2026/09/5/1772207079-capture-d-cran-2026-02-27-164410.jpg',      -- image for menu, false for no image
            },
            ['faggio2']    = {
                price = 1000, 
                image = 'https://image.noelshack.com/fichiers/2026/09/5/1772207140-capture-d-cran-2026-02-27-164535.jpg',
            },
            ['BMX']       = {
                price = 250, 
                image = 'https://image.noelshack.com/fichiers/2026/09/5/1772207177-capture-d-cran-2026-02-27-164612.jpg',
            },
            ['Cruiser']     = {
                price = 300, 
                image = 'https://image.noelshack.com/fichiers/2026/09/5/1772207204-capture-d-cran-2026-02-27-164639.jpg',
            },

        },
        vehiclespawncoords = vector4(-1033.851, -2728.695, 20.140, 234.582), -- where vehicle spawns when rented
    },

    -- add as many locations as you'd like with any type of vehicle (air, water, land) follow same format as above
}

config.debug = true --true if you want debug message or false


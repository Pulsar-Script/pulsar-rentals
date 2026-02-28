local QBCore = GetResourceState('qb-core') == 'started' and exports['qb-core']:GetCoreObject()
local ESX = GetResourceState('es_extended') == 'started' and exports.es_extended:getSharedObject()

-- Rental verification tokens (stored temporarily)
local rentalTokens = {}

-- Generate secure token
local function GenerateToken(src, vehiclename, location, price)
    local token = math.random(100000, 999999) .. os.time() .. src
    rentalTokens[token] = {
        src = src,
        vehiclename = vehiclename,
        location = location,
        price = price,
        timestamp = os.time()
    }
    
    -- Token expires after 5 minutes
    SetTimeout(300000, function()
        if rentalTokens[token] then
            rentalTokens[token] = nil
            if config.debug then
                print("Token " .. token .. " expired")
            end
        end
    end)
    
    return token
end

-- Verify and consume token
local function VerifyToken(src, token)
    if not rentalTokens[token] then
        return false, "Invalid token"
    end
    
    local data = rentalTokens[token]
    
    -- Verify owner
    if data.src ~= src then
        rentalTokens[token] = nil
        return false, "Token mismatch"
    end
    
    -- Token valid, consume it
    rentalTokens[token] = nil
    return true, data
end

-- Discord Webhook Function
local function SendDiscordLog(playerName, playerId, vehicleModel, plate, amount, locationName, isAlert, alertType)
    if not config.webhook.enabled then return end
    
    local title = "🚗 Rent vehicle"
    local description = "A player rent a vehicle"
    local color = config.webhook.color
    local content = ""

    -- If it's an alert (unauthorized vehicle or distance)
    if isAlert then
        color = 15158332 -- Red color
        content = config.webhook.role .. " " -- Add role ping
        
        if alertType == "unauthorized" then
            title = "⚠️ SUSPICIOUS ACTIVITY - Unauthorized Vehicle"
            description = "A player attempted to rent an unauthorized vehicle!"
        elseif alertType == "distance" then
            title = "⚠️ SUSPICIOUS ACTIVITY - Distance Alert"
            description = "A player attempted to rent a vehicle from too far away!"
        elseif alertType == "invalid_token" then
            title = "⚠️ SUSPICIOUS ACTIVITY - Invalid Token"
            description = "A player attempted to rent with an invalid or expired token!"
        elseif alertType == "invalid_selection" then
            title = "⚠️ SUSPICIOUS ACTIVITY - Invalid Vehicle Selection"
            description = "A player attempted to select a vehicle that doesn't exist in config!"
        end
    end

    local embed = {
        {
            ["color"] = color,
            ["title"] = title,
            ["description"] = description,
            ["fields"] = {
                {
                    ["name"] = "👤 Player",
                    ["value"] = playerName .. " (ID: " .. playerId .. ")",
                    ["inline"] = true
                },
                {
                    ["name"] = "🚙 Vehicle",
                    ["value"] = vehicleModel,
                    ["inline"] = true
                },
                {
                    ["name"] = "🔖 Plate",
                    ["value"] = plate,
                    ["inline"] = true
                },
                {
                    ["name"] = "💰 Ammount",
                    ["value"] = "$" .. amount,
                    ["inline"] = true
                },
                {
                    ["name"] = "📍 Locations",
                    ["value"] = locationName,
                    ["inline"] = true
                },
            },
            ["footer"] = {
                ["text"] = "PC Rentals - date of server " .. os.date("%d/%m/%Y %H:%M:%S"),
            },
        }
    }

    PerformHttpRequest(config.webhook.url, function(err, text, headers) end, 'POST', json.encode({
        content = content,
        username = config.webhook.botName,
        avatar_url = config.webhook.botAvatar,
        embeds = embed
    }), { ['Content-Type'] = 'application/json' })
end

local function PlayerName(src)
    if QBCore then 
        local Player = QBCore.Functions.GetPlayer(src)
        return Player.PlayerData.charinfo.firstname..' '..Player.PlayerData.charinfo.lastname
    elseif ESX then 
        local Player = ESX.GetPlayerFromId(src)
        local first, last
        if Player.get and Player.get('firstName') and Player.get('lastName') then
            first = Player.get('firstName')
            last = Player.get('lastName')
        else
            local name = MySQL.Sync.fetchAll('SELECT `firstname`, `lastname` FROM `users` WHERE `identifier`=@identifier', { ['@identifier'] = ESX.GetIdentifier(source) })
            first, last = name[1]?.firstname or ESX.GetPlayerName(source), name[1]?.lastname or ''
        end
        return first..' '..last
    end
end

RegisterNetEvent('pc-rentals:server:RentVehicle', function(vehicle, plateString, location, token)
    local src = source
    local player_name = PlayerName(src)
    local Player = QBCore.Functions.GetPlayer(src)

    -- Verify token
    local isValid, tokenData = VerifyToken(src, token)
    if not isValid then
        if config.debug then
            print("^1[ERROR] Player " .. player_name .. " (ID: " .. src .. ") failed token verification: " .. (tokenData or "unknown") .. "^0")
        end
        SendDiscordLog(player_name, src, vehicle, plateString, 0, location or "unknown", true, "invalid_token")
        return
    end

    local itemMetadata = {}
    itemMetadata.owner = player_name
    itemMetadata.plate = plateString
    itemMetadata.model = vehicle
    itemMetadata.type = "Owner: "..player_name.." | Plate: "..plateString.." | Model: "..vehicle
    
    -- Get price from config (server-side security)
    local price = tokenData.price
    local isValidVehicle = false
    
    if location and config.locations[location] and config.locations[location].vehicles[vehicle] then
        isValidVehicle = true
    end
    
    -- Check if vehicle is authorized for this location
    if not isValidVehicle then
        if config.debug then
            print("^1[ERROR] Player " .. player_name .. " (ID: " .. src .. ") attempted to rent unauthorized vehicle: " .. vehicle .. " at location: " .. location .. "^0")
        end
        -- Send alert to Discord with role ping
        SendDiscordLog(player_name, src, vehicle, plateString, price, location, true, "unauthorized")
        return
    end
    
    -- Check distance between player and location
    local playerPed = GetPlayerPed(src)
    local playerCoords = GetEntityCoords(playerPed)
    local locationCoords = config.locations[location].coords
    local distance = #(playerCoords - vector3(locationCoords.x, locationCoords.y, locationCoords.z))
    
    if distance > 3 then
        if config.debug then
            print("Player " .. player_name .. " (ID: " .. src .. ") attempted to rent vehicle from distance: " .. string.format("%.2f", distance) .. "m at location: " .. location)
        end
        -- Send alert to Discord with role ping
        SendDiscordLog(player_name, src, vehicle, plateString, price, location, true, "distance")
        return
    end

    if config.debug then
        print("Player rent vehicle [ Owner: "..itemMetadata.owner.." | Plate: "..itemMetadata.plate.." | Model: "..itemMetadata.model.." | Location "..location.." | Distance: "..string.format("%.2f", distance).."m ]")
    end

    -- Send Discord Log with plate information (normal log)
    if location and price then
        SendDiscordLog(player_name, src, vehicle, plateString, price, location, false, nil)
        if config.debug then
            print("Logs send to discord vias webhook")
        end
    end


    if config.inventory == 'ox' then
        exports.ox_inventory:AddItem(src, 'rentalpapers', 1, itemMetadata )
    elseif config.inventory == 'qs' then
        print("QS-INVENTORY DETECTED")
        exports['qs-inventory']:AddItem(src, 'rentalpapers', 1, nil, itemMetadata)
    elseif config.inventory == 'qb' then
        Player.Functions.AddItem('rentalpapers', 1, nil, itemMetadata)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['rentalpapers'], 'add')
    end
end)

RegisterNetEvent('pc-rentals:server:SelectVehicle', function(vehiclename, location)
    local src = source
    
    -- Validate vehicle exists in config
    if not location or not config.locations[location] or not config.locations[location].vehicles[vehiclename] then
        if config.debug then
            local player_name = PlayerName(src)
            print(" Player " .. player_name .. " (ID: " .. src .. ") attempted to select invalid vehicle: " .. vehiclename)
        end
        -- Send alert to Discord
        SendDiscordLog(PlayerName(src), src, vehiclename, "N/A", 0, location or "unknown", true, "invalid_selection")
        return
    end
    
    local price = config.locations[location].vehicles[vehiclename].price
    local moneytype = 'bank'
    local bank 
    local cash
    
    if QBCore then 
        local Player = QBCore.Functions.GetPlayer(src)
        bank = Player.PlayerData.money.bank
        cash = Player.PlayerData.money.cash
    elseif ESX then 
        local Player = ESX.GetPlayerFromId(src)
        bank = Player.getAccount('bank').money
        cash = Player.getAccount('money').money
    end

    if bank < price then 
        moneytype = 'cash'
        if cash < price then 
            TriggerClientEvent('ox_lib:notify', src, {
                id = 'not_enough_money',
                description = 'You don\'t have enough money to rent this vehicle.',
                position = 'center-right',
                icon = 'ban',
                iconColor = '#C53030'
            })
            return 
        end    
    end

    if QBCore then 
        local Player = QBCore.Functions.GetPlayer(src)
        Player.Functions.RemoveMoney(moneytype, price)
    elseif ESX then
        local Player = ESX.GetPlayerFromId(src)
        if moneytype == 'cash' then
            Player.removeMoney(price)
        elseif moneytype == 'bank' then
            Player.removeAccountMoney('bank', price)
        end
    end
    
    -- Generate verification token
    local token = GenerateToken(src, vehiclename, location, price)
    
    TriggerClientEvent('ox_lib:notify', src, {
        id = 'rental_success',
        description = vehiclename:gsub("^%l", string.upper)..' rented for $'..price..'.',
        position = 'center-right',
        icon = 'car',
        iconColor = 'white'
    })
    
    if config.debug then
        print("Generated rental token for player " .. src .. ": " .. token)
    end
    
    TriggerClientEvent('pc-rentals:client:SpawnVehicle', src, vehiclename, location, token)
end)

local QBCore = GetResourceState('qb-core') == 'started' and exports['qb-core']:GetCoreObject()
local ESX = GetResourceState('es_extended') == 'started' and exports.es_extended:getSharedObject()

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

RegisterNetEvent('pc-rentals:server:RentVehicle', function(vehicle, plateString, location)
    local src = source
    local player_name = PlayerName(src)
    local Player = QBCore.Functions.GetPlayer(src)

    local itemMetadata = {}
    itemMetadata.owner = player_name
    itemMetadata.plate = plateString
    itemMetadata.model = vehicle
    itemMetadata.type = "Owner: "..player_name.." | Plate: "..plateString.." | Model: "..vehicle
    
    -- Get price from config (server-side security)
    local price = 1000
    local isValidVehicle = false
    
    if location and config.locations[location] and config.locations[location].vehicles[vehicle] then
        price = config.locations[location].vehicles[vehicle].price
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
    
    if distance > 25 then
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

RegisterNetEvent('pc-rentals:server:MoneyAmounts', function(vehiclename, price, location)
    local src = source
    local moneytype = 'bank'
    local price = tonumber(price)
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
    TriggerClientEvent('ox_lib:notify', src, {
        id = 'rental_success',
        description = vehiclename:gsub("^%l", string.upper)..' rented for $'..price..'.',
        position = 'center-right',
        icon = 'car',
        iconColor = 'white'
    })
    
    TriggerClientEvent('pc-rentals:client:SpawnVehicle', src, vehiclename, location)
end)

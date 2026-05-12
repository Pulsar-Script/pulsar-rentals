# Pulsar Script

*Fork of :* | https://github.com/SolosV1/solos-rentals

## Vehicle Rental 
- Customize vehicle and pricing options
- Add as many locations as you'd like (Each location can have different vehicles)
- Players receive rental papers with meta data displaying renter's name, vehicle, and licence plate
- **NEW:** Discord webhook integration for rental logs
- **NEW:** Advanced anti-cheat system with token verification
- **NEW:** Distance verification (25-meter radius)
- **NEW:** Automatic alerts for suspicious activities
- **NEW:** Token-based transaction security system

## Compatibility

**Requires:** ox_lib

**Optional**  ox_inventory | qs-inventory | qb-inventory *(Not standalon)*

**Frameworks:** QB | ESX

**Targets:** qb-target | ox_target

## Preview

https://youtu.be/NMyKnpPYqCA

## Gallery

![FiveM_b2699_GTAProcess_lVuAgry0md](https://github.com/SolosV1/solos-rentals/assets/108097907/497e9bf7-0522-4d5e-93a9-92ff466c6747)
![FiveM_b2699_GTAProcess_ZU03FpehGK](https://github.com/SolosV1/solos-rentals/assets/108097907/cbfbdc3a-7783-4b51-b9fa-3bf3058b6d61)
![FiveM_b2699_GTAProcess_RixfU7t61q](https://github.com/SolosV1/solos-rentals/assets/108097907/579328cf-332a-492d-a111-81c7497b0372)

## Installation:

1. add `pc-rentals` to your resources folder | Make sure folder is UNZIPPED!

2. `ensure pc-rentals` in server.cfg if necessary

3. Add `Rental Papers` item to inventory:

**Add rentalpapers.png to /ox_inventory/web/images/ or /qs-inventory/html/images/**

4. Restart server

5. Enjoy!
## Discord Webhook Configuration

Configure Discord logs in `config.lua`:

```lua
config.webhook = {
    enabled = true, -- Enable/disable Discord logs
    url = 'YOUR_WEBHOOK_URL', -- Your Discord webhook URL
    botName = 'Rentals - Logs', -- Bot name in Discord
    botAvatar = 'AVATAR_URL', -- Bot avatar URL
    color = 3447003, -- Embed color (decimal)
    role = '<@&ROLE_ID>', -- Role to ping on alerts (format: <@&ROLE_ID>)
}
```

### Features:
- **Normal Logs** (Blue embed): Player name, ID, vehicle model, plate, amount, location
- **Security Alerts** (Red embed with role ping):
  - Unauthorized vehicle detection
  - Distance validation (player must be within 25 meters of rental location)
  - Invalid token detection
  - Invalid vehicle selection attempts
  
### How to get your Discord Webhook URL:
1. Go to Server Settings → Integrations → Webhooks
2. Create a new webhook
3. Copy the webhook URL
4. Paste it in `config.webhook.url`

### How to get your Role ID:
1. Enable Developer Mode in Discord (User Settings → Advanced)
2. Right-click on the role → Copy ID
3. Format it as `<@&ROLE_ID>` in config

## Security Features

### Token-Based Verification System
- **Unique token generation** for each transaction
- **Token expires after 5 minutes** (prevents replay attacks)
- **Single-use tokens** (consumed after one use)
- **Player-bound tokens** (cannot be transferred between players)
- **Server-side validation** (impossible to bypass)

### Anti-Cheat Protection
- ✅ Server-side price validation (prevents price manipulation)
- ✅ Vehicle authorization check (only configured vehicles can be rented)
- ✅ Distance verification (25-meter radius from rental location)
- ✅ Token verification system (prevents unauthorized spawning)
- ✅ Invalid vehicle selection detection
- ✅ Real-time Discord alerts for suspicious activities
- ✅ Comprehensive logging system

### How It Works
1. Player selects vehicle → Server validates vehicle exists in config
2. Server deducts money using **config price only** (client price ignored)
3. Server generates **unique token** with transaction data
4. Client receives token and spawns vehicle
5. Server **validates token** before confirming rental
6. Token is **consumed** (cannot be reused)

**Result:** Complete protection against cheaters trying to manipulate prices, spawn unauthorized vehicles, or bypass payment systems.

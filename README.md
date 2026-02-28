# Project Chronos Script

*Fork of :* | https://github.com/SolosV1/solos-rentals

**Join our Discord** | https://discord.gg/f4m6TQRVaj 

## Vehicle Rental 
- Customize vehicle and pricing options
- Add as many locations as you'd like (Each location can have different vehicles)
- Players receive rental papers with meta data displaying renter's name, vehicle, and licence plate
- **NEW:** Discord webhook integration for rental logs
- **NEW:** Advanced anti-cheat system with distance verification
- **NEW:** Automatic alerts for suspicious activities

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

### Features:
- **Normal Logs** (Blue embed): Player name, ID, vehicle model, plate, amount, location
- **Security Alerts** (Red embed with role ping):
  - Unauthorized vehicle detection
  - Distance validation (player must be within 25 meters of rental location)
  
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

- ✅ Server-side price validation (prevents price manipulation)
- ✅ Vehicle authorization check (only configured vehicles can be rented)
- ✅ Distance verification (25-meter radius from rental location)
- ✅ Real-time Discord alerts for suspicious activities
- ✅ Comprehensive logging system

# The Isle - Dedicated Server

Automated PowerShell script to manage The Isle (Evrima) dedicated server.

## Quick Setup

### Prerequisites
- Windows (PowerShell)
- **That's it!** Everything else is automatic

### First Time Setup

1. **Download this repository** (clone or download ZIP)

2. **Place the script:**
   - Create folder: `C:\Server\TheIsle\` (or your preferred location)
   - Put `StartServer.ps1` directly in this folder
   - **Want a different location?** Edit the `$baseDir` variable in [StartServer.ps1](StartServer.ps1):
     ```powershell
     $baseDir = "C:\Server\TheIsle"  # Change this to match where you put the script
     ```
     Example: `D:\MyServers\TheIsle` or `E:\Games\TheIsleServer`

3. **Open PowerShell** in the folder containing `StartServer.ps1`

4. **Run the installation command:**
   ```powershell
   .\StartServer.ps1 -Update
   ```

The script will automatically:
- Download and install SteamCMD to your chosen location (if not present)
- Download The Isle server files (~5GB)
- Create all necessary folders and configuration files
- Start the server

### After First Setup

The folder structure will look like this (based on your chosen `$baseDir` path):
```
$baseDir\
├── StartServer.ps1              (the script - placed here by you)
├── README.md                    (this file)
├── Logs\                        (created automatically - server logs)
├── Server\                      (created automatically - The Isle files ~5GB)
└── SteamCMD\                    (created automatically - Steam download tool)
```

## Usage

### Start the server (no updates)
```powershell
.\StartServer.ps1
```

### Update and start the server
```powershell
.\StartServer.ps1 -Update
```
Use this when there's a game update or to verify server files.

## Server Configuration

Edit settings directly in [StartServer.ps1](StartServer.ps1) (lines 13-33):

```powershell
$serverName = "DeathWing_Server"    # Server name
$maxPlayers = 30                     # Max players
$serverPassword = ""                 # Password (empty = no password)
$port = 7777                         # Server port
```

**Important**: The script automatically regenerates `Game.ini` and `Engine.ini` on each startup. This prevents game bugs where The Isle server can delete or corrupt these files. Your settings in the script are always preserved.

## Default Settings

- **Map**: Gateway
- **Branch**: evrima
- **Port**: 7777
- **Max Players**: 30
- **RCON**: Disabled
- **Mutations**: Enabled (all)
- **Zombie Mode**: Enabled

## Network Configuration (IMPORTANT!)

Your server won't be visible online without proper network setup:

### 1. Use Wired Connection (REQUIRED)
- **Connect your server PC with an Ethernet cable** - WiFi is NOT reliable for game servers
- Wireless connections cause lag and disconnections

### 2. Set a Static IP Address
Your server PC needs a fixed local IP (e.g., `192.168.1.100`):
- Open Windows Settings → Network & Internet → Ethernet → IP settings
- Change from "Automatic (DHCP)" to "Manual"
- Set a static IP in your router's range (usually `192.168.1.x` or `192.168.0.x`)

### 3. Forward Ports on Your Router
Players can't connect without port forwarding:
- Log into your router (usually `192.168.1.1` or `192.168.0.1`)
- Find "Port Forwarding" section
- Forward these ports to your server's static IP:
  - **Port 7777** (UDP) - Game port
  - **Port 27015** (UDP) - Query port
- Save and reboot your router

### 4. Windows Firewall Rules
Allow the server through Windows Firewall:
- Open Windows Defender Firewall → Advanced Settings
- **Inbound Rules** → New Rule → Port
  - UDP, Port 7777 → Allow the connection
  - Name it "The Isle Server - Game Port"
- Repeat for UDP Port 27015 (Query Port)

### 5. Test Your Setup
- Start the server with `.\StartServer.ps1`
- Check if your ports are open: https://www.yougetsignal.com/tools/open-ports/
- Enter your public IP and port 7777

## Support

To modify available dinosaurs, mutations, or other advanced settings, edit the `Game.ini` generation section in the script (lines 100-210).

### Common Issues
- **Server not visible**: Check port forwarding and firewall rules
- **Players can't connect**: Verify static IP hasn't changed
- **Lag/disconnections**: Make sure server is on wired connection, not WiFi

## License

The Isle Server Configuration - Free to use

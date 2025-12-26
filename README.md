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

## Support

To modify available dinosaurs, mutations, or other advanced settings, edit the `Game.ini` generation section in the script (lines 100-210).

## License

The Isle Server Configuration - Free to use

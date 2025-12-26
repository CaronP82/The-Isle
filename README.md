# The Isle - Dedicated Server

Automated PowerShell script to manage The Isle (Evrima) dedicated server.

## Quick Setup

### Prerequisites
- Windows (PowerShell)
- **That's it!** Everything else is automatic

### First Time Setup

1. **Download this repository** (clone or download ZIP)

2. **Choose your installation location:**
   - Default location: `C:\Server\TheIsle\The-Isle\`
   - **Want a different location?** Edit the `$baseDir` variable in [StartServer.ps1](StartServer.ps1):
     ```powershell
     $baseDir = "C:\Server\TheIsle"  # Change this to your preferred path
     ```
     Example: `D:\MyServers\TheIsle` or `E:\Games\TheIsleServer`

3. **Open PowerShell** in the folder where you downloaded the repository

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

The folder structure will look like this (or in your chosen path):
```
<Your chosen path>\TheIsle\
├── Logs/           (server logs with timestamps)
├── Server/         (The Isle server files - ~5GB)
├── SteamCMD/       (Steam download tool - auto-installed)
└── The-Isle/       (this repository)
    ├── StartServer.ps1
    └── README.md
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

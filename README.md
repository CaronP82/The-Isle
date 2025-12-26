# The Isle - Dedicated Server

Automated PowerShell script to manage The Isle (Evrima) dedicated server.

## Quick Setup

### Prerequisites
- Windows
- [SteamCMD](https://developer.valvesoftware.com/wiki/SteamCMD) installed in `C:\Server\TheIsle\SteamCMD\`

### Folder Structure
```
C:\Server\TheIsle\
├── Logs/           (created automatically)
├── Server/         (downloaded by script)
├── SteamCMD/       (manual installation required)
└── The-Isle/       (this Git repository)
    └── StartServer.ps1
```

## Usage

### Start the server
```powershell
.\StartServer.ps1
```

### Install/Update then start
```powershell
.\StartServer.ps1 -Update
```

## Server Configuration

Edit settings directly in [StartServer.ps1](StartServer.ps1) (lines 13-33):

```powershell
$serverName = "DeathWing_Server"    # Server name
$maxPlayers = 30                     # Max players
$serverPassword = ""                 # Password (empty = no password)
$port = 7777                         # Server port
```

**Important**: The script automatically regenerates `Game.ini` and `Engine.ini` on each startup.

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

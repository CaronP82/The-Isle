# === COMMAND LINE PARAMETERS ===
param(
    [switch]$Update
)

# === CONFIGURATION ===

# Base paths
$baseDir = "C:\Server\TheIsle"
$serverPath = Join-Path $baseDir "Server"
$logsPath = Join-Path $baseDir "Logs"
$steamCmdPath = Join-Path $baseDir "SteamCMD"
$configPath = Join-Path $serverPath "TheIsle\Saved\Config\WindowsServer"
$gameIniPath = Join-Path $configPath "Game.ini"
$engineIniPath = Join-Path $configPath "Engine.ini"

# Server settings - Used ONLY for initial Game.ini creation
$serverName = "DeathWing_Server"
$maxPlayers = 30
$serverPassword = ""  # Leave empty for no password
$RconEnabled = "false"
$rconPassword = "qwerty"
$rconPort = 8888
$adminSteamIDs = ""  # Your SteamID64 - Leave empty or add: "76561198XXXXXXXX"

# Network settings
$port = 7777

# EOS Authentication
$clientId = "xyza7891gk5PRo3J7G9puCJGFJjmEguW"
$clientSecret = "pKWl6t5i9NJK8gTpVlAxzENZ65P8hYzodV8Dqe5Rlc8"

# SteamCMD settings
$appId = 412680
$branch = "evrima"
$steamCmdUrl = "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip"

# === FUNCTIONS ===

function Install-SteamCMD {
    Write-Host "`n[INSTALL] SteamCMD not found. Installing automatically..." -ForegroundColor Yellow

    # Create SteamCMD directory
    if (-not (Test-Path $steamCmdPath)) {
        New-Item -ItemType Directory -Path $steamCmdPath | Out-Null
    }

    $zipPath = Join-Path $steamCmdPath "steamcmd.zip"

    try {
        Write-Host "[DOWNLOAD] Downloading SteamCMD from $steamCmdUrl..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $steamCmdUrl -OutFile $zipPath -UseBasicParsing
        Write-Host "[SUCCESS] Download completed." -ForegroundColor Green

        Write-Host "[EXTRACT] Extracting SteamCMD..." -ForegroundColor Cyan
        Expand-Archive -Path $zipPath -DestinationPath $steamCmdPath -Force
        Remove-Item $zipPath -Force
        Write-Host "[SUCCESS] SteamCMD installed successfully!" -ForegroundColor Green

        # Run SteamCMD once to complete installation
        Write-Host "[SETUP] Running initial SteamCMD setup..." -ForegroundColor Cyan
        Start-Process -FilePath "$steamCmdPath\steamcmd.exe" -ArgumentList "+quit" -Wait -NoNewWindow
        Write-Host "[SUCCESS] SteamCMD ready to use!" -ForegroundColor Green

        return $true
    }
    catch {
        Write-Host "[ERROR] Failed to install SteamCMD: $_" -ForegroundColor Red
        Write-Host "[INFO] Please download manually from: https://developer.valvesoftware.com/wiki/SteamCMD" -ForegroundColor Yellow
        return $false
    }
}

function Test-Prerequisites {
    Write-Host "`n[CHECK] Verifying prerequisites..." -ForegroundColor Cyan
    $allGood = $true

    # Check/Install SteamCMD
    if (-not (Test-Path "$steamCmdPath\steamcmd.exe")) {
        if (-not (Install-SteamCMD)) {
            $allGood = $false
        }
    } else {
        Write-Host "[OK] SteamCMD found" -ForegroundColor Green
    }

    # Check/Create Logs directory
    if (-not (Test-Path $logsPath)) {
        Write-Host "[INFO] Creating Logs directory..." -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $logsPath | Out-Null
        Write-Host "[OK] Logs directory created" -ForegroundColor Green
    } else {
        Write-Host "[OK] Logs directory exists" -ForegroundColor Green
    }

    # Check Server directory
    if (-not (Test-Path $serverPath)) {
        Write-Host "[INFO] Server directory not found - will be created during update" -ForegroundColor Yellow
    } else {
        Write-Host "[OK] Server directory exists" -ForegroundColor Green
    }

    Write-Host ""
    return $allGood
}

function Update-Server {
    Write-Host "`n[UPDATE] Updating SteamCMD..." -ForegroundColor Cyan
    # SteamCMD updates itself automatically when run
    Start-Process -FilePath "$steamCmdPath\steamcmd.exe" -ArgumentList "+login anonymous +quit" -Wait -NoNewWindow
    Write-Host "[SUCCESS] SteamCMD update completed." -ForegroundColor Green

    Write-Host "`n[UPDATE] Updating server to: $serverPath" -ForegroundColor Cyan
    Write-Host "[INFO] App ID: $appId | Branch: $branch" -ForegroundColor Yellow

    # Build SteamCMD arguments - CRITICAL: force_install_dir MUST come BEFORE login
    $steamCmdArgs = "+force_install_dir `"$serverPath`" +login anonymous +app_update $appId -beta $branch validate +quit"

    Write-Host "[EXEC] Executing: steamcmd.exe $steamCmdArgs" -ForegroundColor Gray
    Write-Host "[INFO] SteamCMD will download updates if available and validate files..." -ForegroundColor DarkGray
    Start-Process -FilePath "$steamCmdPath\steamcmd.exe" -ArgumentList $steamCmdArgs -Wait -NoNewWindow
    Write-Host "[SUCCESS] Server update/validation completed.`n" -ForegroundColor Green
}

function Initialize-ServerConfig {
    Write-Host "`n[CONFIG] Initializing server configuration..." -ForegroundColor Cyan

    # Check if config directory exists
    if (-not (Test-Path $configPath)) {
        Write-Host "[INFO] Creating config directory..." -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $configPath -Force | Out-Null
        Write-Host "[OK] Config directory created" -ForegroundColor Green
    } else {
        Write-Host "[OK] Config directory exists" -ForegroundColor Green
    }

    # Always recreate Game.ini to prevent game bugs (game can delete/corrupt config files)
    Write-Host "[CONFIG] Generating Game.ini from script settings..." -ForegroundColor Yellow

    $hasPassword = $serverPassword -ne ""
    $gameIniContent = @"
[/Script/TheIsle.TIGameSession]
ServerName="$serverName" // Server name.
MapName=Gateway
MaxPlayerCount=$maxPlayers // 100+ player servers is not recommended.
bEnableHumans=false // Set to true if you want to run around with a flashlight and kick an animal.
bQueueEnabled=false // Enable queue if server slots are all filled.
QueryPort=$Port // Queue port. This port must be open if Queueing is enabled.
bServerPassword=$($hasPassword.ToString().ToLower()) // Set to true if you want a server password.
ServerPassword="$serverPassword" // Your server password.
bRconEnabled=$RconEnabled // Enable RCON.
RconPassword=$rconPassword // RCON password. Do not give this out.
RconPort=$rconPort
bServerDynamicWeather=true // Temporarily disabled. Changing this will do nothing.
ServerDayLengthMinutes=45 // Set in minutes.
ServerNightLengthMinutes=20 // Set in minutes.
bServerWhitelist=false // Set the server whitelist. If true, will look for whitelistIDs in the above category.
bEnableGlobalChat=true // Enabling the Global Chat panel.
bSpawnPlants=true // Enable plant food spawns.
bSpawnAI=true // Enable AI spawns.
AISpawnInterval=40 // Set how frequently AI can spawn in seconds.
bEnableMigration=true // Enable patrol zones, species migrations, and mass migrations.
MaxMigrationTime=5400 // Value is in seconds. This controls how long the migration zones should last.
GrowthMultiplier=1 // Universal multiplier for growth. Putting this number too high will break it. Recommendation is no higher than 20, even for lulz.
bEnableMutations=true // Enable mutations.

[/Script/TheIsle.TIGameStateBase]
AdminsSteamIDs=you admin SteamID // SteamID64 format
WhitelistIDs=White list steam ID here // SteamID64 format. NOTE: Must be enabled in the game session below. Keep this empty if whitelist is disabled
// List of all enabled classes. Remove a line to remove a class from spawning. - Can also be managed in Admin Panel in real time.
AllowedClasses=Allosaurus
AllowedClasses=Beipiaosaurus
AllowedClasses=Carnotaurus
AllowedClasses=Ceratosaurus
AllowedClasses=Deinosuchus
AllowedClasses=Diabloceratops
AllowedClasses=Dilophosaurus
AllowedClasses=Dryosaurus
AllowedClasses=Gallimimus
AllowedClasses=Herrerasaurus
AllowedClasses=Hypsilophodon
AllowedClasses=Maiasaura
AllowedClasses=Omniraptor
AllowedClasses=Pachycephalosaurus
AllowedClasses=Pteranodon
AllowedClasses=Stegosaurus
AllowedClasses=Tenontosaurus
AllowedClasses=Triceratops
AllowedClasses=Troodon
AllowedClasses=Tyrannosaurus

// List of all enabled mutations and values. Keep commented out to have all mutations enabled. Enabling any mutations means you must include all mutations you would like available on your server. Listed below are all modifiable mutations with default values. Altering these values may produce unstable gameplay.
// EnabledMutations=(MutationName=Hemomania,EffectValue=0.05)
// EnabledMutations=(MutationName=Hematophagy,EffectValue=0.25)
// EnabledMutations=(MutationName="Accelerated Prey Drive",EffectValue=0.1)
// EnabledMutations=(MutationName="Xerocole Adaptation",EffectValue=0.2)
// EnabledMutations=(MutationName=Hypervigilance,EffectValue=0.5)
// EnabledMutations=(MutationName=Truculency,EffectValue=0.2)
// EnabledMutations=(MutationName="Osteophagic,EffectValue"=0.15)
// EnabledMutations=(MutationName="Photosynthetic Regeneration",EffectValue=0.1)
// EnabledMutations=(MutationName="Cellular Regeneration",EffectValue=0.15)
// EnabledMutations=(MutationName="Advanced Gestation",EffectValue=0.5)
// EnabledMutations=(MutationName="Sustained Hydration",EffectValue=0.2)
// EnabledMutations=(MutationName="Enlarged meniscus",EffectValue=0.15)
// EnabledMutations=(MutationName="Efficient Digestion",EffectValue=0.2)
// EnabledMutations=(MutationName=Featherweight EffectValue=0.5)
// EnabledMutations=(MutationName=Osteosclerosis,EffectValue=0.2)
// EnabledMutations=(MutationName=Wader,EffectValue=0.25)
// EnabledMutations=(MutationName="Epidermal Fibrosis",EffectValue=0.15)
// EnabledMutations=(MutationName="Congenital Hypoalgesia",EffectValue=0.15)
// EnabledMutations=(MutationName="Photosynthetic Tissue",EffectValue=0.05)
// EnabledMutations=(MutationName=Nocturnal,EffectValue=0.05)
// EnabledMutations=(MutationName=Hydroregenerative,EffectValue=0.25)
// EnabledMutations=(MutationName="Increased Inspiratory Capacity",EffectValue=0.15)
// EnabledMutations=(MutationName=Hydrodynamic,EffectValue=0.15)
// EnabledMutations=(MutationName="Submerged Optical Retention",EffectValue=0.05)
// EnabledMutations=(MutationName="Infrasound Communication",EffectValue=0.5)
// EnabledMutations=(MutationName="Augmented Tapetum",EffectValue=0.5)
// EnabledMutations=(MutationName="Hypermetabolic Inanition",EffectValue=0.15)
// EnabledMutations=(MutationName="Tactile Endurance",EffectValue=0.5)
// EnabledMutations=(MutationName="Gastronomic Regeneration",EffectValue=0.1)
// EnabledMutations=(MutationName="Heightened Ghrelin",EffectValue=0.25)
// EnabledMutations=(MutationName="Prolific Reproduction",EffectValue=0.1)
// EnabledMutations=(MutationName="Enhanced Digestion",EffectValue=0.1)
// EnabledMutations=(MutationName="Reinforced Tendons",EffectValue=0.1)
// EnabledMutations=(MutationName="Multichambered Lungs",EffectValue=0.05)
// EnabledMutations=(MutationName=Reabsorption,EffectValue=1) ****** // Value must be 1 or remove from this list to disable it.
// EnabledMutations=(MutationName=Cannibalistic,EffectValue=1) ******// Value must be 1 or remove from this list to disable it.
// EnabledMutations=(MutationName="Barometric Sensitivity",EffectValue=1) ******// Value must be 1 or remove from this list to disable it.
// EnabledMutations=(MutationName="Social Behavior",EffectValue=1) *****// Value must be 1 or remove from this list to disable it.
// EnabledMutations=(MutationName="Traumatic Thrombosis",EffectValue=1) *****// Value must be 1 or remove from this list to disable it.
// EnabledMutations=(MutationName="Reniculate Kidneys",EffectValue=1) *****// Value must be 1 or remove from this list to disable it.

// Start a Zombie Infection
EnabledMutations=(MutationName="NHJ-INF",EffectValue=1)
EnabledMutations=(MutationName="NHJ-UND",EffectValue=1)

// Add the names of each AI class that should be disabled, one line for each.
// DisallowedAIClasses=Compsognathus
// DisallowedAIClasses=Pterodactylus
// DisallowedAIClasses=Boar
// DisallowedAIClasses=Deer
// DisallowedAIClasses=Goat
// DisallowedAIClasses=Seaturtle
"@

    $gameIniContent | Out-File -FilePath $gameIniPath -Encoding UTF8
    Write-Host "[SUCCESS] Game.ini regenerated successfully!" -ForegroundColor Green

    # Always recreate Engine.ini to prevent game bugs (game can delete/corrupt config files)
    Write-Host "[CONFIG] Generating Engine.ini from script settings..." -ForegroundColor Yellow

    $engineIniContent = @"
[EpicOnlineServices]
DedicatedServerClientId=xyza7891gk5PRo3J7G9puCJGFJjmEguW
DedicatedServerClientSecret=pKWl6t5i9NJK8gTpVlAxzENZ65P8hYzodV8Dqe5Rlc8

[Core.System]
Paths=../../../Engine/Content
Paths=%GAMEDIR%Content
Paths=../../../Engine/Plugins/Runtime/SoundUtilities/Content
Paths=../../../Engine/Plugins/Runtime/Synthesis/Content
Paths=../../../Engine/Plugins/Runtime/AudioSynesthesia/Content
Paths=../../../Engine/Plugins/Runtime/WebBrowserWidget/Content
Paths=../../../Engine/Plugins/FX/Niagara/Content
Paths=../../../Engine/Plugins/Experimental/PythonScriptPlugin/Content
Paths=../../../TheIsle/Plugins/RVTObjectLandscapeBlending/Content
Paths=../../../TheIsle/Plugins/DLSS/Content
Paths=../../../TheIsle/Plugins/UIPF/Content
Paths=../../../Engine/Plugins/Experimental/ControlRig/Content
Paths=../../../TheIsle/Plugins/SkinnedDecalComponent/Content
Paths=../../../TheIsle/Plugins/DLSSMoviePipelineSupport/Content
Paths=../../../Engine/Plugins/MovieScene/MovieRenderPipeline/Content
Paths=../../../Engine/Plugins/Compositing/OpenColorIO/Content
Paths=../../../Engine/Plugins/MovieScene/SequencerScripting/Content
Paths=../../../TheIsle/Plugins/EOSOnlineSubsystem/Content
Paths=../../../TheIsle/Plugins/ImpostorBaker/Content
Paths=../../../Engine/Plugins/2D/Paper2D/Content
Paths=../../../Engine/Plugins/Developer/AnimationSharing/Content
Paths=../../../Engine/Plugins/Editor/GeometryMode/Content
Paths=../../../Engine/Plugins/Editor/SpeedTreeImporter/Content
Paths=../../../Engine/Plugins/Enterprise/DatasmithContent/Content
Paths=../../../Engine/Plugins/Experimental/ChaosClothEditor/Content
Paths=../../../Engine/Plugins/Experimental/GeometryProcessing/Content
Paths=../../../Engine/Plugins/Experimental/GeometryCollectionPlugin/Content
Paths=../../../Engine/Plugins/Experimental/ChaosSolverPlugin/Content
Paths=../../../Engine/Plugins/Experimental/ChaosNiagara/Content
Paths=../../../Engine/Plugins/Experimental/MotoSynth/Content
Paths=../../../Engine/Plugins/MagicLeap/MagicLeapPassableWorld/Content
Paths=../../../Engine/Plugins/Media/MediaCompositing/Content
Paths=../../../Engine/Plugins/Runtime/OpenXREyeTracker/Content
Paths=../../../Engine/Plugins/Runtime/OpenXR/Content
Paths=../../../Engine/Plugins/Runtime/OpenXRHandTracking/Content
Paths=../../../Engine/Plugins/VirtualProduction/Takes/Content
"@

    $engineIniContent | Out-File -FilePath $engineIniPath -Encoding UTF8
    Write-Host "[SUCCESS] Engine.ini regenerated successfully!" -ForegroundColor Green

    Write-Host ""
    return $true  # Continue execution
}

function Start-GameServer {
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $logFile = Join-Path $logsPath "log_$timestamp.txt"
    $serverExe = Join-Path $serverPath "TheIsleServer.exe"

    # Verify server executable exists
    if (-not (Test-Path $serverExe)) {
        Write-Host "`n[ERROR] Server executable not found: $serverExe" -ForegroundColor Red
        Write-Host "[INFO] Run with -Update parameter to download the server files:" -ForegroundColor Yellow
        Write-Host "  .\StartServer.ps1 -Update" -ForegroundColor Cyan
        return
    }

    Write-Host "`n========================================" -ForegroundColor Magenta
    Write-Host "  THE ISLE DEDICATED SERVER" -ForegroundColor Magenta
    Write-Host "========================================" -ForegroundColor Magenta
    Write-Host "[INFO] Port: $port" -ForegroundColor Yellow
    Write-Host "[INFO] Config: $gameIniPath" -ForegroundColor Yellow
    Write-Host "[INFO] Log file: $logFile" -ForegroundColor Yellow
    Write-Host ""

    # Build dynamic arguments - Reference format from working batch file
    $serverOptions = "?Port=${port}"
    $logFlag = "-log"
    $cmdOptions = "-ini:Engine:[EpicOnlineServices]:DedicatedServerClientId=${clientId} -ini:Engine:[EpicOnlineServices]:DedicatedServerClientSecret=${clientSecret}"
    $arguments = "$serverOptions $logFlag $cmdOptions"

    Write-Host "[START] Launching server..." -ForegroundColor Cyan
    Write-Host "[EXEC] $serverExe $arguments" -ForegroundColor Gray
    Write-Host ""

    # 100% PowerShell - no Invoke-Expression needed
    & $serverExe $arguments.Split(' ') 2>&1 | Tee-Object -FilePath $logFile

    Write-Host "`n[STOPPED] Server stopped." -ForegroundColor Red
}

# === MAIN EXECUTION ===

# Always check prerequisites first
if (-not (Test-Prerequisites)) {
    Write-Host "[FATAL] Prerequisites check failed. Please fix the issues above." -ForegroundColor Red
    exit 1
}

if ($Update) {
    Update-Server
    if (-not (Initialize-ServerConfig)) {
        # Game.ini was just created - stop here
        exit 0
    }
    Start-GameServer
} else {
    # Check if server exists before trying to start
    $serverExe = Join-Path $serverPath "TheIsleServer.exe"
    if (-not (Test-Path $serverExe)) {
        Write-Host "`n[ERROR] Server not installed. Run with -Update to install:" -ForegroundColor Red
        Write-Host "  .\StartServer.ps1 -Update" -ForegroundColor Yellow
        exit 1
    }

    if (-not (Initialize-ServerConfig)) {
        # Game.ini was just created - stop here
        exit 0
    }
    Start-GameServer
}

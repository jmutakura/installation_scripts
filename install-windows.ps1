# ============================================
# Developer Environment Setup Script (Scoop)
# ============================================

# Color functions for good output
function Write-Header {
    param([string]$Message)
    $width = 64
    $padding = $width - $Message.Length
    $leftPad = [Math]::Floor($padding / 2)
    $rightPad = $padding - $leftPad

    $topLine = "+" + ("-" * $width) + "+"
    $middleLine = "|" + (" " * $leftPad) + $Message + (" " * $rightPad) + "|"
    $bottomLine = "+" + ("-" * $width) + "+"

    Write-Host "`n$topLine" -ForegroundColor Magenta
    Write-Host $middleLine -ForegroundColor Magenta
    Write-Host "$bottomLine`n" -ForegroundColor Magenta
}

function Write-LogError {
    param([string]$Message)
    Write-Host "  [X] " -ForegroundColor Red -NoNewline
    Write-Host $Message -ForegroundColor Red
}

function Write-LogSuccess {
    param([string]$Message)
    Write-Host "  [OK] " -ForegroundColor Green -NoNewline
    Write-Host $Message -ForegroundColor Green
}

function Write-LogInfo {
    param([string]$Message)
    Write-Host "  [i] " -ForegroundColor Cyan -NoNewline
    Write-Host $Message -ForegroundColor White
}

function Write-LogWarning {
    param([string]$Message)
    Write-Host "  [!] " -ForegroundColor Yellow -NoNewline
    Write-Host $Message -ForegroundColor Yellow
}

function Write-Step {
    param([string]$Message)
    Write-Host "`n  >> " -ForegroundColor Blue -NoNewline
    Write-Host $Message -ForegroundColor White
}

# Check if Scoop is installed
function Test-ScoopInstalled {
    return (Get-Command scoop -ErrorAction SilentlyContinue) -ne $null
}

# Check if a Scoop app is installed
function Test-ScoopAppInstalled {
    param([string]$AppName)
    $installed = scoop list | Select-String -Pattern "^\s*$AppName\s" -Quiet
    return $installed
}

# Install Scoop
function Install-Scoop {
    Write-Step "Installing Scoop package manager..."

    try {
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
        Write-LogSuccess "Scoop installed successfully"
        return $true
    }
    catch {
        Write-LogError "Failed to install Scoop: $_"
        return $false
    }
}

# Add Scoop bucket if not already added
function Add-ScoopBucket {
    param([string]$BucketName)

    $buckets = scoop bucket list
    if ($buckets -match $BucketName) {
        Write-LogInfo "Bucket '$BucketName' already added"
        return $true
    }

    try {
        scoop bucket add $BucketName | Out-Null
        Write-LogSuccess "Added bucket: $BucketName"
        return $true
    }
    catch {
        Write-LogError "Failed to add bucket '$BucketName': $_"
        return $false
    }
}

# Install Scoop package
function Install-ScoopPackage {
    param(
        [string]$Package,
        [string]$DisplayName
    )

    $appName = $Package.Split("/")[-1]

    if (Test-ScoopAppInstalled $appName) {
        Write-LogWarning "$DisplayName is already installed (skipping)"
        return $true
    }

    Write-LogInfo "Installing $DisplayName..."
    try {
        scoop install $Package
        Write-LogSuccess "$DisplayName installed successfully"
        return $true
    }
    catch {
        Write-LogError "Failed to install $DisplayName"
        return $false
    }
}

# Main installation function
function Install-DeveloperEnvironment {
    Write-Header "Developer Environment Setup"

    # Check if Scoop is installed
    if (-not (Test-ScoopInstalled)) {
        Write-LogWarning "Scoop is not installed"
        if (-not (Install-Scoop)) {
            Write-LogError "Cannot proceed without Scoop"
            exit 1
        }
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    }
    else {
        Write-LogSuccess "Scoop is already installed"
    }

    Write-Header "Installing Packages"

    # Add required buckets
    Write-Step "Setting up Scoop buckets..."
    Add-ScoopBucket "java"
    Add-ScoopBucket "extras"
    Add-ScoopBucket "versions"
    Add-ScoopBucket "main"

    # Install packages
    Write-Step "Installing packages..."
    Install-ScoopPackage -Package "main/nodejs-lts" -DisplayName "Node.js LTS"
    Install-ScoopPackage -Package "versions/python314" -DisplayName "Python 3.14"
    Install-ScoopPackage -Package "main/git" -DisplayName "Git"
    Install-ScoopPackage -Package "main/docker" -DisplayName "Docker"
    Install-ScoopPackage -Package "extras/vscode" -DisplayName "Visual Studio Code"
    Install-ScoopPackage -Package "extras/android-studio" -DisplayName "Android Studio"

    Write-Header "Installation Complete"
    Write-LogSuccess "Setup completed successfully!"

    Write-Host "`n  Press any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# Run the installation
try {
    Install-DeveloperEnvironment
}
catch {
    Write-LogError "An unexpected error occurred: $_"
    Write-Host "`n  Press any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

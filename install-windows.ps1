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

# Interactive package selection
function Show-PackageMenu {
    Write-Header "Select Packages to Install"

    $packages = @(
        @{ Name = "Java OpenJDK 25"; Bucket = "java"; Package = "java/openjdk25"; Selected = $true },
        @{ Name = "Node.js LTS"; Bucket = "main"; Package = "main/nodejs-lts"; Selected = $true },
        @{ Name = "Python 3.14"; Bucket = "versions"; Package = "versions/python314"; Selected = $true },
        @{ Name = "Docker"; Bucket = "main"; Package = "main/docker"; Selected = $true },
        @{ Name = "Git"; Bucket = "main"; Package = "main/git"; Selected = $true },
        @{ Name = "Android Studio"; Bucket = "extras"; Package = "extras/android-studio"; Selected = $true },
        @{ Name = "IntelliJ IDEA"; Bucket = "extras"; Package = "extras/idea"; Selected = $true },
        @{ Name = "Google Chrome"; Bucket = "extras"; Package = "extras/googlechrome"; Selected = $true },
        @{ Name = "Slack"; Bucket = "extras"; Package = "extras/slack"; Selected = $true },
        @{ Name = "Visual Studio Code"; Bucket = "extras"; Package = "extras/vscode"; Selected = $true }
    )

    Write-Host "  Select packages to install (Y/N for each, or A for all):`n" -ForegroundColor White

    $installAll = Read-Host "  Install all packages? (Y/N)"

    if ($installAll -eq "Y" -or $installAll -eq "y" -or $installAll -eq "A" -or $installAll -eq "a") {
        return $packages
    }

    Write-Host ""
    foreach ($pkg in $packages) {
        $response = Read-Host "  Install $($pkg.Name)? (Y/N)"
        $pkg.Selected = ($response -eq "Y" -or $response -eq "y")
    }

    return $packages
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

    # Get user package selection
    $selectedPackages = Show-PackageMenu
    $packagesToInstall = $selectedPackages | Where-Object { $_.Selected -eq $true }

    if ($packagesToInstall.Count -eq 0) {
        Write-LogWarning "No packages selected for installation"
        exit 0
    }

    Write-Header "Installing Selected Packages"

    # Group packages by bucket
    $buckets = $packagesToInstall | ForEach-Object { $_.Bucket } | Select-Object -Unique

    # Add required buckets
    Write-Step "Setting up Scoop buckets..."
    foreach ($bucket in $buckets) {
        Add-ScoopBucket $bucket
    }

    # Install packages
    Write-Step "Installing packages..."
    foreach ($pkg in $packagesToInstall) {
        Install-ScoopPackage -Package $pkg.Package -DisplayName $pkg.Name
    }

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

# ============================================
# Developer Environment Setup Script (Chocolatey)
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

function Install-ChocoPackage {
    param([string]$Package)

    Write-LogInfo "Installing $Package..."
    try {
        choco install $Package -y
        Write-LogSuccess "$Package installed successfully"
        return $true
    }
    catch {
        Write-LogError "Failed to install $Package: $_"
        return $false
    }
}

function Install-Windows {
    Write-Header "Developer Environment Setup"

    # Check if running as administrator
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-LogError "This script must be run as Administrator"
        exit 1
    }

    # Check if Chocolatey is installed
    if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-LogInfo "Installing Chocolatey..."
        try {
            Set-ExecutionPolicy Bypass -Scope Process -Force
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
            Write-LogSuccess "Chocolatey installed successfully"
        }
        catch {
            Write-LogError "Failed to install Chocolatey: $_"
            exit 1
        }
    }
    else {
        Write-LogSuccess "Chocolatey is already installed"
    }

    # Array of packages to install
    $packages = @(
        "nodejs",
        "python",
        "vscode",
        "androidstudio",
        "git.install",
        "docker-desktop",
        "webstorm"
    )

    # Install packages
    foreach ($package in $packages) {
        if (!(Install-ChocoPackage $package)) {
            Write-LogError "Installation process failed at package: $package"
            exit 1
        }
    }

    Write-Header "Installation Complete"
    Write-LogSuccess "All packages installed successfully"
    Write-LogInfo "Please restart your computer to complete the installation"
}

try {
    Install-Windows
}
catch {
    Write-LogError "An unexpected error occurred: $_"
    exit 1
}

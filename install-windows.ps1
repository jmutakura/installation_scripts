function Write-LogError {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Write-LogSuccess {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-LogInfo {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
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
        }
        catch {
            Write-LogError "Failed to install Chocolatey: $_"
            exit 1
        }
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
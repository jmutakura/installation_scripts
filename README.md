# Developer Environment Setup Scripts

Automated installation scripts for setting up a complete developer environment across Windows, macOS, and Debian-based Linux systems (Ubuntu, Debian, etc.).

## Features

- Interactive package selection menu
- Color-coded output for easy tracking
- Installation summary with success/failure reporting
- Automatic detection of already-installed packages
- Consistent experience across all platforms

## Supported Packages

All scripts support the following development tools:

- **Java OpenJDK** (25 for Windows/Mac, 21 for Debian)
- **Node.js** (LTS version)
- **Python 3** (3.14 for Windows/Mac, latest for Debian)
- **Docker**
- **Git**
- **Android Studio**
- **IntelliJ IDEA** (Ultimate for Windows/Mac, Community for Debian)
- **Google Chrome**
- **Slack**
- **Visual Studio Code**

## Usage

### macOS (Homebrew)

```bash
chmod +x install-mac.sh
./install-mac.sh
```

The script will:
- Install Homebrew if not already installed
- Prompt you to select which packages to install
- Handle both regular packages and casks automatically

### Windows (Scoop)

**Run PowerShell as Administrator**, then:

```powershell
Set-ExecutionPolicy Bypass -Scope Process
.\install-windows.ps1
```

The script will:
- Install Scoop package manager if not already installed
- Add required Scoop buckets (java, versions, extras)
- Prompt you to select which packages to install

### Debian/Ubuntu (APT/Snap)

```bash
chmod +x install-debian.sh
./install-debian.sh
```

The script will:
- Verify you're running on a Debian-based system
- Update package lists
- Install snapd if needed for GUI applications
- Prompt you to select which packages to install
- Configure Docker and add your user to the docker group

**Note:** You may need to log out and back in for Docker group changes to take effect.

## Interactive Installation

Each script provides an interactive menu where you can:
- Install all packages at once (Y/A)
- Select individual packages (Y/N for each)
- Skip packages you don't need

## Requirements

### macOS
- macOS 10.15 or later
- Command Line Tools (installed automatically with Homebrew)

### Windows
- Windows 10 or later
- PowerShell 5.1 or later
- Administrator privileges

### Debian/Ubuntu
- Ubuntu 20.04+ or Debian 11+
- sudo privileges
- Internet connection

## Package Managers Used

- **macOS:** Homebrew
- **Windows:** Scoop
- **Debian/Ubuntu:** APT (system packages) + Snap (GUI applications)

## Troubleshooting

### macOS
- If Homebrew installation fails, ensure Command Line Tools are installed: `xcode-select --install`
- For Apple Silicon Macs, the script automatically adds Homebrew to your PATH

### Windows
- If you get an execution policy error, make sure you're running PowerShell as Administrator
- Some packages may require a system restart to work properly

### Debian/Ubuntu
- If snap installations fail, ensure snapd is running: `sudo systemctl start snapd`
- Chrome and VS Code are installed via direct .deb downloads from official sources
- Node.js is installed via NodeSource repository for the latest LTS version

## License

MIT

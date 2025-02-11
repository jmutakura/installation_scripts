#!/bin/bash
function log_error() {
    echo "[ERROR] $1" >&2
}

function log_success() {
    echo "[SUCCESS] $1"
}

function log_info() {
    echo "[INFO] $1"
}

function install_brew_package() {
    local package=$1
    local is_cask=$2
    
    log_info "Installing $package..."
    if [ "$is_cask" = true ]; then
        if brew install --cask "$package"; then
            log_success "$package installed successfully"
        else
            log_error "Failed to install $package"
            return 1
        fi
    else
        if brew install "$package"; then
            log_success "$package installed successfully"
        else
            log_error "Failed to install $package"
            return 1
        fi
    fi
}

function install_mac() {
    # Check if Homebrew is installed
    if ! command -v brew &> /dev/null; then
        log_info "Installing Homebrew..."
        if ! /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
            log_error "Failed to install Homebrew"
            exit 1
        fi
    fi

    # Array of packages to install
    declare -A packages=(
        ["nodejs"]=false
        ["python"]=false
        ["visual-studio-code"]=true
        ["android-studio"]=true
        ["docker"]=false
        ["webstorm"]=true
        ["git"]=false
    )

    # Install packages
    for package in "${!packages[@]}"; do
        if ! install_brew_package "$package" "${packages[$package]}"; then
            log_error "Installation process failed at package: $package"
            exit 1
        fi
    done

    log_success "All packages installed successfully"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    log_error "This script should not be run as root"
    exit 1
fi

install_mac
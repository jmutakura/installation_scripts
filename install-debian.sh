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

function install_apt_package() {
    local package=$1
    
    log_info "Installing $package..."
    if sudo apt install -y "$package"; then
        log_success "$package installed successfully"
    else
        log_error "Failed to install $package"
        return 1
    fi
}

function install_debian() {
    # Check if running on Debian/Ubuntu
    if [ ! -f /etc/debian_version ]; then
        log_error "This script only supports Debian/Ubuntu Linux distributions"
        exit 1
    }

    # Update package list
    log_info "Updating package list..."
    if ! sudo apt update; then
        log_error "Failed to update package list"
        exit 1
    fi

    # Array of basic packages
    declare -a packages=(
        "nodejs"
        "npm"
        "python3"
        "python3-pip"
        "software-properties-common"
        "apt-transport-https"
        "wget"
        "git"
        "docker.io"
    )

    # Install basic packages
    for package in "${packages[@]}"; do
        if ! install_apt_package "$package"; then
            log_error "Installation process failed at package: $package"
            exit 1
        fi
    done

    # Install VSCode
    log_info "Installing VSCode..."
    if ! wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -; then
        log_error "Failed to add Microsoft GPG key"
        exit 1
    fi
    
    if ! sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"; then
        log_error "Failed to add VSCode repository"
        exit 1
    fi
    
    sudo apt update
    if ! install_apt_package "code"; then
        log_error "Failed to install VSCode"
        exit 1
    fi

    # Configure Docker
    log_info "Configuring Docker..."
    if ! sudo systemctl start docker; then
        log_error "Failed to start Docker service"
        exit 1
    fi
    
    if ! sudo systemctl enable docker; then
        log_error "Failed to enable Docker service"
        exit 1
    fi
    
    if ! sudo usermod -aG docker "$USER"; then
        log_error "Failed to add user to Docker group"
        exit 1
    fi

    # Install Android Studio
    log_info "Installing Android Studio..."
    if ! install_apt_package "android-studio"; then
        log_error "Failed to install Android Studio"
        exit 1
    fi

    # WebStorm notice
    log_info "Please download WebStorm from https://www.jetbrains.com/webstorm/download/"

    log_success "All packages installed successfully"
    log_info "Please log out and log back in for Docker group changes to take effect"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    log_error "This script should not be run as root"
    exit 1
fi

install_debian

#!/bin/bash

# ============================================
# Developer Environment Setup Script (APT)
# For Debian-based systems (Ubuntu, Debian, etc.)
# ============================================

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

function write_header() {
    local message="$1"
    local width=64
    local padding=$((width - ${#message}))
    local left_pad=$((padding / 2))
    local right_pad=$((padding - left_pad))

    echo ""
    echo -e "${MAGENTA}+$(printf '%*s' "$width" | tr ' ' '-')+${NC}"
    echo -e "${MAGENTA}|$(printf '%*s' "$left_pad")${message}$(printf '%*s' "$right_pad)|${NC}"
    echo -e "${MAGENTA}+$(printf '%*s' "$width" | tr ' ' '-')+${NC}"
    echo ""
}

function log_error() {
    echo -e "  ${RED}[X]${NC} ${RED}$1${NC}"
}

function log_success() {
    echo -e "  ${GREEN}[OK]${NC} ${GREEN}$1${NC}"
}

function log_info() {
    echo -e "  ${CYAN}[i]${NC} ${WHITE}$1${NC}"
}

function log_warning() {
    echo -e "  ${YELLOW}[!]${NC} ${YELLOW}$1${NC}"
}

function install_apt_package() {
    local package=$1
    local display_name=$2

    log_info "Installing $display_name..."
    if sudo apt install -y "$package" &>/dev/null; then
        log_success "$display_name installed successfully"
        return 0
    else
        log_error "Failed to install $display_name"
        return 1
    fi
}

function install_debian() {
    write_header "Developer Environment Setup"

    # Check if running on Debian/Ubuntu
    if [ ! -f /etc/debian_version ]; then
        log_error "This script only supports Debian-based systems (Ubuntu, Debian, etc.)"
        exit 1
    fi

    log_success "Detected Debian-based system"

    # Update package list
    log_info "Updating package list..."
    if sudo apt update &>/dev/null; then
        log_success "Package list updated"
    else
        log_error "Failed to update package list"
        exit 1
    fi

    # Basic packages
    declare -a packages=(
        "nodejs"
        "npm"
        "python3"
        "python3-pip"
        "git"
        "docker.io"
    )

    for package in "${packages[@]}"; do
        if ! install_apt_package "$package" "$package"; then
            log_error "Installation process failed at package: $package"
            exit 1
        fi
    done

    # Install VSCode
    log_info "Installing Visual Studio Code..."
    if wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg &>/dev/null; then
        sudo install -D -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg &>/dev/null
        sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list' &>/dev/null
        rm /tmp/packages.microsoft.gpg
        sudo apt update &>/dev/null
        install_apt_package "code" "Visual Studio Code"
    fi

    # Configure Docker
    log_info "Configuring Docker..."
    sudo systemctl start docker &>/dev/null
    sudo systemctl enable docker &>/dev/null
    sudo usermod -aG docker "$USER" &>/dev/null
    log_info "You may need to log out and back in for Docker group changes to take effect"

    write_header "Installation Complete"
    log_success "All packages installed successfully"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    log_error "This script should not be run as root"
    exit 1
fi

install_debian

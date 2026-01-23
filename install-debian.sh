#!/bin/bash

# ============================================
# Developer Environment Setup Script (APT/Snap)
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

# Display functions
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

function write_log_error() {
    echo -e "  ${RED}[X]${NC} ${RED}$1${NC}"
}

function write_log_success() {
    echo -e "  ${GREEN}[OK]${NC} ${GREEN}$1${NC}"
}

function write_log_info() {
    echo -e "  ${CYAN}[i]${NC} ${WHITE}$1${NC}"
}

function write_log_warning() {
    echo -e "  ${YELLOW}[!]${NC} ${YELLOW}$1${NC}"
}

function write_step() {
    echo ""
    echo -e "  ${BLUE}>>${NC} ${WHITE}$1${NC}"
}

# Check if package is installed
function test_package_installed() {
    local package=$1
    dpkg -l | grep -q "^ii  $package " || snap list 2>/dev/null | grep -q "^$package "
}

# Install APT package
function install_apt_package() {
    local package=$1
    local display_name=$2

    if test_package_installed "$package"; then
        write_log_warning "$display_name is already installed (skipping)"
        return 0
    fi

    write_log_info "Installing $display_name..."

    if sudo apt install -y "$package" &>/dev/null; then
        write_log_success "$display_name installed successfully"
        return 0
    else
        write_log_error "Failed to install $display_name"
        return 1
    fi
}

# Install Snap package
function install_snap_package() {
    local package=$1
    local display_name=$2
    local classic=$3

    if snap list 2>/dev/null | grep -q "^$package "; then
        write_log_warning "$display_name is already installed (skipping)"
        return 0
    fi

    write_log_info "Installing $display_name..."

    if [ "$classic" = true ]; then
        if sudo snap install "$package" --classic &>/dev/null; then
            write_log_success "$display_name installed successfully"
            return 0
        fi
    else
        if sudo snap install "$package" &>/dev/null; then
            write_log_success "$display_name installed successfully"
            return 0
        fi
    fi

    write_log_error "Failed to install $display_name"
    return 1
}

# Interactive package selection
function show_package_menu() {
    write_header "Select Packages to Install"

    echo -e "  ${WHITE}Select packages to install (Y/N for each, or A for all):${NC}"
    echo ""

    read -p "  Install all packages? (Y/N): " install_all

    if [[ "$install_all" =~ ^[YyAa]$ ]]; then
        SELECTED_JAVA=true
        SELECTED_NODE=true
        SELECTED_PYTHON=true
        SELECTED_DOCKER=true
        SELECTED_GIT=true
        SELECTED_ANDROID_STUDIO=true
        SELECTED_INTELLIJ=true
        SELECTED_CHROME=true
        SELECTED_SLACK=true
        SELECTED_VSCODE=true
    else
        echo ""
        read -p "  Install Java OpenJDK 25? (Y/N): " response
        [[ "$response" =~ ^[Yy]$ ]] && SELECTED_JAVA=true || SELECTED_JAVA=false

        read -p "  Install Node.js (LTS)? (Y/N): " response
        [[ "$response" =~ ^[Yy]$ ]] && SELECTED_NODE=true || SELECTED_NODE=false

        read -p "  Install Python 3? (Y/N): " response
        [[ "$response" =~ ^[Yy]$ ]] && SELECTED_PYTHON=true || SELECTED_PYTHON=false

        read -p "  Install Docker? (Y/N): " response
        [[ "$response" =~ ^[Yy]$ ]] && SELECTED_DOCKER=true || SELECTED_DOCKER=false

        read -p "  Install Git? (Y/N): " response
        [[ "$response" =~ ^[Yy]$ ]] && SELECTED_GIT=true || SELECTED_GIT=false

        read -p "  Install Android Studio? (Y/N): " response
        [[ "$response" =~ ^[Yy]$ ]] && SELECTED_ANDROID_STUDIO=true || SELECTED_ANDROID_STUDIO=false

        read -p "  Install IntelliJ IDEA? (Y/N): " response
        [[ "$response" =~ ^[Yy]$ ]] && SELECTED_INTELLIJ=true || SELECTED_INTELLIJ=false

        read -p "  Install Google Chrome? (Y/N): " response
        [[ "$response" =~ ^[Yy]$ ]] && SELECTED_CHROME=true || SELECTED_CHROME=false

        read -p "  Install Slack? (Y/N): " response
        [[ "$response" =~ ^[Yy]$ ]] && SELECTED_SLACK=true || SELECTED_SLACK=false

        read -p "  Install Visual Studio Code? (Y/N): " response
        [[ "$response" =~ ^[Yy]$ ]] && SELECTED_VSCODE=true || SELECTED_VSCODE=false
    fi
}

# Main installation function
function install_developer_environment() {
    write_header "Developer Environment Setup"

    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        write_log_error "This script should not be run as root"
        exit 1
    fi

    # Check if running on Debian/Ubuntu
    if [ ! -f /etc/debian_version ]; then
        write_log_error "This script only supports Debian-based systems (Ubuntu, Debian, etc.)"
        exit 1
    fi

    write_log_success "Detected Debian-based system"

    # Get user package selection
    show_package_menu

    write_header "Installing Selected Packages"

    # Update package list
    write_step "Updating package list..."
    if sudo apt update &>/dev/null; then
        write_log_success "Package list updated"
    else
        write_log_error "Failed to update package list"
        exit 1
    fi

    # Ensure snapd is installed if needed
    if [[ "$SELECTED_ANDROID_STUDIO" == true ]] || [[ "$SELECTED_INTELLIJ" == true ]] || \
       [[ "$SELECTED_SLACK" == true ]]; then
        write_step "Ensuring snapd is installed..."
        if ! command -v snap &> /dev/null; then
            if sudo apt install -y snapd &>/dev/null; then
                write_log_success "Snapd installed"
            else
                write_log_error "Failed to install snapd"
            fi
        else
            write_log_info "Snapd already installed"
        fi
    fi

    # Install packages
    write_step "Installing packages..."

    if [[ "$SELECTED_JAVA" == true ]]; then
        install_apt_package "openjdk-21-jdk" "Java OpenJDK 21"
    fi

    if [[ "$SELECTED_NODE" == true ]]; then
        write_log_info "Adding NodeSource repository..."
        if curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - &>/dev/null; then
            install_apt_package "nodejs" "Node.js LTS"
        fi
    fi

    if [[ "$SELECTED_PYTHON" == true ]]; then
        install_apt_package "python3" "Python 3"
        install_apt_package "python3-pip" "Python 3 pip"
    fi

    if [[ "$SELECTED_DOCKER" == true ]]; then
        if install_apt_package "docker.io" "Docker"; then
            sudo systemctl start docker &>/dev/null
            sudo systemctl enable docker &>/dev/null
            sudo usermod -aG docker "$USER" &>/dev/null
            write_log_info "You may need to log out and back in for Docker group changes to take effect"
        fi
    fi

    if [[ "$SELECTED_GIT" == true ]]; then
        install_apt_package "git" "Git"
    fi

    if [[ "$SELECTED_ANDROID_STUDIO" == true ]]; then
        install_snap_package "android-studio" "Android Studio" true
    fi

    if [[ "$SELECTED_INTELLIJ" == true ]]; then
        install_snap_package "intellij-idea-community" "IntelliJ IDEA Community" true
    fi

    if [[ "$SELECTED_CHROME" == true ]]; then
        write_log_info "Installing Google Chrome..."
        if wget -q -O /tmp/google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb &>/dev/null; then
            if sudo apt install -y /tmp/google-chrome.deb &>/dev/null; then
                rm /tmp/google-chrome.deb
                write_log_success "Google Chrome installed successfully"
            fi
        fi
    fi

    if [[ "$SELECTED_SLACK" == true ]]; then
        install_snap_package "slack" "Slack" true
    fi

    if [[ "$SELECTED_VSCODE" == true ]]; then
        write_log_info "Installing Visual Studio Code..."
        if wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg &>/dev/null; then
            sudo install -D -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg &>/dev/null
            sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list' &>/dev/null
            rm /tmp/packages.microsoft.gpg
            sudo apt update &>/dev/null
            install_apt_package "code" "Visual Studio Code"
        fi
    fi

    write_header "Installation Complete"
    write_log_success "Setup completed successfully!"

    echo ""
    echo -e "  ${GRAY}Press any key to exit...${NC}"
    read -n 1 -s
}

# Run the installation
install_developer_environment

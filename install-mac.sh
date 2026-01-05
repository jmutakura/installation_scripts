#!/bin/bash

# ============================================
# Developer Environment Setup Script (Homebrew)
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

function install_brew_package() {
    local package=$1
    local display_name=$2
    local is_cask=$3

    log_info "Installing $display_name..."
    if [ "$is_cask" = true ]; then
        if brew install --cask "$package" &>/dev/null; then
            log_success "$display_name installed successfully"
            return 0
        fi
    else
        if brew install "$package" &>/dev/null; then
            log_success "$display_name installed successfully"
            return 0
        fi
    fi
    log_error "Failed to install $display_name"
    return 1
}

function install_mac() {
    write_header "Developer Environment Setup"

    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        log_error "This script should not be run as root"
        exit 1
    fi

    # Check if Homebrew is installed
    if ! command -v brew &> /dev/null; then
        log_warning "Homebrew is not installed"
        log_info "Installing Homebrew..."
        if ! /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
            log_error "Failed to install Homebrew"
            exit 1
        fi
        if [[ $(uname -m) == "arm64" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        log_success "Homebrew installed successfully"
    else
        log_success "Homebrew is already installed"
    fi

    # Update Homebrew
    log_info "Updating Homebrew..."
    brew update

    # Install packages
    install_brew_package "nodejs" "Node.js" false
    install_brew_package "python" "Python" false
    install_brew_package "git" "Git" false
    install_brew_package "docker" "Docker" false
    install_brew_package "visual-studio-code" "Visual Studio Code" true
    install_brew_package "android-studio" "Android Studio" true
    install_brew_package "webstorm" "WebStorm" true

    write_header "Installation Complete"
    log_success "All packages installed successfully"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    log_error "This script should not be run as root"
    exit 1
fi

install_mac

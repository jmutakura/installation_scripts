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

# Check if Homebrew is installed
function test_brew_installed() {
    command -v brew &> /dev/null
}

# Check if a Homebrew package is installed
function test_brew_package_installed() {
    local package=$1
    brew list "$package" &> /dev/null || brew list --cask "$package" &> /dev/null
}

# Install Homebrew
function install_brew() {
    write_step "Installing Homebrew package manager..."

    if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        write_log_success "Homebrew installed successfully"

        if [[ $(uname -m) == "arm64" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi

        return 0
    else
        write_log_error "Failed to install Homebrew"
        return 1
    fi
}

# Install Homebrew package
function install_brew_package() {
    local package=$1
    local display_name=$2
    local is_cask=$3

    if test_brew_package_installed "$package"; then
        write_log_warning "$display_name is already installed (skipping)"
        return 0
    fi

    write_log_info "Installing $display_name..."

    if [ "$is_cask" = true ]; then
        if brew install --cask "$package" 2>&1 | grep -q "already installed"; then
            write_log_warning "$display_name is already installed"
            return 0
        elif brew install --cask "$package"; then
            write_log_success "$display_name installed successfully"
            return 0
        fi
    else
        if brew install "$package" 2>&1 | grep -q "already installed"; then
            write_log_warning "$display_name is already installed"
            return 0
        elif brew install "$package"; then
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

        read -p "  Install Node.js 24? (Y/N): " response
        [[ "$response" =~ ^[Yy]$ ]] && SELECTED_NODE=true || SELECTED_NODE=false

        read -p "  Install Python 3.14? (Y/N): " response
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

    # Check if Homebrew is installed
    if ! test_brew_installed; then
        write_log_warning "Homebrew is not installed"
        if ! install_brew; then
            write_log_error "Cannot proceed without Homebrew"
            exit 1
        fi
    else
        write_log_success "Homebrew is already installed"
    fi

    # Get user package selection
    show_package_menu

    write_header "Installing Selected Packages"

    # Update Homebrew
    write_step "Updating Homebrew..."
    brew update

    # Install packages
    write_step "Installing packages..."

    if [[ "$SELECTED_JAVA" == true ]]; then
        install_brew_package "openjdk@25" "Java OpenJDK 25" false
    fi

    if [[ "$SELECTED_NODE" == true ]]; then
        install_brew_package "node@24" "Node.js 24" false
    fi

    if [[ "$SELECTED_PYTHON" == true ]]; then
        install_brew_package "python@3.14" "Python 3.14" false
    fi

    if [[ "$SELECTED_DOCKER" == true ]]; then
        install_brew_package "docker" "Docker" false
    fi

    if [[ "$SELECTED_GIT" == true ]]; then
        install_brew_package "git" "Git" false
    fi

    if [[ "$SELECTED_ANDROID_STUDIO" == true ]]; then
        install_brew_package "android-studio" "Android Studio" true
    fi

    if [[ "$SELECTED_INTELLIJ" == true ]]; then
        install_brew_package "intellij-idea" "IntelliJ IDEA" true
    fi

    if [[ "$SELECTED_CHROME" == true ]]; then
        install_brew_package "google-chrome" "Google Chrome" true
    fi

    if [[ "$SELECTED_SLACK" == true ]]; then
        install_brew_package "slack" "Slack" true
    fi

    if [[ "$SELECTED_VSCODE" == true ]]; then
        install_brew_package "visual-studio-code" "Visual Studio Code" true
    fi

    write_header "Installation Complete"
    write_log_success "Setup completed successfully!"

    echo ""
    echo -e "  ${GRAY}Press any key to exit...${NC}"
    read -n 1 -s
}

# Run the installation
install_developer_environment

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
    local line
    line=$(printf '─%.0s' $(seq 1 $width))

    echo ""
    echo -e "${MAGENTA}╭${line}╮${NC}"
    echo -e "${MAGENTA}│$(printf "%${left_pad}s")${message}$(printf "%${right_pad}s")│${NC}"
    echo -e "${MAGENTA}╰${line}╯${NC}"
    echo ""
}

function write_log_error() {
    echo -e "  ${RED}✗${NC}  ${RED}$1${NC}"
}

function write_log_success() {
    echo -e "  ${GREEN}✓${NC}  ${GREEN}$1${NC}"
}

function write_log_info() {
    echo -e "  ${CYAN}◆${NC}  ${WHITE}$1${NC}"
}

function write_log_warning() {
    echo -e "  ${YELLOW}⚠${NC}  ${YELLOW}$1${NC}"
}

function write_step() {
    echo ""
    echo -e "  ${BLUE}❯${NC}  ${WHITE}$1${NC}"
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
        
        # Add Homebrew to PATH for Apple Silicon Macs
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
    
    # Check if any packages selected
    if [[ "$SELECTED_JAVA" != true ]] && [[ "$SELECTED_NODE" != true ]] && \
       [[ "$SELECTED_PYTHON" != true ]] && [[ "$SELECTED_DOCKER" != true ]] && \
       [[ "$SELECTED_GIT" != true ]] && [[ "$SELECTED_ANDROID_STUDIO" != true ]] && \
       [[ "$SELECTED_INTELLIJ" != true ]] && [[ "$SELECTED_CHROME" != true ]] && \
       [[ "$SELECTED_SLACK" != true ]] && [[ "$SELECTED_VSCODE" != true ]]; then
        write_log_warning "No packages selected for installation"
        exit 0
    fi
    
    write_header "Installing Selected Packages"
    
    # Track installation results
    declare -a SUCCESS_LIST
    declare -a FAILED_LIST
    declare -a SKIPPED_LIST
    
    # Update Homebrew
    write_step "Updating Homebrew..."
    brew update
    
    # Install packages
    write_step "Installing packages..."
    
    if [[ "$SELECTED_JAVA" == true ]]; then
        if test_brew_package_installed "openjdk@25"; then
            SKIPPED_LIST+=("Java OpenJDK 25")
            write_log_warning "Java OpenJDK 25 is already installed"
        elif install_brew_package "openjdk@25" "Java OpenJDK 25" false; then
            SUCCESS_LIST+=("Java OpenJDK 25")
        else
            FAILED_LIST+=("Java OpenJDK 25")
        fi
    fi
    
    if [[ "$SELECTED_NODE" == true ]]; then
        if test_brew_package_installed "node@24"; then
            SKIPPED_LIST+=("Node.js 24")
            write_log_warning "Node.js 24 is already installed"
        elif install_brew_package "node@24" "Node.js 24" false; then
            SUCCESS_LIST+=("Node.js 24")
        else
            FAILED_LIST+=("Node.js 24")
        fi
    fi
    
    if [[ "$SELECTED_PYTHON" == true ]]; then
        if test_brew_package_installed "python@3.14"; then
            SKIPPED_LIST+=("Python 3.14")
            write_log_warning "Python 3.14 is already installed"
        elif install_brew_package "python@3.14" "Python 3.14" false; then
            SUCCESS_LIST+=("Python 3.14")
        else
            FAILED_LIST+=("Python 3.14")
        fi
    fi
    
    if [[ "$SELECTED_DOCKER" == true ]]; then
        if test_brew_package_installed "docker"; then
            SKIPPED_LIST+=("Docker")
            write_log_warning "Docker is already installed"
        elif install_brew_package "docker" "Docker" false; then
            SUCCESS_LIST+=("Docker")
        else
            FAILED_LIST+=("Docker")
        fi
    fi
    
    if [[ "$SELECTED_GIT" == true ]]; then
        if test_brew_package_installed "git"; then
            SKIPPED_LIST+=("Git")
            write_log_warning "Git is already installed"
        elif install_brew_package "git" "Git" false; then
            SUCCESS_LIST+=("Git")
        else
            FAILED_LIST+=("Git")
        fi
    fi
    
    if [[ "$SELECTED_ANDROID_STUDIO" == true ]]; then
        if test_brew_package_installed "android-studio"; then
            SKIPPED_LIST+=("Android Studio")
            write_log_warning "Android Studio is already installed"
        elif install_brew_package "android-studio" "Android Studio" true; then
            SUCCESS_LIST+=("Android Studio")
        else
            FAILED_LIST+=("Android Studio")
        fi
    fi
    
    if [[ "$SELECTED_INTELLIJ" == true ]]; then
        if test_brew_package_installed "intellij-idea"; then
            SKIPPED_LIST+=("IntelliJ IDEA")
            write_log_warning "IntelliJ IDEA is already installed"
        elif install_brew_package "intellij-idea" "IntelliJ IDEA" true; then
            SUCCESS_LIST+=("IntelliJ IDEA")
        else
            FAILED_LIST+=("IntelliJ IDEA")
        fi
    fi
    
    if [[ "$SELECTED_CHROME" == true ]]; then
        if test_brew_package_installed "google-chrome"; then
            SKIPPED_LIST+=("Google Chrome")
            write_log_warning "Google Chrome is already installed"
        elif install_brew_package "google-chrome" "Google Chrome" true; then
            SUCCESS_LIST+=("Google Chrome")
        else
            FAILED_LIST+=("Google Chrome")
        fi
    fi
    
    if [[ "$SELECTED_SLACK" == true ]]; then
        if test_brew_package_installed "slack"; then
            SKIPPED_LIST+=("Slack")
            write_log_warning "Slack is already installed"
        elif install_brew_package "slack" "Slack" true; then
            SUCCESS_LIST+=("Slack")
        else
            FAILED_LIST+=("Slack")
        fi
    fi
    
    if [[ "$SELECTED_VSCODE" == true ]]; then
        if test_brew_package_installed "visual-studio-code"; then
            SKIPPED_LIST+=("Visual Studio Code")
            write_log_warning "Visual Studio Code is already installed"
        elif install_brew_package "visual-studio-code" "Visual Studio Code" true; then
            SUCCESS_LIST+=("Visual Studio Code")
        else
            FAILED_LIST+=("Visual Studio Code")
        fi
    fi
    
    # Display summary
    write_header "Installation Summary"
    
    if [ ${#SUCCESS_LIST[@]} -gt 0 ]; then
        echo -e "  ${GREEN}Successfully Installed:${NC}"
        for item in "${SUCCESS_LIST[@]}"; do
            echo -e "    ${GREEN}- $item${NC}"
        done
    fi
    
    if [ ${#SKIPPED_LIST[@]} -gt 0 ]; then
        echo ""
        echo -e "  ${YELLOW}Already Installed:${NC}"
        for item in "${SKIPPED_LIST[@]}"; do
            echo -e "    ${YELLOW}- $item${NC}"
        done
    fi
    
    if [ ${#FAILED_LIST[@]} -gt 0 ]; then
        echo ""
        echo -e "  ${RED}Failed to Install:${NC}"
        for item in "${FAILED_LIST[@]}"; do
            echo -e "    ${RED}- $item${NC}"
        done
    fi
    
    echo ""
    if [ ${#FAILED_LIST[@]} -eq 0 ]; then
        write_log_success "Setup completed successfully!"
    else
        write_log_warning "Setup completed with some failures"
    fi
    
    echo ""
    echo -e "  ${GRAY}Press any key to exit...${NC}"
    read -n 1 -s
}

# Run the installation
install_developer_environment

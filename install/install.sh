#!/usr/bin/env bash

# Exit in case of failure
set -e

# Clear screen
printf "\033[2J\033[1;1H"

printf "\nWelcome to The CS Launchpad Installer!\n\n"
sleep 0.5

OS="$(uname -s)"


case "$OS" in
    Linux*) os_name="Linux" known_os=true ;;
    Darwin*) os_name="macOS" known_os=true ;;
    CYGWIN*|MINGW*|MSYS*) os_name="Windows" known_os=true ;;
    *) os_name="$OS" known_os=false ;;
esac

if [ "$known_os" != "true" ]; then
    printf "Unknown OS detected: %s\nAborting.\n" "$OS"
    exit 1
fi

printf "OS detected successfully!\n\nStarting installation for %s...\n\nChecking for prerequisites:\n" "$os_name"
sleep 0.3


check_for_command() {
    if command -v "$1" > /dev/null 2>&1; then
        printf "\t> %s is installed!\n" "$2"
        sleep 0.3
    else
        printf "%s is not installed. Aborting.\n" "$2"
        exit 1
    fi
}

check_internet() {
    if command -v curl > /dev/null 2>&1; then
        if curl -fsS --connect-timeout 3 https://1.1.1.1 >/dev/null 2>&1; then
            return 0
        fi
    fi

    if [ "$os_name" = "Linux" ]; then
        ping -c 1 -W 1 8.8.8.8 >/dev/null 2>&1 && return 0
    else
        ping -c 1 8.8.8.8 >/dev/null 2>&1 && return 0
    fi
    return 1
}

try_install() {
    if command -v "$1" > /dev/null 2>&1; then
        printf "\t> %s: Already installed!\n" "$3"
        sleep 0.3
    else
        printf "\t> Installing %s...\n" "$3"
        sudo pacman -S -q --noconfirm "$2" && printf "\t> %s successfully installed!\n" "$3"
    fi
}

# Functions are defined BEFORE calling to prevent error

check_linux() {
    # Check if sudo exists
    if ! command -v sudo > /dev/null 2>&1; then
        printf "Sudo not found. Aborting.\n"
        exit 1
    fi

    # Check for internet connectivity
    if check_internet; then
        printf "\t> Connected to internet!\n"
    else
        printf "Not connected to internet. Aborting\n"
        exit 1
    fi

    # Check for Sudo
    check_for_command sudo Sudo

    # Check for Pacman
    check_for_command pacman Pacman

    printf "\n[1/3] All prerequisites found!\n\n"
    sleep 0.5
}

install_linux() {
    printf "Refreshing Pacman database if needed. Please enter your password below if prompted.\n\n"
    sudo pacman -Sy --noconfirm

    # Check for Git
    try_install git git Git

    # Check for Python
    try_install python python Python

    # Check for VS Code
    try_install code code "VS Code"

    # Check for GitHub CLI
    try_install gh github-cli "GitHub CLI"

    printf "\n[2/3] Installation step complete!\n"
    sleep 0.5
}

configure_git() {
    printf "\t> Git:\n"
    GIT_NAME="$(git config --global user.name)"
    if [ "$GIT_NAME" != "" ]; then
        printf "\t  - Name: %s\n" "$GIT_NAME"
        sleep 0.2
    else
        printf "There is not a name in your current Git config. Please enter your name:\n"
        read -r name
        if ! git config --global user.name "$name"; then
            printf "Error: Failed to set Git name. Aborting.\n"
            exit 1
        fi
        printf "\t  - Global name set as %s\n" "$name"
    fi

    GIT_EMAIL="$(git config --global user.email)"
    if [ "$GIT_EMAIL" != "" ]; then
        printf "\t  - Email: %s\n" "$GIT_EMAIL"
        sleep 0.2
    else
        printf "There is not an email in your current Git config. Please enter your email:\n"
        read -r email
        if ! git config --global user.email "$email"; then
            printf "Error: Failed to set Git email. Aborting.\n"
            exit 1
        fi
        printf "\t  - Global email set as %s\n" "$email"
    fi
    sleep 0.4
}

configure_github_cli() {
    printf "\t> GitHub CLI:\n"

    if gh auth status >/dev/null 2>&1; then
        printf "\t  - GitHub CLI is already authenticated!\n"
        sleep 0.3
    else
        printf "Not logged into GitHub CLI\nPlease sign in on the browser window.\n"
        if ! gh auth login -h github.com -p https -w --skip-ssh-key; then
            printf "Warning: GitHub CLI authentication failed. You can authenticate later with 'gh auth login'.\n"
        fi
    fi
}

configure_common() {
    printf "\nChecking config files:\n"
    sleep 0.3

    configure_git
    configure_github_cli

    printf "\n\n[3/3] Everything is configured!\n"
}

configure_linux() {
    configure_common
}

configure_mac() {
    configure_common
}

check_mac() {
    # macOS prerequisite checks: sudo, internet, curl
    # Check if sudo exists
    if ! command -v sudo > /dev/null 2>&1; then
        printf "Sudo not found. Aborting.\n"
        exit 1
    fi

    # Check for internet connectivity
    if check_internet; then
        printf "\t> Connected to internet!\n"
    else
        printf "Not connected to internet. Aborting\n"
        exit 1
    fi

    # Check for Sudo
    check_for_command sudo Sudo

    # Check for curl (needed to install Homebrew)
    if command -v curl > /dev/null 2>&1; then
        printf "\t> cURL is installed!\n"
    else
        printf "cURL is not installed. Aborting.\n"
        exit 1
    fi

    # Inform about Homebrew (we will install it in install_mac if missing)
    if command -v brew > /dev/null 2>&1; then
        printf "\t> Homebrew is installed!\n"
    else
        printf "\t> Homebrew not found. It will be installed in the next step.\n"
    fi

    printf "\n[1/3] All prerequisites found (or will be installed).\n\n"
    sleep 0.5
}

try_install_brew() {
    # Usage: try_install_brew <command_to_check> <brew_pkg> <pretty_name> [cask]
    local cmd="$1" pkg="$2" pretty="$3" cask="$4"
    if command -v "$cmd" > /dev/null 2>&1; then
        printf "\t> %s: Already installed!\n" "$pretty"
        sleep 0.2
    else
        printf "\t> Installing %s...\n" "$pretty"
        if [ "$cask" = "cask" ]; then
            brew install --cask "$pkg"
        else
            brew install "$pkg"
        fi
        printf "\t> %s successfully installed!\n" "$pretty"
    fi
}

install_mac() {
    printf "Refreshing Homebrew if needed and installing packages.\n\n"

    # Install Homebrew if missing
    if ! command -v brew > /dev/null 2>&1; then
        printf "Homebrew is not installed. Installing Homebrew...\n"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Load Homebrew environment for the current shell session
        if [ -x "/opt/homebrew/bin/brew" ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)" || true
        elif [ -x "/usr/local/bin/brew" ]; then
            eval "$(/usr/local/bin/brew shellenv)" || true
        fi

        printf "Homebrew installed.\n"
    else
        printf "Homebrew already installed.\n"
    fi

    printf "Updating Homebrew...\n"
    if ! brew update; then
        printf "Warning: Homebrew update failed, but installation will continue.\n"
    fi

    # Install Git
    try_install_brew git git Git

    # Install Python
    try_install_brew python3 python Python

    # Install VS Code (cask)
    try_install_brew code visual-studio-code "VS Code" cask

    # Install GitHub CLI
    try_install_brew gh gh "GitHub CLI"

    printf "\n[2/3] Installation step complete!\n"
    sleep 0.5
}

check_win() {
    printf "Windows is not supported with this script.\nPlease visit https://github.com/cs-launchpad/setup for Windows installation instructions.\nAborting.\n"
}

case $os_name in
    Linux) check_linux ; install_linux ; configure_linux ;;
    macOS) check_mac ; install_mac ; configure_mac ;;
    Windows) check_win ;;
esac

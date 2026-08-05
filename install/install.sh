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
    *) os_name=OS known_os=false ;;
esac

if [ "$known_os" != "true" ]; then
    printf "Unknown OS detected: %s\nAborting." "$OS"
    exit 1
fi

printf "OS detected succesfully!\n\nStarting installation for %s...\n\nChecking for prerequisites:\n" "$os_name"
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

try_install() {
    if command -v "$1" > /dev/null 2>&1; then
        printf "\t> %s: Already installed!\n" "$3"
        sleep 0.3
    else
        printf "\t> Installing %s...\n" "$3"
        sudo pacman -S -q --noconfirm "$2" && printf "\t> %s succesfully installed!\n" "$3"
    fi
}

# Functions are defined BEFORE calling to prevent error

check_linux() {
    # Check if sudo exists
    if ! command -v sudo > /dev/null 2>&1; then
        printf "Sudo not found. Aborting.\n"
        exit 1
    fi

    # Check for internet by pinging reliable IP adress
    if ping -c 1 -W 1 8.8.8.8 >/dev/null 2>&1; then
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

configure_linux() {
    printf "\nChecking config files:\n"
    sleep 0.3


    # Git name and email

    printf "\t> Git:\n"
    GIT_NAME="$(git config --global user.name)"
    if [ "$GIT_NAME" != "" ]; then
        printf "\t  - Name: %s\n" "$GIT_NAME"
        sleep 0.2
    else
        printf "There is not a name in your current Git config. Please enter your name:\n"
        read -r name
        git config --global user.name "$name"
    fi

    GIT_EMAIL="$(git config --global user.email)"
    if [ "$GIT_EMAIL" != "" ]; then
        printf "\t  - Email: %s\n" "$GIT_EMAIL"
        sleep 0.2
    else
        printf "There is not an email in your current Git config. Please enter your email:\n"
        read -r email
        git config --global user.email "$email"
        printf "\t  - Global email set as %s\n" "$email"
    fi
    sleep 0.4

    # GH CLI auth status check
    printf "\t> GitHub CLI:\n"

    if gh auth status >/dev/null 2>&1; then
        printf "\t  - GitHub CLI is already authenticated!\n"
        sleep 0.3
    else
        printf "Not logged into GitHub CLI\nPlease sign in on the browser window."
        gh auth login -h github.com -p https -w --skip-ssh-key
    fi

    printf "\n\n[3/3] Everything is configured!\n"
}


check_mac() {
    printf \n
}

check_win() {
    printf \n
}

case $os_name in
    Linux) check_linux ; install_linux ; configure_linux ;;
    macOS) check_mac ;;
    Windows) check_win ;;
esac

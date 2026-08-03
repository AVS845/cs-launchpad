#!/usr/bin/env bash
# TODO: add one function for check and install if not there
# Clear screen
printf "\033[2J\033[1;1H"

printf "\nWelcome to The CS Launchpad Installer!\n\n"

OS="$(uname -s)"


case "$OS" in
    Linux*) os_name="Linux" known_os=true ;;
    Darwin*) os_name="macOS" known_os=true ;;
    CYGWIN*|MINGW*|MSYS*) os_name="Windows" known_os=true ;;
    *) os_name=OS known_os=false ;;
esac

if [ "$known_os" != "true" ]; then
    printf "Unknown OS detected: $OS\nAborting."
    exit 1
fi

printf "OS detected succesfully!\n\nStarting installation for $os_name...\n\nChecking for prerequisites:\n"


# Functions are defined BEFORE calling to prevent error

check_linux() {
    # Check if sudo exists
    if ! command -v sudo > /dev/null 2>&1; then
        printf "Sudo not found. Aborting.\n"
        exit 1
    fi

    # Check if user has sudo privileges
    if sudo -n true 2>&1 | grep -q "a password is required\|incorrect password"; then
        printf "\t> Sudo is installed and User has access!\n"
    elif sudo -v -n > /dev/null 2>&1 || [ $? -eq 0 ]; then
        printf "\t>Sudo is installed and User has access!\n"
    else
        printf "User does not have access to Sudo. Aborting.\n"
        exit 1
    fi

    # Check for internet by pinging reliable IP adress
    if ping -c 1 -W 1 8.8.8.8 >/dev/null 2>&1; then
        printf "\t> Connected to internet!\n"
    else
        printf "Not connected to internet. Aborting\n"
        exit 1
    fi

    # Check for Pacman
    if command -v pacman > /dev/null 2>&1; then
        printf "\t> Pacman is installed!\n"
    else
        printf "Pacman is not installed. Aborting.\n"
        exit 1
    fi

    printf "\nAll prerequisites found!\n\nChecking for apps to install:\n"

    # Check for Git
    if command -v git > /dev/null 2>&1; then
        printf "\t> Git: already installed!\n"
    else
        printf "\t> Installing Git...\n"
        sudo pacman -Sy -q --noconfirm git && printf "\t> Git succesfully installed!\n"
    fi

    # Check for Python
    if command -v python3 > /dev/null 2>&1; then
        printf "\t> Python: already installed!\n"
    else
        sudo pacman -Sy -q --noconfirm python3 && printf "\t> Python succesfully installed!\n"
    fi

    # Check for VS Code
    if command -v code > /dev/null 2>&1; then
        printf "\t> VS Code: already installed!\n"
    else
        # Install Code OSS with pacman
        sudo pacman -Sy -q --noconfirm code && printf "\t> VS Code succesfully installed!\n"
    fi

    # Check for GitHub CLI
    if command -v gh > /dev/null 2>&1; then
        printf "\t> GitHub CLI: already installed!\n"
    else
        sudo pacman -Sy -q --noconfirm github-cli && printf "\t> GitHub CLI succesfully installed!\n"
    fi

    printf "\nInstallation step complete!\n"

    printf "\nChecking config files:\n"


    # Git name and email

    printf "\t> Git:\n"
    GIT_NAME=$(git config --global user.name)
    if [ "$GIT_NAME" != "" ]; then
        printf "\t  - Name: $GIT_NAME\n"
    else
        printf "There is not a name in your current Git config. Please enter your name:\n"
        read name
        git config --global user.name $name
    fi

    GIT_EMAIL=$(git config --global user.email)
    if [ "$GIT_EMAIL" != "" ]; then
        printf "\t  - Email: $GIT_EMAIL\n"
    else
        printf "There is not an email in your current Git config. Please enter your email:\n"
        read email
        git config --global user.email $email
        printf "\t  - Global email set as $email\n"
    fi

    # GH CLI auth status check
    printf "\t> GitHub CLI:\n"

    if gh auth status >/dev/null 2>&1; then
        printf "\t  - GitHub CLI is already authenticated!\n"
    else
        printf "Not logged into GitHub CLI\nPlease sign in on the browser window."
        gh auth login -h github.com -p https -w --skip-ssh-key
    fi
    
}


check_mac() {
    printf \n
}

check_win() {
    printf \n
}

case $os_name in
    Linux) check_linux ;;
    macOS) check_mac ;;
    Windows) check_win ;;
esac

# Exit in case of failure
$ErrorActionPreference = "Stop"

# Clear screen
Clear-Host

Write-Output "`nWelcome to The CS Launchpad Installer!`n"
Start-Sleep -Milliseconds 500

$os_name = "Windows"

Write-Output "OS detected successfully!`n`nStarting installation for $os_name...`n`nChecking for prerequisites:"
Start-Sleep -Milliseconds 300


function Test-Command {
    param(
        [string]$Command,
        [string]$DisplayName
    )
    try {
        $null = Get-Command $Command -ErrorAction Stop
        Write-Output "`t> $DisplayName is installed!"
        Start-Sleep -Milliseconds 300
    } catch {
        Write-Output "$DisplayName is not installed. Aborting."
        exit 1
    }
}

$ConnectivityHosts = @('1.1.1.1','8.8.8.8')

function Test-InternetConnection {
    foreach ($target in $ConnectivityHosts) {
        try {
            $res = Test-NetConnection -ComputerName $target -InformationLevel Quiet -ErrorAction Stop
            if ($res) { return $true }
        } catch {
            Write-Verbose "Connection to $target failed"
        }
    }
    return $false
}

function Install-Winget {
    Write-Output "`t> Installing winget..."
    $installerUrl = "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    $tempFile = Join-Path $env:TEMP "Microsoft.DesktopAppInstaller.msixbundle"

    try {
        Invoke-WebRequest -Uri $installerUrl -OutFile $tempFile -ErrorAction Stop | Out-Null
        Add-AppxPackage -Path $tempFile -ErrorAction Stop
        Write-Output "`t> Winget successfully installed!"
    } catch {
        Write-Output "`t> Error: Failed to install winget. Aborting."
        exit 1
    } finally {
        if (Test-Path $tempFile) {
            Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
        }
    }
}

function Install-PackageIfMissing {
    param(
        [string]$Command,
        [string]$Package,
        [string]$DisplayName
    )
    try {
        $null = Get-Command $Command -ErrorAction Stop
        Write-Output "`t> ${DisplayName}: Already installed!"
        Start-Sleep -Milliseconds 200
    } catch {
        Write-Output "`t> Installing $DisplayName..."
        & winget install --id $Package -q --accept-source-agreements --accept-package-agreements 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Output "`t> $DisplayName successfully installed!"
        } else {
            Write-Warning "`t> Warning: $DisplayName installation had issues, but continuing..."
        }
    }
}

function Test-Windows {
    Write-Output "Checking for administrative privileges..."
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

    if (-not $isAdmin) {
        Write-Error "Administrator privileges are required. Aborting."
        exit 1
    }

    # Check for internet connectivity
    if (Test-InternetConnection) {
        Write-Output "`t> Connected to internet!"
    } else {
        Write-Output "Not connected to internet. Aborting"
        exit 1
    }

    # Check for PowerShell
    try {
        $null = Get-Command powershell -ErrorAction Stop
    } catch {
        try {
            $null = Get-Command pwsh -ErrorAction Stop
        } catch {
            Write-Output "PowerShell is required. Aborting."
            exit 1
        }
    }
    Write-Output "`t> PowerShell is available!"

    # Check for winget
    try {
        $null = Get-Command winget -ErrorAction Stop
        Write-Output "`t> Winget is installed!"
    } catch {
        Write-Output "`t> Winget not found. Installing winget now..."
        Install-Winget
    }

    Write-Output "`n[1/3] All prerequisites found (or will be installed).`n"
    Start-Sleep -Milliseconds 500
}

function Install-Windows {
    Write-Output "Installing packages using Winget.`n"

    # Install Git
    Install-PackageIfMissing -Command "git" -Package "Git.Git" -DisplayName "Git"

    # Install Python
    Install-PackageIfMissing -Command "python" -Package "Python.Python.3.12" -DisplayName "Python"

    # Install VS Code
    Install-PackageIfMissing -Command "code" -Package "Microsoft.VisualStudioCode" -DisplayName "VS Code"

    # Install GitHub CLI
    Install-PackageIfMissing -Command "gh" -Package "GitHub.cli" -DisplayName "GitHub CLI"

    Write-Output "`n[2/3] Installation step complete!`n"
    Start-Sleep -Milliseconds 500
}

function Set-GitConfig {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param()
    Write-Output "`t> Git:"

    $gitName = & git config --global user.name 2>$null
    if ($gitName) {
        Write-Output "`t  - Name: $gitName"
        Start-Sleep -Milliseconds 200
    } else {
        Write-Output "There is not a name in your current Git config. Please enter your name:"
        $name = Read-Host
        try {
            if ($PSCmdlet.ShouldProcess("Global git config user.name","Set to $name")) {
                & git config --global user.name $name
                Write-Output "`t  - Global name set as $name"
            } else {
                Write-Output "`t  - Skipped setting git user.name"
            }
        } catch {
            Write-Error "Error: Failed to set Git name. Aborting."
            exit 1
        }
    }

    $gitEmail = & git config --global user.email 2>$null
    if ($gitEmail) {
        Write-Output "`t  - Email: $gitEmail"
        Start-Sleep -Milliseconds 200
    } else {
        Write-Output "There is not an email in your current Git config. Please enter your email:"
        $email = Read-Host
        try {
            if ($PSCmdlet.ShouldProcess("Global git config user.email","Set to $email")) {
                & git config --global user.email $email
                Write-Output "`t  - Global email set as $email"
            } else {
                Write-Output "`t  - Skipped setting git user.email"
            }
        } catch {
            Write-Error "Error: Failed to set Git email. Aborting."
            exit 1
        }
    }
    Start-Sleep -Milliseconds 400
}

function Set-GitHubCLIAuth {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param()
    Write-Output "`t> GitHub CLI:"

    try {
        $null = & gh auth status 2>$null
        Write-Output "`t  - GitHub CLI is already authenticated!"
        Start-Sleep -Milliseconds 300
    } catch {
        Write-Output "Not logged into GitHub CLI`nPlease sign in on the browser window."
        try {
            if ($PSCmdlet.ShouldProcess("GitHub CLI authentication","Open browser to authenticate")) {
                & gh auth login --hostname github.com --protocol https --web --skip-ssh-key
            } else {
                Write-Output "`t  - Skipped GitHub CLI authentication"
            }
        } catch {
            Write-Warning "Warning: GitHub CLI authentication failed. You can authenticate later with 'gh auth login'."
        }
    }
}

function Set-WindowsConfiguration {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param()
    Write-Output "`nChecking config files:"
    Start-Sleep -Milliseconds 300

    if ($PSCmdlet.ShouldProcess("System configuration","Apply Git and GitHub CLI configuration")) {
        Set-GitConfig
        Set-GitHubCLIAuth
    } else {
        Write-Output "`t> Skipped configuration steps"
    }

    Write-Output "`n`n[3/3] Everything is configured!`n"
}

# Main execution
Test-Windows
Install-Windows
Set-WindowsConfiguration

Write-Output "Installation complete! You're ready to get started with CS Launchpad."

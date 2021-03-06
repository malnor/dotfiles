
$installActions = @(
    ###  ------ Require administrator privileges ------ ###
    "RequireAdmin",

    ### ------ Requred package manager for install ------ ###
    "InstallChocolatey",

    ### ------ Development tools ------ ###
    "InstallVisualStudioCode",
    "InstallGit",
    "InstallBeyondCompare",
    # "InstallRider",
    "InstallTotalCommander",
    "InstallConEmu",
    "InstallDocker",
    "InstallDotNetCore",
    "InstallNodeJs",
    "InstallTelnet",
    "InstallCurl",
    "InstallSourceTree",
    "InstallInkScape",
    "InstallPowershell"
    "InstallYarn"

    ###  ------ Utilities ------ ###
    "InstallEverythingSearch",

    ###  ------ Browsers ------ ###
    "InstallFirefox",
    "InstallChrome",

    ###  ------ Social ------ ###

    ###  ------ Media ------ ###
    "InstallSpotify",

    ###  ------ Storage ------ ###
    "InstallOneDrive"
)

Function InstallChocolatey {
    if(Get-CommandAvailable 'choco'){
        Install-Package 'chocolatey' 'Chocolatey'
    } else {
        Write-Host -NoNewline "Installing Chocolatey... "
        # https://chocolatey.org/install
        Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) | Out-Null
        Write-Host "done!"
    }
}

Function UninstallChocolatey {
    # https://chocolatey.org/docs/uninstallation
    Remove-Item -Recurse -Force "$env:ChocolateyInstall"
    [System.Text.RegularExpressions.Regex]::Replace([Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Environment').GetValue('PATH', '', [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames).ToString(), [System.Text.RegularExpressions.Regex]::Escape("$env:ChocolateyInstall\bin") + '(?>;)?', '', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase) | %{[System.Environment]::SetEnvironmentVariable('PATH', $_, 'User')}
    [System.Text.RegularExpressions.Regex]::Replace([Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SYSTEM\CurrentControlSet\Control\Session Manager\Environment\').GetValue('PATH', '', [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames).ToString(),  [System.Text.RegularExpressions.Regex]::Escape("$env:ChocolateyInstall\bin") + '(?>;)?', '', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase) | %{[System.Environment]::SetEnvironmentVariable('PATH', $_, 'Machine')}
}

Function InstallVisualStudioCode {
    Install-Package 'visualstudiocode' 'Visual Studio Code' @(
        '/NoDesktopIcon',
        '/NoQuicklaunchIcon',
        '/NoContextMenuFiles',
        '/NoContextMenuFolders'
    )

    New-Item -Type HardLink -Force -Path $env:APPDATA\Code\User -Name settings.json -Target $PSScriptRoot\config\vscode\settings.json | Out-Null
    New-Item -Type HardLink -Force -Path $env:APPDATA\Code\User -Name keybindings.json -Target $PSScriptRoot\config\vscode\keybindings.json | Out-Null

    code --install-extension ow.vscode-subword-navigation
    code --install-extension ms-vscode.powershell
    code --install-extension dbaeumer.vscode-eslint
}

Function UninstallVisualStudioCode {
    Uninstall-Package "visualstudiocode"
}

Function InstallGit {
    Install-Package 'git.install' 'Git' @(
        '/NoShellIntegration', # Disables shell integration ( "Git GUI Here" and "Git Bash Here" entries in context menus).
        '/NoGitLfs', # Disable Git LFS installation.
        '/GitAndUnixToolsOnPath' #Include unit tools in path
    )

    if(Test-Path $PSScriptRoot\config\git\gitconfig.local -ne $null)
    {
        Copy-Item -Path $PSScriptRoot\config\git\gitconfig.local -Destination $HOME\.gitconfig.local | Out-null
    }
    New-Item -ItemType HardLink -Force -Path $HOME -Name .gitignore -Value $PSScriptRoot\config\git\gitignore | Out-null
    New-Item -ItemType HardLink -Force -Path $HOME -Name .gitattributes -Value $PSScriptRoot\config\git\gitattributes | Out-null
    New-Item -ItemType HardLink -Force -Path $HOME -Name .gitconfig -Value $PSScriptRoot\config\git\gitconfig | Out-null
}

Function UninstallGit {
    Uninstall-Package "git"
}

Function InstallPowershell {
    Install-Package 'powershell-core' 'Powershell Core'

    # Setup profile location
    New-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' Personal -Value $env:userprofile -Type ExpandString -Force
    New-Item -ItemType HardLink -Force -Path $env:userprofile\powershell -Name Microsoft.PowerShell_profile.ps1 -Value $PSScriptRoot\config\powershell\Microsoft.PowerShell_profile.ps1 | Out-null

    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    Install-Module -Name 'Get-ChildItemColor'
    Install-Module -Name 'posh-git'
    Install-Module -Name 'oh-my-posh'
}

Function UninstallPowershell {
    Uninstall-Package 'powershell-core'

    Uninstall-Package 'poshgit'
}

Function InstallYarn { Install-Package 'yarn' 'Yarn' }
Function UninstallYarn { Uninstall-Package 'yarn' }

Function InstallBeyondCompare { Install-Package 'beyondcompare' 'Beyond Compare' }
Function UninstallBeyondCompare { Uninstall-Package 'beyondcompare' }

Function InstallInkScape { Install-Package 'inkscape' 'InkScape' }
Function UninstallInkScape { Uninstall-Package 'inkscape' }

Function InstallLockhunter { Install-Package 'lockhunter' 'Lock Hunter' }
Function UninstallLockhunter { Uninstall-Package 'lockhunter' }

Function InstallRider {
    Invoke-WebRequest -Uri "https://download.jetbrains.com/resharper/JetBrains.Rider-2017.2.1.exe" -OutFile "c:\install\rider.exe"
    & "c:\installer\rider.exe /S"
}

Function UninstallRider {
    & ExecWait '"$INSTDIR\uninstaller.exe" /S _?=$INSTDIR'
}

Function InstallEverythingSearch {
    Install-Package 'everything' 'Everything (search)', @(
    '/efu-association', # - Install EFU file association.
    '/run-on-system-startup', # - Install "Everything" in the system startup.
    '/service' # - Install and start the "Everything" service.
    )
}

Function InstallTotalCommander {
    Install-Package 'totalcommander' 'TotalCommander'

    Remove-Item $env:APPDATA\Ghisler\wincmd.ini -ErrorAction Ignore
    New-Item -Type HardLink -Force -Path $env:APPDATA\Ghisler -Name wincmd.ini -Target $PSScriptRoot\config\totalcommander\wincmd.ini | Out-Null
}

Function UninstallTotalCommander {
    Uninstall-Package 'totalcommander' 'TotalCommander'

    Remove-Item $env:APPDATA\Ghisler\wincmd.ini -ErrorAction Ignore
}

Function InstallConEmu {
    $powerfontslocation = "$env:USERPROFILE\powerfonts"
    git clone https://github.com/powerline/fonts.git $powerfontslocation
    Push-Location
    Set-Location $powerfontslocation
    .\install.ps1
    Pop-Location

    Install-Package 'conemu' 'ConEmu'

    Remove-Item $env:APPDATA\ConEmu.xml -ErrorAction Ignore
    New-Item -Type HardLink -Force -Path $env:APPDATA -Name ConEmu.xml -Target $PSScriptRoot\config\conemu\ConEmu.xml | Out-Null
}
Function UninstallConEmu { Uninstall-Package 'conemu' 'ConEmu' }


Function InstallDocker { Install-Package 'docker-for-windows' 'Docker' }
Function UninstallDocker { Uninstall-Package 'docker-for-windows' }



Function InstallDotNetCore {
    Install-Package 'dotnetcore-sdk' '.NET Core SDK'
    # Opt out of telemetry https://docs.microsoft.com/en-us/dotnet/core/tools/telemetry
    [Environment]::SetEnvironmentVariable("DOTNET_CLI_TELEMETRY_OPTOUT", "1", "Machine") | Out-Null
}
Function UninstallDotNetCore {
    Uninstall-Package 'dotnetcore-sdk'
    Remove-Item Env:\DOTNET_CLI_TELEMETRY_OPTOUT -ErrorAction SilentlyContinue
}

Function InstallSourceTree { Install-Package 'sourcetree' 'SourceTree' }
Function UninstallSourceTree { Uninstall-Package 'sourcetree' }

Function InstallTelnet { Install-Package 'telnet' 'Telnet' }
Function UninstallTelnet { Uninstall-Package 'telnet' }

Function InstallCurl { Install-Package 'curl' 'Curl' }
Function UninstallCurl { Uninstall-Package 'curl' }

Function InstallNodeJs { Install-Package 'nodejs.install' 'Node.js' }
Function UninnstallNodeJs { Uninstall-Package 'nodejs.install' }

Function InstallEverythingSearch { Uninstall-Package 'everything'}
Function InstallEverythingSearch { Uninstall-Package 'everything'}

Function InstallSpotify { Install-Package 'spotify' 'Spotify'}

Function UninstallSpotify { Uninstall-Package 'spotify' }

Function InstallFirefox { Install-Package 'firefox' 'Firefox' }

Function UninstallFirefox { Uninstall-Package 'firefox' }

Function InstallChrome { Install-Package 'googlechrome', 'Chrome' }

Function InstallChrome { Uninstall-Package 'googlechrome' }

Function InstallOneDrive { Install-Package 'onedrive' 'OneDrive' }

Function InstallOneDrive { Uninstall-Package 'onedrive' 'OneDrive' }

##########
# Auxiliary Functions
##########

# Relaunch the script with administrator privileges
Function RequireAdmin {
	If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
		Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $PSCommandArgs" -WorkingDirectory $pwd -Verb RunAs
		Exit
	}
}

Function Remove-DesktopShortcuts {
    Get-ChildItem -Path $env:USERPROFILE\Desktop -Filter *.lnk | ForEach-Object { Remove-Item $_ -ErrorAction SilentlyContinue }
}
Function Uninstall-Package([string] $packageName) {
    if(Get-CommandAvailable "choco") {
        Invoke-Expression "choco uninstall $packageName --confirm" -ErrorAction SilentlyContinue | Out-Null
    } else {
        Write-Host "Command 'choco' is not available. Is Chocolatey installed?" -ForegroundColor Red
        Exit
    }
}

Function Install-Package($packageName, $dispayName, $arguments){
    $chocoArgs = "--params='$($arguments -join ' ')'"

    if(Get-CommandAvailable "choco") {
        $operation = if(Test-PackageInstalled $packageName) {"upgrade"} else {"install"}
        Write-Host -NoNewline "Performing $operation of $dispayName..."
        Invoke-Expression "choco $operation $packageName $chocoArgs --confirm" -ErrorAction Stop | Out-Null
        Remove-DesktopShortcuts
        Write-Host "done!" -ForegroundColor Green
    } else {
        Write-Host "Command 'choco' is not available. Is Chocolatey installed?" -ForegroundColor Red
        Exit
    }
}

Function Test-PackageInstalled($packageName) {
    $matchFound = $false
    Invoke-Expression "choco list --local-only" | ForEach-Object {
        $installedName = $_.Split(" ") | Select-Object -First 1;
        if($installedName -eq $packageName) {
            $matchFound = $true
        }
    }
    return $matchFound
}

function Get-CommandAvailable([string] $cmdName) {
    if (Get-Command $cmdName -errorAction SilentlyContinue)
    {
        return $true;
    }
    return $false;
}

##########
# Parse parameters and apply tweaks
##########

# Normalize path to preset file
$preset = ""
$PSCommandArgs = $args
If ($args -And $args[0].ToLower() -eq "-preset") {
	$preset = Resolve-Path $($args | Select-Object -Skip 1)
	$PSCommandArgs = "-preset `"$preset`""
}

# Load function names from command line arguments or a preset file
If ($args) {
	$installActions = $args
	If ($preset) {
		$installActions = Get-Content $preset -ErrorAction Stop | ForEach { $_.Trim() } | Where { $_ -ne "" -and $_[0] -ne "#" }
	}
}

# Call the desired tweak functions
$installActions | ForEach { Invoke-Expression $_ }

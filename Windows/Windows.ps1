# Auto-Setup Script for my personal Windows Machines

$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath

function println{
    param(
        [String]$text
    )
    Write-Output($text + "`n");
}

function print{
    param(
        [String]$text
    )
    Write-Output($text);
}

function preRuntime{
    if (!Get-InstalledModule -Name "PSWindowsUpdate"){
        Install-Module PSWindowsUpdate;
    }
    Get-WindowsUpdate;

    # Set variables to indicate value and key to set
    $RegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem'
    $Name         = 'LongPathsEnabled'
    $Value        = '1'
    # Create the key if it does not exist
    if (-NOT (Test-Path $RegistryPath)) {
        New-Item -Path $RegistryPath -Force | Out-Null
    }  
    # Now set the value
    New-ItemProperty -Path $RegistryPath -Name $Name -Value $Value -PropertyType DWORD -Force
}

function getComponent{
    param(
        [String]$Url, [String]$FileName, [String]$FileParameters, [String]$ComponentName, [Boolean]$IsMsi, [Boolean]$IsZip
    )
    println("Getting $ComponentName...");
    wget -Uri "$Url" -OutFile "./$FileName";
    println("Installing $ComponentName...");
    if ($IsZip){
        Expand-Archive -Path "./$FileName" -DestinationPath "./" 
        Start-Process -FilePath "./$ComponentName $FileParameters" -Wait;
        return 0;
    }
    if ($IsMsi){
        MsiExec.exe /i "./$FileName" /qn;
    }else{
        Start-Process -FilePath "./$FileName $FileParameters" -Wait;
    }
    
}

function WorkstationSetup{
    $includeExtras = Read-Host "Would you like to install extra tools? <y/n>: "
    if ($includeExtras -eq "y"){
        println("Resuming with extras...")
        $extras = $true;
    }
    else{
        println("Resuming without extras...")
        $extras = $false;
    }
    mkdir -Path $dir/TEMP/;
    cd $dir/TEMP/;

    # Visual Studio Code
    getComponent -Url "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-user" -FileName "VSCodeSetup.exe" -FileParameters "/VERYSILENT /NORESTART /MERGETASKS=!runcode" -ComponentName "Visual Studio Code" -IsMsi $false -IsZip $false;

    #Visual Studio Professional
    getComponent -Url "https://c2rsetup.officeapps.live.com/c2r/downloadVS.aspx?sku=professional&channel=Release&version=VS2022&source=VSLandingPage&cid=2030" -FileName "VisualStudioSetup.exe" -FileParameters "" -ComponentName "Visual Studio Professional" -IsMsi $false -IsZip $false;

    #Python 3.10.4
    getComponent -Url "https://www.python.org/downloads/release/python-3104/" -FileName "PythonSetup.exe" -FileParameters "/quiet InstallAllUsers=1 SimpleInstall=1 PrependPath=1" -ComponentName "Python 3.10.4" -IsMsi $false -IsZip $false;

    #NodeJS LTS
    getComponent -Url "https://nodejs.org/dist/v16.14.2/node-v16.14.2-x64.msi" -FileName "NodeSetup.exe" -FileParameters "" -ComponentName "NodeJS" -IsMsi $true -IsZip $false;

    #Node Version Manager (NVM) 
    getComponent -Url "https://github.com/coreybutler/nvm-windows/releases/download/1.1.9/nvm-setup.zip" -FileName "nvm-setup.zip" -FileParameters "/SILENT" -ComponentName "nvm-setup" -IsMsi $false -IsZip $true;

    #WinSCP
    getComponent -Url "https://winscp.net/download/WinSCP-5.19.6-Setup.exe" -FileName "WinSCPSetup.exe" -FileParameters "/VERYSILENT /CURRENTUSER" -ComponentName "WinSCP" -IsMsi $false -IsZip $false;

    if ($extras){
        println("Installing extras...");

        #Spotify
        getComponent -Url "https://download.scdn.co/SpotifySetup.exe" -FileName "SpotifySetup.exe" -FileParameters "/extract 'C:\Program Files\Spotify'" -ComponentName "Spotify" -IsMsi $false -IsZip $false;
        
        #Discord
        getComponent -Url "https://discord.com/api/downloads/distributions/app/installers/latest?channel=stable&platform=win&arch=x86" -FileName "DiscordSetup.exe" -FileParameters "-s" -ComponentName "Discord" -IsMsi $false -IsZip $false;

        #Krita 
        getComponent -Url "https://download.kde.org/stable/krita/5.0.2/krita-x64-5.0.2-setup.exe" -FileName "KritaSetup.exe" -FileParameters "/S" -ComponentName "Krita" -IsMsi $false -IsZip $false;
    }
}

function PersonalSetup{
       
}

function MainMenu{
    print("######################## PanickingLynx: Automatic Workspace Setup ######################## `n `n");
    println("Please select from the following:");
    println("----------------------------------");
    println("Workstation: 1");
    println("Personal: 2");
    $decision = Read-Host "Selection: ";
    if ($decision -eq 1){
        WorkstationSetup;
    }
    elseif ($decision -eq 2){
        PersonalSetup;
    }
    else {
        clear;
        println("Please insert 1 or 2");
    }
}

MainMenu;
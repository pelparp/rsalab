# Parse arguments
param (
    [string]$GITHUB_PAT
)

#create temp directory
mkdir C:\temp
mkdir C:\lab

# Set log file path
$logFilePath = "C:\temp\install_software.log"

# Function to log messages
function LogMessage {
    param(
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $logFilePath -Value "$timestamp - $message"
}

# Clear existing log file or create a new one
Clear-Content -Path $logFilePath -ErrorAction SilentlyContinue

## Create directory C:\Lab
#try {
#    mkdir "C:\Lab" -ErrorAction Stop
#    LogMessage "Directory 'C:\Lab' created successfully."
#}
#catch {
#    LogMessage "Error creating directory: $_"
#}

## Install Chrome
#try {
#    $LocalTempDir = $env:TEMP
#    $ChromeInstaller = "ChromeInstaller.exe"
#    (New-Object System.Net.WebClient).DownloadFile('http://dl.google.com/chrome/install/375.126/chrome_installer.exe', "$LocalTempDir\$ChromeInstaller")
#    & "$LocalTempDir\$ChromeInstaller" /silent /install
#    $Process2Monitor =  "ChromeInstaller"
#    do {
#        $ProcessesFound = Get-Process | Where-Object {$Process2Monitor -contains $_.Name} | Select-Object -ExpandProperty Name
#        if ($ProcessesFound) {
#            "Still running: $($ProcessesFound -join ', ')" | Write-Host
#            Start-Sleep -Seconds 2
#        } else {
#            Remove-Item "$LocalTempDir\$ChromeInstaller" -ErrorAction SilentlyContinue -Verbose
#        }
#    } until (!$ProcessesFound)
#    LogMessage "Chrome installed successfully."
#}
#catch {
#    LogMessage "Error installing Chrome: $_"
#}

# Create directory
try {
    mkdir "C:\temp" -ErrorAction Stop
    LogMessage "Directory 'C:\temp' created successfully."
}
catch {
    LogMessage "Error creating directory: $_"
}

# Install dotnet6
try {
    Invoke-WebRequest -Uri "https://download.visualstudio.microsoft.com/download/pr/68ff350e-8b8d-4249-8678-570d5025f8e3/2178c63b5572b6016647525b53aa75b5/dotnet-sdk-6.0.420-win-x64.exe" -OutFile "C:\temp\dotnet-6.0-runtime.exe"
    Start-Process -FilePath "C:\temp\dotnet-6.0-runtime.exe" -ArgumentList "/quiet /norestart" -Wait
    LogMessage "dotnet6 installed successfully."
}
catch {
    LogMessage "Error installing dotnet6: $_"
}

# Install Libreoffice
try {
    Invoke-WebRequest -Uri "https://download.documentfoundation.org/libreoffice/stable/24.2.2/win/x86_64/LibreOffice_24.2.2_Win_x86-64.msi" -OutFile "C:\temp\LibreOffice_24.2.2_Win_x86-64.msi"
    Start-Process -FilePath "msiexec.exe" -ArgumentList "/i", "C:\temp\LibreOffice_24.2.2_Win_x86-64.msi", "/qn", "/norestart", "/lv C:\temp\logfile.log" -Wait
    LogMessage "LibreOffice installed successfully."
}
catch {
    LogMessage "Error installing LibreOffice: $_"
}

# Git clone
try {
    &"C:\Program Files\Git\bin\git.exe" clone "https://$GITHUB_PAT@github.com/rsa-lab/lab1.git" "C:\Lab"
    LogMessage "Git repository cloned successfully."
}
catch {
    LogMessage "Error cloning Git repository: $_"
}

# Add exclusion paths in Defender

powershell -command 'Add-MpPreference -ExclusionPath "c:\Lab"'
powershell -command 'Add-MpPreference -ExclusionPath "c:\Tools"'
powershell -command 'Add-MpPreference -ExclusionPath "c:\temp"'
powershell -command 'Add-MpPreference -ExclusionPath "c:\Users"'

#MFT unzip

Expand-Archive 'C:\lab\Tools\MFTECmd\DC\$MFT.zip' -DestinationPath 'C:\lab\tools\MFTECmd\DC'
Expand-Archive 'C:\lab\tools\MFTECmd\FileServer\$MFT.zip' -DestinationPath 'C:\lab\tools\MFTECmd\FileServer'
rm 'C:\lab\tools\MFTECmd\DC\$MFT.zip'
rm 'C:\lab\tools\MFTECmd\FileServer\$MFT.zip'

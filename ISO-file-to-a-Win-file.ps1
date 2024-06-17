# Script written by Saeid Esmaili on 01-03-2024
# Define variables
$isoPath = "F:\Sources\Windows11-iso\Win11_23H2_Swedish_x64v2.iso"   # Update this path
$mountPath = "F:\Sources\Windows11-iso\Mount"   # Update this path
$wimSourcePath = "$mountPath\sources\install.wim"
$wimDestinationPath = "F:\Sources\Windows11-iso\install.wim"  # Update this path if needed

# Create mount directory if it doesn't exist
if (-Not (Test-Path -Path $mountPath)) {
    New-Item -ItemType Directory -Path $mountPath
}

# Mount the ISO
Mount-DiskImage -ImagePath $isoPath
Start-Sleep -Seconds 5 # Wait a few seconds to ensure the ISO is mounted

# Get the drive letter of the mounted ISO
$diskImage = Get-DiskImage -ImagePath $isoPath
$volumes = Get-Volume -DiskImage $diskImage
$driveLetter = ($volumes | Select-Object -First 1).DriveLetter + ":\"

# Check if the drive letter is correct and accessible
if (Test-Path -Path $driveLetter) {
    Write-Host "Drive letter $driveLetter is accessible."
    
    # Copy the contents of the ISO to a local directory
    Write-Host "Copying contents from $driveLetter to $mountPath..."
    Copy-Item -Path "$driveLetter*" -Destination $mountPath -Recurse -Force
} else {
    Write-Host "Drive letter $driveLetter is not accessible. Please check the ISO mount."
    exit
}

# Check if the WIM file exists
if (Test-Path -Path $wimSourcePath) {
    Write-Host "install.wim found. Copying to destination..."
    Copy-Item -Path $wimSourcePath -Destination $wimDestinationPath -Force
    Write-Host "Copy completed. The WIM file is located at $wimDestinationPath"
} else {
    Write-Host "install.wim not found. Please check the ISO contents."
}

# Dismount the ISO
Dismount-DiskImage -ImagePath $isoPath

# Clean up
Remove-Item -Path $mountPath -Recurse -Force

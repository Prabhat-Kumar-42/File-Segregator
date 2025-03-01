# PowerShell Script to Segregate PDF, DOCX, PPT, and Image Files

[string[]]$SourcePath = @()
[string]$DestinationPath = ""
[string]$Action = ""
[switch]$SilentMode = $true

# Default settings message
function Show-Defaults {
    Write-Host "Default settings:" -ForegroundColor Yellow
    Write-Host "  - Source Path: Entire PC (all drives) if left empty"
    Write-Host "  - Enter '.' to use the current directory as the source"
    Write-Host "  - Destination Path: Current directory if left empty or if '.' is entered"
    Write-Host "  - Action: Shortcut (options: move, copy, shortcut)"
    Write-Host "  - Silent Mode: Hides scanning locations"
    Write-Host ""
}

Show-Defaults

# Ask user if they want silent mode if not provided as argument
$silentChoice = Read-Host "Enable silent mode? (Y/n) [Default: Y]"
$SilentMode = -not ($silentChoice -match "^[Nn]")

# Takes Source Path Input
while ($true) {
    $inputPath = Read-Host "Enter source path (press Enter twice to finish, '.' for current directory)" 
    if ($inputPath -eq "") {
        Write-Host "Exiting Path Input" 
        break 
    }
    elseif ($inputPath -eq ".") {
        $SourcePath += (Get-Location).Path
    } else {
        $SourcePath += $inputPath
    }
    Write-Host "Added Path to SourceList: $inputPath"
}

# If Source Path is Empty, then Defaults to whole system
if (-not $SourcePath) {
    $temp= @(Get-PSDrive -PSProvider FileSystem | ForEach-Object { $_.Root })
    $SourcePath = $temp.Split(' ')
}


# Get destination path from user if not provided
if (-not $DestinationPath) {
    $DestinationPath = Read-Host "Enter destination path (leave empty for current directory, or '.' for current directory)"
}
if (-not $DestinationPath -or $DestinationPath -eq ".") {
    $DestinationPath = (Get-Location).Path
}

# Validate action choice
$validActions = @("move", "copy", "shortcut", "m", "c", "s", "1", "2", "3")
$actionMapping = @{ "m" = "move"; "c" = "copy"; "s" = "shortcut"; "1" = "move"; "2" = "copy"; "3" = "shortcut" }
$attempts = 0
if (-not $Action) {
    $Action = Read-Host "Enter action (move, copy, shortcut) [Default: shortcut]"
    if (-not $Action) {
        Write-Host "No action entered. Defaulting to 'shortcut'." -ForegroundColor Yellow
        $Action = "shortcut"
    }
}
while ($Action -notin $validActions) {
    $attempts++
    if ($attempts -ge 4) {
        Write-Host "Invalid action entered multiple times. Script will now exit." -ForegroundColor Red
        exit
    }
    Write-Host "Invalid option! Try again ($((4 - $attempts)) attempts left)" -ForegroundColor Red
    $Action = Read-Host "Enter action (move, copy, shortcut)"
    if (-not $Action) {
        Write-Host "No action entered. Defaulting to 'shortcut'." -ForegroundColor Yellow
        $Action = "shortcut"
        break
    }
}

if ($actionMapping.ContainsKey($Action)) {
    $Action = $actionMapping[$Action]
}

Write-Host "Using Source: $SourcePath" -ForegroundColor Green
Write-Host "Using Destination: $DestinationPath" -ForegroundColor Green
Write-Host "Selected Action: $Action" -ForegroundColor Green

# Define file categories
$folders = @{
    "pdf" = "*.pdf"
    "docx" = "*.docx"
    "ppt" = "*.ppt*"
    "image" = "*.jpg", "*.jpeg", "*.png", "*.gif", "*.bmp", "*.tiff"
}

# Create destination directories
foreach ($folder in $folders.Keys) {
    $dir = "$DestinationPath\$folder"
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir | Out-Null
        Write-Host "Created folder: $dir" -ForegroundColor Cyan
    } else {
        Write-Host "Folder already exists: $dir" -ForegroundColor Yellow
    }
}

Write-Host "Source paths collected: $SourcePath"
Write-Host "Destination Path: $DestinationPath" 
# Process files
foreach ($path in $SourcePath) {
    try {
        #if (-not $SilentMode) {
            # Write-Host "Scanning: $path" -ForegroundColor Blue
        #}

        # Scan files
        Get-ChildItem -Path $path -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
            $file = $_
            $fileDir = $file.DirectoryName
            #if (-not $SilentMode) {
             #   Write-Host "Scanning: $fileDir" -ForegroundColor Blue
            #}

            try {
                # Check file category and process accordingly
                foreach ($folder in $folders.Keys) {
                    foreach ($extension in $folders[$folder]) {
                        if ($file.Name -like $extension) {
                            $destinationFile = "$DestinationPath\$folder\$($file.Name)"
                            if ($Action -eq "move") {
                                Move-Item -Path $file.FullName -Destination $destinationFile -Force
                            } elseif ($Action -eq "copy") {
                                Copy-Item -Path $file.FullName -Destination $destinationFile -Force
                            } elseif ($Action -eq "shortcut") {
                                $shortcutPath = "$DestinationPath\$folder\$($file.BaseName).lnk"
                                if (!(Test-Path $shortcutPath)) {
                                    $WshShell = New-Object -ComObject WScript.Shell
                                    $Shortcut = $WshShell.CreateShortcut($shortcutPath)
                                    $Shortcut.TargetPath = $file.FullName
                                    $Shortcut.Save()
                                }
                            }
                            if (-not $SilentMode) {
                                Write-Host "Processed: $($file.Name) -> $folder" -ForegroundColor Green
                            }
                            break
                        }
                    }
                }
            } catch {
                Write-Host "Access denied to $fileDir. Skipping..." -ForegroundColor Red
            }
        }
    } catch {
        Write-Host "Access denied to $path. Skipping..." -ForegroundColor Red
    }
}

Write-Host "File segregation completed!" -ForegroundColor Cyan
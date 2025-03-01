# 📂 PowerShell Script to Segregate PDF, DOCX, PPT, and Image Files

## 📌 Overview
This PowerShell script scans a specified source directory (or the entire system if unspecified) to locate and segregate PDF, DOCX, PPT, and image files (JPG, PNG, GIF, BMP, TIFF) into separate folders. Users can choose to move, copy, or create shortcuts for these files at a specified destination.

## ✨ Features
- Supports scanning the entire system, specific directories, or the current directory.
- Allows moving, copying, or creating shortcuts for files.
- Silent mode to hide scanning logs.
- Automatically creates necessary folders for segregated files.
- Handles access permission issues gracefully.

## 🚀 Usage

### 1️⃣ Running the Script
1. Open PowerShell.
2. Navigate to the script directory.
3. Run the script:
   ```powershell
   .\segregate_files.ps1
   ```

### 2️⃣ Configuration Options
During execution, the script prompts for:
- **Source Path**: Enter directories to scan (press Enter twice to finish, `.` for the current directory, or leave empty to scan the entire system).
- **Destination Path**: Leave empty or enter `.` for the current directory.
- **Action**:
  - `move` (or `m` / `1`): Moves files to the destination.
  - `copy` (or `c` / `2`): Copies files to the destination.
  - `shortcut` (or `s` / `3`): Creates shortcuts instead of moving/copying (default option).
- **Silent Mode**: Suppresses scanning messages if enabled (`Y`/`N`).

### 3️⃣ Example Execution
```powershell
Enter source path (press Enter twice to finish, '.' for current directory): C:\Users\John\Documents
Enter destination path (leave empty for current directory, or '.' for current directory): D:\SortedFiles
Enter action (move, copy, shortcut) [Default: shortcut]: move
Enable silent mode? (Y/n) [Default: Y]: Y
```

## 📂 File Segregation Logic
The script organizes files into the following categories:
- **PDF Files** (`*.pdf`) → `Destination\pdf`
- **Word Documents** (`*.docx`) → `Destination\docx`
- **PowerPoint Presentations** (`*.ppt, *.pptx`) → `Destination\ppt`
- **Images** (`*.jpg, *.jpeg, *.png, *.gif, *.bmp, *.tiff`) → `Destination\image`

## ⚠️ Error Handling
- If a directory is inaccessible, it is skipped with an error message.
- If an invalid action is entered more than 3 times, the script exits.
- Existing destination folders are reused; new ones are created if necessary.

## 🔧 Requirements
- Windows PowerShell (version 5.1 or later recommended)
- Administrator privileges (if scanning the entire system)

## 📜 Notes
- If files with the same name exist in the destination, they will be overwritten.
- Shortcuts are created with `.lnk` extensions.
- Large file scans may take time, especially on extensive directories.

## 📜 License
This script is open-source and can be modified as needed.

## 👨‍💻 Author
Developed by Prabhat


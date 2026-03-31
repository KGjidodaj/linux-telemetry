# Linux Telemetry & Active Remediation Utility (system_audit.sh) [Updating as I go]

## Overview
This project is an automated Bash script that provides a real-time interactive dashboard for System Administrators and DevOpsSec Engineers.
Instead of manually typing individual Linux diagnostic commands in the CLI, this script wraps the system diagnostic tools into a continuous log-generating session loop. 

It acts like a "First-Responder" runbook. You drop it into any Bare-Metal Linux, VM, or Docker Container, and it can help with Triage, Forensics, and Remediation capabilities using strictly native Linux `coreutils`.
Done this way to avoid compatibility and dependencies errors.

## Core Architecture & Advanced Features

* **Dynamic Log Rotation:** The script prevents disk exhaustion by actively monitoring the `audit.log` file size every time it is run. During installation it also prompts the user for a preferred log size limit, exports it dynamically to `.bashrc` and automatically updates to preserve disk space.
* **Context-Aware Execution:** Automatically detects the underlying OS (`/etc/os-release`) and adjusts package managers and commands accordingly.[Updating]
* **Dependency Auto Remediation:** The script automatically checks for missing networking packages (like `iproute2` to track network info) and then attempts to install them without crashing.
* **Docker SafeGuards:** Identifies containerized environments via `/.dockerenv` and disables incompatible commands like `systemd`/`journalctl` to prevent crashes.
* **Subshell UX Handling:** Input prompts are extracted from logging pipes to prevent terminal-freezing glitches and ensure a smooth User Experience.
* **Security Forensics:** Scans for tampered files (`find / -mmin`), reviews kernel logs (`dmesg`), and analyzes SSH login attempts. Helping the user find possible breaches.
* **Active Remediation:** It allows the user to identify resource heavy PIDs with `top` command , execute graceful or forceful kills (if the first does not work) and automatically restart affected services asking only for the sevice name.

## Testing & Environment Certification
To ensure maximum portability and no host-system corruption, the telemetry utility was tested inside isolated **Docker Containers** running stripped down Ubuntu environments.
This guarantees it can be safely deployed on any bare-metal server or headless container.

## Installation & Usage

To ensure maximum usability this script includes a **Self-Installing Global Alias mechanism** by modifying the `~/.bashrc` file the first time it is run.

**Step 1: Download & Initialization Durin First Run (each linked to a command)**
1) Clone the repository to your local machine. 2) Navigate into the directory. 3) Modify any needed permissions. 4) Execute the script directly to initialize the installation and configure your dynamic log limits:

```bash
git clone [https://github.com/KGjidodaj/linux-telemetry.git](https://github.com/KGjidodaj/linux-telemetry.git)
cd linux-telemetry
chmod +x system_audit.sh
./system_audit.sh
```
**Step 2: Daily Operation **
Once initialized simply type (`telemetry`) from anywhere in your terminal to launch the Hyper-Menu and begin monitoring or remediating your system.

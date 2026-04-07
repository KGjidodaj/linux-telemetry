# Linux Telemetry & Active Remediation Utility (`system_audit.sh`)

### Overview
This project is an automated Bash script that provides a real-time interactive dashboard for System Administrators and DevSecOps Engineers. Instead of manually typing individual Linux diagnostic commands in the CLI, this script wraps the system diagnostic tools into a continuous log-generating session loop.

It acts like a "First-Responder" runbook. You drop it into any bare-metal Linux, VM, or Docker Container, and it provides Triage, Forensics, and Remediation capabilities using strictly native Linux Coreutils. This architecture is intentionally chosen to avoid compatibility and dependency errors across different environments.

### Core Architecture & Advanced Features
* **Dynamic Log Rotation:** The script prevents disk exhaustion by actively monitoring the `audit.log` file size every time it is run. During initialization, it prompts the user for a preferred log size limit, exports it dynamically to `.bashrc`, and automatically updates to preserve disk space.
* **Context-Aware Execution:** Automatically detects the underlying OS (`/etc/os-release`) and adjusts package managers (`apt`, `pacman`, `apk`, `dnf`, `zypper`) and commands accordingly.
* **Dependency Auto-Remediation:** The script automatically checks for missing networking packages (like `iproute2` to track socket statistics) and attempts to install them gracefully in the background without crashing.
* **Docker Safeguards:** Identifies containerized environments via `/.dockerenv` and disables incompatible commands (like `systemd` / `journalctl`) to prevent execution failures. It also dynamically strips ANSI color outputs to keep logs clean in minimal environments.
* **Subshell UX Handling & ANSI UI:** Input prompts are strategically extracted from logging pipes to prevent terminal-freezing glitches. The dashboard features a complete, context-aware ANSI color interface for a premium User Experience.
* **Security Forensics:** Scans for recently tampered files (`find / -mmin`), reviews kernel logs (`dmesg`), and analyzes SSH login attempts, helping the user pinpoint possible breaches.
* **Active Remediation:** Allows the user to identify resource-heavy PIDs with the `top` command, execute graceful or forceful kills, and automatically restart affected services by securely prompting for the exact service name.

### Testing & Environment Certification
To ensure maximum portability and zero host-system corruption, the telemetry utility was extensively tested inside isolated Docker Containers running stripped-down Ubuntu environments. This guarantees it can be safely deployed on any production bare-metal server or headless container.

### Installation & Usage
To ensure maximum usability, this script includes a **Self-Installing Global Alias** mechanism by dynamically modifying the `~/.bashrc` file the first time it is run.

**Step 1: Download & Initialization (First Run)**
Clone the repository to your local machine, navigate into the directory, modify execution permissions, and execute the script directly to initialize the installation:

```bash
git clone [https://github.com/KGjidodaj/linux-telemetry.git](https://github.com/KGjidodaj/linux-telemetry.git)
cd linux-telemetry
chmod +x system_audit.sh
./system_audit.sh ```

Step 2: Daily Operation
Once initialized, simply type the following command from anywhere in your terminal to launch the Hyper-Menu and begin monitoring or remediating your system:

Bash
`telemetry`

---
*Built via Headless SSH sessions. All code authored directly in the terminal via nano editor and tested in docker containers*

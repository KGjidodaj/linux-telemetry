# Linux System Telemetry & Audit

> An interactive, strictly CLI-based system diagnostic tool designed to retrieve hardware and partition metrics dynamically.

## Overview
This project is an automated Bash orchestrator that provides a real-time dashboard for System Administrators.
Instead of manually typing individual Linux diagnostic commands, this script wraps the system diagnostic tools (`uptime`, `free`, `df`) into a continuous, log-generating session loop.

## 🚀 Installation & Usage

To ensure maximum usability, this script includes a **Self-Installing Global Alias mechanism** by modifying the ~/.bashrc file.

## Advanced Features (system_audit.sh)
- **Dependency Auto-Remediation:** The script automatically checks for missing networking packages (like `iproute2`) and attempts to install them without crashing.
- **Subshell UX Handling:** Input prompts (`read`) are safely extracted from logging pipes to prevent random (terminal freezing) glitches and ensure a smooth User Experience.

## Testing & Environment Certification
To ensure maximum portability and zero host-system corruption during dependency auto-remediation, the `system_audit.sh` utility was also tested inside isolated **Docker Containers** running minimal Ubuntu environments.
This guarantees it can be safely deployed on any bare-metal server or headless container.


**Step 1: Download & Initialization (First Run)**
Clone the repository to your local machine, navigate into the directory, and execute the script directly to initialize the installation:
```bash
git clone [https://github.com/KGjidodaj/linux-telemetry.git](https://github.com/KGjidodaj/linux-telemetry.git)
cd linux-telemetry
chmod +x system_audit.sh
./system_audit.sh

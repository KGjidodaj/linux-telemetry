# Linux System Telemetry & Audit

> An interactive, strictly CLI-based system diagnostic tool designed to retrieve hardware and partition metrics dynamically.

## Overview
This project is an automated Bash orchestrator that provides a real-time dashboard for System Administrators.
Instead of manually typing individual Linux diagnostic commands, this script wraps the system diagnostic tools (`uptime`, `free`, `df`) into a continuous, log-generating session loop.

## 🚀 Installation & Usage

To ensure maximum usability, this script includes a **Self-Installing Global Alias mechanism** by modifying the ~/.bashrc file.

**Step 1: Download & Initialization (First Run)**
Clone the repository to your local machine, navigate into the directory, and execute the script directly to initialize the installation:
```bash
git clone [https://github.com/KGjidodaj/linux-telemetry.git](https://github.com/KGjidodaj/linux-telemetry.git)
cd linux-telemetry
chmod +x system_audit.sh
./system_audit.sh

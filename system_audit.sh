#!/bin/bash

# =================================================================
# System Specs Script
# Author: Kristian Gjidodaj
# Description: It gathers metrics for CPU, RAM, and Disk.
# =================================================================

# Variables
Date_var=$(date "+%Y-%m-%d %H:%M:%S")
user=$(whoami)

# using a divider to clarify output
DIVIDER="---------------------------------------------------"

echo "Hello $user"
read -p "Would you like to learn your system metrics?(Yes/No) " User_choice

if [[ "$User_choice" == "yes" || "$User_choice" == "Yes" ]]; then

	#### Logging the metrics into system_audit.log along with showing them to the screen for the user
	{
	echo "$DIVIDER"
	echo "   SYSTEM AUDIT REPORT - $Date_var "
	echo -e "$DIVIDER\n"

	sleep 0.5

	# 1. RAM Check
	# 'free -h' to convert to readable form (MB/GB)
	echo "[*] MEMORY USAGE (RAM):"
	free -h
	echo ""

	sleep 1

	# 2. Disk Check
	# 'df -h /' shows the space in the root partition (Root)
	echo "[*] DISK SPACE ALLOCATION (Root /):"
	### (df -h) to be in human readable form with (/) to output info reovlving the root partition
	df -h /
	echo ""

	sleep 1

	# 3. CPU LOAD
	# 'uptime' show the Load Average (1, 5 and 15 minutes ago)
	echo "[*] CPU LOAD AVERAGE & UPTIME:"
	uptime

	echo ""
	echo "$DIVIDER"
	echo "       Audit Successfully Completed."
	} | tee -a "system_audit.log"

elif [[ "$User_choice" == "No" || "$User_choice" == "no" ]]; then

	echo "Goodbye then. Exiting..."
	sleep 0.5

#if the user does not input yes or no by mistake 
else
	echo "Wrong answer format try again"

fi

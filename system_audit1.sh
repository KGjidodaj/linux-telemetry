#!/usr/bin/env bash

# =================================================================
# System Specs Script
# Author: Kristian Gjidodaj
# Description: It gathers metrics for CPU, RAM, and Disk.
# =================================================================

clear 
# Variables
Date_var=$(date "+%Y-%m-%d %H:%M:%S")
user=$(whoami)

# using a divider to clarify output
DIVIDER="---------------------------------------------------"

echo -e "Hello $user\n"


while true
	do

	read -p "Would you like to learn your system metrics?(Yes/No) " answer

	if [[ $answer == "Yes" || $answer == "yes" ]];then

		echo "What would you like to do? Here are the options:"
		echo -e "1.uptime\n2.free-h\n3.df -h /\n" 

		read user_choice
	      { #### Logging the metrics into system_audit.log along with showing them to the screen for the user
       		echo "$DIVIDER"
        	echo "   SYSTEM AUDIT REPORT - $Date_var "
        	echo -e "$DIVIDER\n"


		case $user_choice in

			1)
			   # 3. CPU LOAD
        		   # 'uptime' show the Load Average (1, 5 and 15 minutes ago)
		           echo "[*] CPU LOAD AVERAGE & UPTIME:"
			   uptime

			   sleep 0.5;;
			2)
			   # 1. RAM Check
        		   # 'free -h' to convert to readable form (MB/GB)
        		   echo "[*] MEMORY USAGE (RAM):"
        		   free -h
        		   echo ""

			   sleep 1;;
			3)
			   # 2. Disk Check
		           # 'df -h /' shows the space in the root partition (Root)
        		   echo "[*] DISK SPACE ALLOCATION (Root /):"
       			   ### (df -h) to be in human readable form with (/) to output info reovlving the root partition
        		   df -h /
        		   echo ""

			   sleep 0.5;;
			*)
			   echo "Invalid input"

		esac

		echo ""
        	echo "$DIVIDER"
        	echo "       Audit Successfully Completed."

		} | tee -a "audit.log"


	elif [[ $answer == "No" || $answer == "no" ]]; then
		exit 0
	else
		echo " Wrong format try again"
	fi

	done

exit 0

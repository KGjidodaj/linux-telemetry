#!/usr/bin/env bash

# =================================================================
# System Specs Script
# Author: Kristian Gjidodaj
# Description: It gathers metrics for CPU, RAM, and Disk.
# =================================================================

clear # Keeping the terminal clean

#Modifying .bashrc file when it is run for the first time so telemetry command is active and can be run with the command telemetry

if ! grep -q "alias telemetry=" ~/.bashrc  ;then

        location="$PWD/system_audit.sh"
        echo -e "alias telemetry='$location'" >> ~/.bashrc
	echo "Restarting session"
	echo "Script can be run via the (telemetry) command."
	sleep 1
	first_time=true
	exec bash
fi

# Variables:

## Date_var : Updates with every loop to show the time in the correct format ISO 8601.
## answer : Checks user answer in the first read.
## user_choice : Checks user choice for the case statement.

session_date_var=$(date "+%Y-%m-%d %H:%M:%S")
user=$(whoami) 
LOG_FILE="$HOME/linux-telemetry/audit.log"

# using a divider to clarify output
DIVIDER="---------------------------------------------------"

echo -e "Hello $user\n"

while :
	do

	read -p "Would you like to learn your system metrics?(Yes/No) " answer

	if [[ $answer == "Yes" || $answer == "yes" ]];then

	        #### Logging the metrics into system_audit.log along with showing them to the screen for the user
		echo "SESSION STARTED: $session_date_var" | tee -a "$LOG_FILE" #Session date that states when the user started the script (future idea of background work and automation)

		while [[ ! -f "flag.txt" ]] #If the file is not created by case 4 since an exit or break would not work.
			do

			echo "What would you like to do? Here are the options:"
	                echo -e "1.uptime\n2.free-h\n3.df -h /\n4.Exit\n"

	                read user_choice


	       	      { echo "$DIVIDER"
	        	Date_var=$(date "+%Y-%m-%d %H:%M:%S")
			echo "   SYSTEM AUDIT REPORT - $Date_var "
	        	echo  "$DIVIDER"


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
				4)
				   #3. Quit choice
				   touch flag.txt
				   echo -e "          	 USER: $user EXITED\n "


				   sleep 0.5;;
				*)
				   echo "Invalid input";;

			esac

			echo ""
	        	echo "$DIVIDER"
	        	echo -e "       Audit Successfully Completed.\n\n"
			 } | tee -a "$LOG_FILE"

		done

		if [[ -f "flag.txt" ]]; then ##Since I am "feeding" the metrics in a log check exit 0 would not work to terminate the whole while loop

			echo "Exiting..."
			rm flag.txt
			exit 0
		fi

	elif [[ $answer == "No" || $answer == "no" ]]; then

		echo "Exiting..."
		exit 0
	else
		echo " Wrong format try again"
	fi

	done


exit 0

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
mkdir -p "$HOME/linux-telemetry" >/dev/null 2>&1 # in case someone does not already have the directory ready to avoid variable LOG_FILE errors
LOG_FILE="$HOME/linux-telemetry/audit.log"

# ==========================================
# FUNCTIONS
# ==========================================

check_dependencies() {

	local program=$1 #storing the name into a variable and checking if the program is installed
	command -v $program > /dev/null 2>&1

	if [[ $? -ne 0 ]];then

		echo "Dependencies missing!!!"
		echo "Trying to install iproute2:"
		sudo apt install iproute2 -y >/dev/null 2>&1 #trying to install the program in the background

		if [[ $? -ne 0 ]];then

			echo "Could not install."
			echo "Try updating and then installing iproute2"
			return 1 ##if the program does not exist and could not be installed then an error code is returned to check
		fi
	else
		return 0
	fi
}






# using a divider to clarify output
DIVIDER="---------------------------------------------------"

echo -e "Hello $user\n"


# ==========================================
# Starting while loop  with the menus
# ==========================================



while :
	do

	read -p "Would you like to learn your system metrics?(Yes/No) " answer

	if [[ $answer == "Yes" || $answer == "yes" ]];then

	        #### Logging the metrics into system_audit.log along with showing them to the screen for the user
		echo "SESSION STARTED: $session_date_var" | tee -a "$LOG_FILE" #Session date that states when the user started the script (future idea of background work and automation)

		while [[ ! -f "flag.txt" ]] #If the file is not created by case 4 since an exit or break would not work.
			do

			echo "What would you like to do? Here are the options:"
	                echo -e "1.CPU Info\n2.Ram Info\n3.Disk Info\n4.Network Info\n5.Exit\n"

	                read user_choice


	       	      { echo "$DIVIDER"
	        	Date_var=$(date "+%Y-%m-%d %H:%M:%S")
			echo "   SYSTEM AUDIT REPORT - $Date_var "
	        	echo  "$DIVIDER"
			sleep 0.5
} | tee -a "$LOG_FILE"

			case $user_choice in

				1)
				   # 1. CPU LOAD
	        		   # 'uptime' show the Load Average (1, 5 and 15 minutes ago)
			           echo "[*] CPU LOAD AVERAGE & UPTIME:" | tee -a "$LOG_FILE"
				   uptime | tee -a "$LOG_FILE" ;;
				2)
				   # 2. RAM Check
	        		   # 'free -h' to convert to readable form (MB/GB)
	        		   echo "[*] MEMORY USAGE (RAM):" | tee -a "$LOG_FILE"
	        		   free -h | tee -a "$LOG_FILE"
	        		   echo ""

				   sleep 0.5;;
				3)
				   # 3. Disk Check
				   # 'df' = free disk and 'du' = disk usage
				   # '-h' = human readable form  (MG/GB)
			           # '/' = root partition (Root) and '.' = working directory

                                   read -p "Would you like to check about root partition or current directory?(1/2): " disk_space
                                   case $disk_space in
                                        1)

					   read -p "Would you like to learn about disk usage or free disc space?(du/df): " command
					{  echo ""

					   if [[ $command == "df" ]];then
						df -h /
					   elif [[ $command == "du" ]];then
						du -h / --max-depth=1 2>/dev/null
					   else
						echo "Invalid answer!"
					   fi

					   echo -e "\n[*] DISK SPACE ALLOCATION (Root /):"
	                                   echo ""
} | tee -a "$LOG_FILE"

					   sleep 0.5 ;;

					2)

					   read -p "Would you like to learn about disk usage or free disc space?(du/df): " command
                                        {  echo ""

                                           if [[ $command == "df" ]];then
                                                df -h .
                                           elif [[ $command == "du" ]];then
                                                du -h . --max-depth=1 2>/dev/null
                                           else
                                                echo "Invalid answer!"
                                           fi

					   echo -e "\n[*] DISK SPACE ALLOCATION (Working Direcroty .):"
	                                   echo ""
} | tee -a "$LOG_FILE"

                                           sleep 0.5;;
				   esac

				   sleep 0.5;;
				4)

				   #Starting with a network summary and then moving onto more detailed metrics
				 { echo "--------Network-Summary--------"
				   check_dependencies "ss"
				   if [[ $? -eq 0 ]];then
					   ss -s
				   fi
				   echo -e "--------End-Of-Summary--------\n"

} | tee -a "$LOG_FILE"

				   #4.Information about user's Ip and network basics
				   echo "Would you like to learn about your Network Interface Configuration or Socket Statistics?(1/2)"
				   read -p "" Network_choice
			  	 { case $Network_choice in

					1)

					   #Using command ip a to show user ip, status and MAC info
					   check_dependencies "ip"
					   if [[ $? -eq 0 ]];then
					   	ip a
					   fi ;;

					2)

					   #Using command -tulpn flag to show active service ports and listening processes
					   check_dependencies "ss"
					   if [[ $? -eq 0 ]];then
					   	ss -tulpn
					   fi ;;

					*)
					   echo -e "Invalid Input\n";;
  				   esac
} | tee -a "$LOG_FILE" ;;

			        5)
				   #5. Quit choice
				   touch flag.txt
				   echo -e "          	 USER: $user EXITED\n " | tee -a "$LOG_FILE" ;;

				*)
				   echo "Invalid input"  | tee -a "$LOG_FILE" ;;

			esac
			{
			echo ""
	        	echo "$DIVIDER"
	        	echo -e "       Audit Successfully Completed.\n\n"
}| tee -a "$LOG_FILE"

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

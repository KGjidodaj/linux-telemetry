#!/usr/bin/env bash

# ==================================================================
# System Specs & Security Script
# Author: Kristian Gjidodaj
# Description: It gathers metrics and logs according to user choice.
# ==================================================================



## Also adding a check if less command exists to use it or else use cat -n
if command -v less >/dev/null 2>&1; then
	page_cmd="less -SN"
else
	page_cmd="cat -n"
fi


## Separating docker containers to avoid errors in stripped down docker containers that would not support ANSI colour output!
if [[ -f /.dockerenv ]];then

	## Declaring all the ANSI colours as blank as to not be outputted in docker environmnets
	Red=""
	Green=""
	Yellow=""
	Cyan=""
	Reset=""
	White=""

        machine="Docker"

else

	# Declaring actual ANSI colours with \033 instead of \e to avoid errors where it is not recognized.

	Red='\033[1;91m' ## (1;91) for it to be bold high intensity red
	Green='\033[1;32m' ## (0;32) for it to be bold green
	Yellow='\033[1;33m' ## (1;33) for it to be bold yellow
	Cyan='\033[1;36m' ## (0;36) for it to be bold cyan
	Reset='\033[0m' ## This resets the colours
	White='\033[1;97m' ## (1;97) for it to be high intensity bold white

        machine="Non Docker"
fi


## Seperating os-releases so when using the package manager errors do not occur.
## grep -q -i to search in teh or-release file not caring with case sensitivity.
## Seperating update and install commands to be used in check_dependencies function

if grep -q -i "debian\|ubuntu\|mint" /etc/os-release 2>/dev/null; then

	OS="Deb"
        Package_man_update="apt update"
        Package_man_install="apt install iproute2"

elif grep -q -i "arch\|manjaro" /etc/os-release 2>/dev/null; then

	OS="Arch"
        Package_man_update="pacman -Sy"
        Package_man_install="pacman -S iproute2 --noconfirm"

elif grep -q -i "alpine" /etc/os-release 2>/dev/null; then

	OS="Alpine"
        Package_man_update="apk update"
        Package_man_install="apk add iproute2"

elif grep -q -i "fedora\|rhel\|centos" /etc/os-release 2>/dev/null; then

	OS="Rhel"
        Package_man_update="dnf makecache"
	Package_man_install="dnf install iproute2 -y"

elif grep -q -i "sles\|suse" /etc/os-release 2>/dev/null; then

	OS="Suse"
	Package_man_update="zypper refresh"
	Package_man_install=" zypper install -y iproute2"

else

	OS="unknown"
        Package_man_update="unknown"
fi






clear # Keeping the terminal clean
# using pwd as it is the working directory of the user when they first run the script
location=$(find "$PWD" -name "system_audit.sh") #reached some scenarios with directory errors so saving location

#Modifying .bashrc file when it is run for the first time so telemetry command is active and can be run with the command telemetry
#Since it is being run for the first time also asking user for how big they want the audit.log size

if ! grep -q "alias telemetry=" "$HOME"/.bashrc  ;then

	# in case of a docker container alias telemetry will never be set, so to avoid re writing lines again and again a check is done
	if ! grep -q "export log_lines=" "$HOME"/.bashrc ;then

	# In a while loop to "trap" the user if they do not input a number!
	while :
		do

	        echo -e "${White}How many lines would you want the log file to be? (Input a number)${Reset}"
		        read -r log_lines

			#checking if the output is a number so an error with tail does not happen
			if [[ $log_lines =~ ^[0-9]+$ ]];then

				echo "export log_lines=\"$log_lines\"" >> "$HOME"/.bashrc
				break
			else

				echo "Input a valid integer"
			fi
		done

	fi


        if [[ $machine != "Docker" ]];then
                #No need to create alias telemetry in a docker container

                echo -e "alias telemetry='$location'" >> "$HOME"/.bashrc
                echo -e "${White}Restarting session${Reset}"
                echo -e "${White}Script can be run via the (telemetry) command.${Reset}"

                sleep 1
                exec bash # Using exec bash because without it in the same terminal the telemetry command will not work as a restart is needed
        fi
fi

### Variables (frequently used) together for easier comprehension and readability :

# 1) Revolving the User :

## Date_var - session_date_var : Updates with every loop to show the time in the correct format ISO 8601.
## answer : Checks like user_choice each answer for case statements
## user_choice  : Checks user choice for each case statement.
## user : checking who the user is when running the script

# 2) Revolving how the script works :

## LOG_FILE : a specific directory for the audit.log file to be created and updated
## command : used to check for the command the user wants in case 1 telemetrics
## sudo_cmd " used to avoid errors with docker containers that usually do not have sudo
## machine : again like sudo_cmd to distinguish docker containers and avoid errors
## service_name : for the journalctl and systemclt commands in the active remediation case

### End of variables.


session_date_var=$(date "+%Y-%m-%d %H:%M:%S")
user=$(whoami)

### checking if linux-telemetry directory exists in case user copied file (e.g. to a docker container) without the directory
directory_location=$(find "$HOME" -name linux-telemetry)


if [[ "$directory_location" == "" ]];then #had some problems so made it with quotes
        mkdir -p "$HOME/linux-telemetry" >/dev/null 2>&1 # in case someone does not already have the directory ready to avoid variable LOG_FILE errors
fi


LOG_FILE="$HOME/linux-telemetry/audit.log"

### Checking for sudo dependecies according to user :

if command -v "sudo" > /dev/null 2>&1 ;then
        sudo_cmd="sudo"
else
        sudo_cmd=""

fi





# ==========================================
# FUNCTIONS
# ==========================================

check_dependencies() {

        local program=$1 #storing the name into a variable and checking if the program is installed
        command -v "$program" > /dev/null 2>&1

        if  ! command -v "$program" > /dev/null 2>&1 ;then

                # Trying older netstat and if config in case it works then saving them in dep_command variable
                if [[ $program == "ss" ]];then
                        if  command -v netstat > /dev/null 2>&1 ;then
                                dep_command="netstat -tulpan"
                                return 0
                        fi
                else
                        if  command -v ifconfig >/dev/null 2>&1 ;then
                                dep_command="ifconfig -a"
                                return 0
                        fi
                fi

                echo -e "${Yellow}Dependencies missing!!${Reset}"
                echo -e "${White}Trying to install iproute2:${Reset}"
                sleep 2
                clear

                echo -e "${Yellow}WARNING: Might Take Some Minutes!${Reset}"
		# According to the package manager and os release

                $sudo_cmd "$Package_man_update"  >/dev/null 2>&1 #updating in case machine has not been updated
                $sudo_cmd "$Package_man_install" >/dev/null 2>&1 #trying to install the program in the background


                if [[ $? -ne 0 ]];then

                        echo -e "${Red}Could not install.${Reset}"
                        echo -e "${White}Try updating and then installing iproute2${Reset}"
                        return 1 ##if the program does not exist and could not be installed then an error code is returned to check
                fi
        else
                if [[ $program == "ip" ]];then
                        dep_command="ip a"
                else
                        dep_command="ss -tulpan"
                fi

                return 0
        fi
}










# using a divider to clarify output
DIVIDER="---------------------------------------------------"

echo -e "Hello $user\n" >> "$LOG_FILE"



## Checking audit.log file for too many lines and limiting the size of the file to avoid memory problems

if [[ -f "$LOG_FILE" ]];then
        tail -n "$log_lines" "$LOG_FILE" > "audit.tmp"
        $sudo_cmd mv "audit.tmp" "$LOG_FILE"
fi



# ==========================================
# Starting while loop  with the menus
# ==========================================



while :
        do

        echo -e "${White}What would you like to do${Reset}\n"
        echo -e "${Cyan}1.system-telemetrics (check info about cpu/ram/disk/network)\n2.security-forensics (check possible security breach)\n3.active remediation (check what is causing the system to crash and resolve it)\n4.Exit${Reset}\n"
        read -r answer
        clear

        { echo "$DIVIDER"
        echo -e "[SESSION STARTED: $session_date_var]"  #Session date that states when the user started the script
	echo "[USER: $user] [OS: $OS] [MACHINE: $machine] "
        echo "$DIVIDER"
} | tee -a "$LOG_FILE"

        case $answer in

                1)
                        #### Logging the metrics into system_audit.log along with showing them to the screen for the user

                        while :
                                do

                                echo -e "${White}What would you like to do? Here are the options:${Reset}"
                                echo -e "${Cyan}1.CPU Info\n2.Ram Info\n3.Disk Info\n4.Network Info\n5.Exit${Reset}\n"

                                read -r user_choice1


                              { echo "$DIVIDER"
                                Date_var=$(date "+%Y-%m-%d %H:%M:%S")
                                echo "   SYSTEM AUDIT REPORT - $Date_var "
                                echo  "$DIVIDER"
                                sleep 0.5
        } | tee -a "$LOG_FILE"

                                case $user_choice1 in

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

					   echo -e "${Cyan}Would you like to check about root partition or current directory?(1/2):${Reset} "
					   read -r disk_space
                                           case $disk_space in
                                                1)

                                                   echo -e "${Cyan}Would you like to learn about disk usage or free disc space?(du/df):${Reset} "
						   read -r command
                                                   echo ""

                                                   if [[ $command == "df" ]];then
                                                        df -h / | tee -a "$LOG_FILE"
                                                   elif [[ $command == "du" ]];then
                                                        du -h / --max-depth=1 2>/dev/null | tee -a "$LOG_FILE"
                                                   else
                                                        echo -e "${Red}Invalid answer!${Reset}"
                                                   fi
						{
                                                   echo -e "\n[*] DISK SPACE ALLOCATION (Root /):"
                                                   echo ""
		} | tee -a "$LOG_FILE"

                                                   sleep 0.5 ;;

                                                2)

                                                   echo -e "${Cyan}Would you like to learn about disk usage or free disc space?(du/df):${Reset} "
						   read -r command
                                                   echo "" | tee -a "$LOG_FILE"

                                                   if [[ $command == "df" ]];then
                                                        df -h . | tee -a "$LOG_FILE"
                                                   elif [[ $command == "du" ]];then
                                                        du -h . --max-depth=1 2>/dev/null | tee -a "$LOG_FILE"
                                                   else
                                                        echo -e "${Red}Invalid answer!${Reset}"
                                                   fi

                                                {  echo -e "\n[*] DISK SPACE ALLOCATION (Directory .):"
                                                   echo ""
		 } | tee -a "$LOG_FILE"


                                                   sleep 0.5 ;;
                                           esac

                                           sleep 0.5 ;;

                                        4)

                                           #Starting with a network summary and then moving onto more detailed metrics
                                           echo "--------Network-Summary--------" | tee -a "$LOG_FILE"

                                           if command -v ss >/dev/null 2>&1 ;then
                                                   ss -s | tee -a "$LOG_FILE"
                                           else
                                                   echo -e "${Yellow}ss command does not exist: stopping summary${Reset}"
                                           fi

					   # Using ping command if not in docker (as to avoid depndency errors) to check network "health"
					   if [[ $machine != "Docker" ]] ;then

						sleep 1
						echo "$DIVIDER" | tee -a "$LOG_FILE"
						echo -e "${Cyan}Would you like to check your internet or a custom IP? (1/2):${Reset} \n"
						read -r answer1

						case $answer1 in

							1)
							   # using -c 3 flag for only three checks to be done and using 8.8.8.8 as a reliable server
							   if ping -c 3 8.8.8.8 >/dev/null 2>&1 ;then
								echo -e "${Green}You have an active internet connection${Reset}"
								echo "Internet Connection Is Active." >> "$LOG_FILE"
							   else
								echo "Internet Connection Is Down" >> "$LOG_FILE"
	   						   	echo -e "${Red}Internet is Down${Reset}"
							   fi ;;

							2)
							   #asking the user for the IP adress to check
							   echo -e "${White}Input the IP address you would like to check:${Reset} "
							   read -r IP_Add

							   if ping -c 3 "$IP_Add" >/dev/null 2>&1 ;then
								echo "Machine with IP: $IP_Add is up" >> "$LOG_FILE"
								echo  -e "${Green}The machine you are trying to reach is up${Reset}"
							   else
								echo "Machine with IP: $IP_Add is down" >> "$LOG_FILE"
								echo -e "${Red}The machine you are trying to reach is down${Reset}"
							   fi ;;
							esac
					else
						echo "Bypassing for docker..."
					fi



                                           echo -e "\n--------End-Of-Summary--------\n" | tee -a "$LOG_FILE"


                                           #4.Information about user's Ip and network basics
                                           echo -e "${Cyan}Would you like to learn about your Network Interface Configuration or Socket Statistics?(1/2)\nPress Enter to skip${Reset}"
                                           read -r -p "" Network_choice
                                           case $Network_choice in

                                                1)

                                                   #Using command ip a to show user ip, status and MAC info
                                                   if check_dependencies "ip" ;then
                                                        $dep_command | tee -a "$LOG_FILE"
                                                   fi ;;

                                                2)

                                                   #Using command -tulpn flag to show active service ports and listening processes
                                                   if check_dependencies "ss" ;then
                                                        $dep_command | tee -a "$LOG_FILE"
                                                   fi ;;

                                                *)

                                                   echo -e "${Yellow}Invalid Input-Skipping\n${Reset}"
						   #Invalid input check to not have audit sucssessfully complte
						   invalid_input=1 ;;
                                           esac ;;

                                        5)

                                           #5. Quit choice
					   echo -e " ${Green} Exiting...${Reset}"
                                           echo -e "             USER: $user EXITED\n " | tee -a "$LOG_FILE"
					   clear # clearing screen output
                                           break ;;

                                        *)

					   echo "" | tee -a "$LOG_FILE"
                                           echo -e "${Red}Invalid input${Reset}" ;;

                                esac
				{
                                echo ""
                                echo "$DIVIDER"
	} | tee -a "$LOG_FILE"
				if [[ $invalid_input != 1 ]];then
	                                echo -e "       ${Green}Audit Successfully Completed.${Reset}\n\n"
					echo -e "		Audit Successfully Completed \n " >> "$LOG_FILE"
				fi

                        done ;;

                2)
                        while :
                                do

                                echo -e "${White}What would you like to check?${Reset}"
                                echo -e "${Cyan}1.Who is connected\n2.The command history\n3.Check of potential ssh attempts\n4.Files changed\n5.Kernel Logs\n6.socket statistics\n7.Exit${Reset}\n"
                                read -r user_choice2

                                case $user_choice2 in

                                        1)

                                                # looking who is connected  with the w command
                                                { echo -e "\n$DIVIDER                       [Active Users]:                       $DIVIDER\n"

                                                if command -v w >/dev/null 2>&1 ;then
                                                        w
                                                else
                                                        echo "Cannot check active users"
                                                fi
                } | tee -a "$LOG_FILE" ;;

                                        2)

                                                # checking .bash_history for any suspicious activity
                                                { echo -e "\n$DIVIDER                       [History]:                       $DIVIDER\n"

                                                echo -e " Here is the bash_history \n"
		} | tee -a "$LOG_FILE"
                                                tail -n 120 "$HOME"/.bash_history 2> /dev/null | $page_cmd
						cat "$HOME"/.bash_history 2> /dev/null |tail -n 120 >> "$LOG_FILE" ;;

                                        3)

                                                echo -e "\n$DIVIDER                       [Log Attempts]:                       $DIVIDER\n" | tee -a "$LOG_FILE"

                                                if command -v journalctl>/dev/null 2>&1 ;then

							# --since in journalctl needs a search date so it is stored in the variable $search_date
                                                        echo "Add date from to search from in date format (e.g. 2026-03-30 21:00:00) or string format (e.g. 5 hours ago )"
                                                        read -r search_date

                                                        $sudo_cmd journalctl --since "$search_date" | $page_cmd
							$sudo_cmd journalctl --since "$search_date" >> "$LOG_FILE"

                                                elif [[ -f /var/log/auth.log ]];then

                                                        $sudo_cmd grep "Accepted" /var/log/auth.log >> "$LOG_FILE"
							$sudo_cmd grep "Accepted" /var/log/auth.log | tee -a "$LOG_FILE"
                                                else
                                                        echo "Could not check logs" | tee -a "$LOG_FILE"
                                                fi ;;
                                        4)

                                                { echo -e "\n$DIVIDER                       [Tampered Files]:                       $DIVIDER\n"
                                                #using -not -path to avoid some paths that could overwhelm the user and fill up the screen
                                                $sudo_cmd find / -mmin -60 -type f -not -path "/proc/*" -not -path "/sys/*" -not -path "/run/*" -not -path "/dev/*" -not -path "/var/lib/docker/*" 2>/dev/null
                } | tee -a "$LOG_FILE" ;;


                                        5)

                                                echo -e "\n$DIVIDER                       [Kernel Logs]:                       $DIVIDER\n" | tee -a "$LOG_FILE"
						# enountered errors in dockers so adding an else statement in case an error occurs and -T to convert in human readable time
						if $sudo_cmd dmesg -T >/dev/null 2>&1 ;then

                                                        $sudo_cmd dmesg -T | tail -n 70 | $page_cmd | tee -a "$LOG_FILE"
						else
	                                              	echo "Error" >> "$LOG_FILE"
							# many times in docker if the user has not run the docker in privilaged mode a perimission error might occur with dmesg
							echo -e "${Red}Error: If in docker try running in privileged mode first${Reset}"
	                                        fi ;;


                                        6)

                                                check_dependencies "ss"

                                                { echo "$DIVIDER$DIVIDER"
                                                echo "Checking socket statistics..."
                                                echo "$DIVIDER$DIVIDER"

                                                ss -tulpan
                } | tee -a "$LOG_FILE" ;;

                                        7)

                                                echo "Exiting..." >>  "$LOG_FILE"
						echo -e "${Green} Exiting... ${Reset}"
                                                clear # cleaning the screen
						break ;;
                                        *)

                                                echo -e "${Yellow}Invalid Input${Reset}" ;;

                                esac
                                      { echo "                                    [END OF ACTIVITY]                                              "
                                        echo -e "$DIVIDER$DIVIDER\n"
	 } | tee -a "$LOG_FILE"
                                done ;;

                3)
                        while :
                                do
                                echo -e "${Cyan}Would you like to start active remediation? (yes/no)${Reset}\n"
                                read -r answer3

                                if [[ "$answer3" == "Yes" || "$answer3" == "yes" ]];then

                                       { echo "$DIVIDER$DIVIDER"
                                        echo "Here is a list of processes that could be the cause of system slowdown"
                                        echo "$DIVIDER$DIVIDER"

                                        # -b in batch mode, -n 1 for there to only be one iteration and head to limit the output
                                        top -b -n 1 | head -n 25
        } | tee -a "$LOG_FILE"

                                        echo -e "${White}What PID  would you like to terminate? (To skip press enter):${Reset} "
                                        read -r PID_tokill
                                        echo "                    [PID HUNT]:                 " | tee -a "$LOG_FILE"

                                        if  [[ $PID_tokill == "" ]];then
                                                echo "Skipping Hunt Of PID ..." | tee -a "$LOG_FILE"
                                        else


						echo -e "${Yellow} Warning: Would you like to kill the process now?${Reset}"
						echo -e " ${Yellow}If you do kill it you will not be able to continue (e.g logs)${Reset}\n ${White}I would suggest checking the logs and then asking for active remidition and then killing the process!${Reset}"
						echo -e "${White}So would you like to kill the PID now? (Yes/No) :${Reset}"
						read -r answer2
						# Checking just to avoid errors if I kill the process and the user still want to check logs of a PID that does not exist
						if [[ $answer2 == "Yes" || $answer2 == "yes" ]];then

							#just hiding any output from the user especially if error occurred
	                                                if $sudo_cmd kill "$PID_tokill" > /dev/null 2>&1 ;then

	                                                                if $sudo_cmd kill -9 "$PID_tokill" > /dev/null 2>&1 ;then
	                                                                        echo "Could not kill process" | tee -a "$LOG_FILE"
	                                                                else
	                                                                        echo "Killed process successesfully" | tee -a "$LOG_FILE"
	                                                                fi
	                                                else
	                                                        echo "Killed process successesfully" | tee -a "$LOG_FILE"
	                                                fi
						else

	                                                if [[ $machine == "Docker" ]];then
								# avoiding systemd errors in docker containers
	                                                        echo "stopping here for dockers" | tee -a "$LOG_FILE"

	                                                else

								# Since I have acoided systemd dependecies and stripped systems with the if for docker containers I can continue with systemctl and journalctl commands.
	                                                        echo -e "${Cyan}Would you like to restart the process?(yes/no): ${Reset}"
								read -r restart
	                                                        if [[ $restart == "y" || $restart == "yes" ]];then

	                                                                echo ""
	                                                                echo "(You can find <service_name> by running systemctl status <PID>)" #instructing the user how to find the service name
	                                                                read -r -p "Add <service_name> you want to restart:  " service_name
	                                                                echo "                  [RESTARTING SERVICE]:            " | tee -a "$LOG_FILE"

									# Doing a restart as many times even a restart is enough to fix services.
	                                                                $sudo_cmd systemctl restart "$service_name" > /dev/null 2>&1
	                                                        fi

	                                                        echo -e "${White}(You can find <service_name> by running systemctl status PID)${Reset}"
	                                                        echo -e "${Cyan}Would you like to check the logs of the processes? (Yes/No) ${Reset}\n"
	                                                        read -r user_choice3

	                                                        if [[ $user_choice3 == "Yes" || $user_choice3 == "yes" ]];then

	                                                                echo -e "${White}Insert service name: ${Reset}"
									read -r service_name
	                                                                # -u and -n to provide logs about a specific service and --no-pager to outup directly to the terminal and avoid errors with "$LOG_FILE"
	                                                                echo "                   [SERVICE LOGS]:                 " | tee -a "$LOG_FILE"

	                                                                $sudo_cmd journalctl -u "$service_name" -n 50 --no-pager >> "$LOG_FILE"
									$sudo_cmd journalctl -u "$service_name" -n 70 --no-pager | $page_cmd
	                                                        fi
	                                                fi
						fi
                                        fi

                                elif [[ $answer3 == "No" || $answer3 == "no" ]];then

                                         echo "$DIVIDER" | tee -a "$LOG_FILE"
                                         echo "Exiting..." >> "$LOG_FILE"
					 echo -e "${Green}Exiting...${Reset}"

                                         break
                                 else

                                        echo "$DIVIDER" >> "$LOG_FILE"
                                        echo -e "${Red}Invalid Input${Reset} "
                                fi

                        done ;;

                4)

			echo "$DIVIDER"
                        echo -e " $user  ${Green} Exiting...${Reset} \n"
                      { echo "$DIVIDER"
                        echo " $user   Exiting..."
	} >>  "$LOG_FILE"
                        exit 0 ;;

                *)
                        echo -e "${Red}Invalid Input${Reset} " ;;

                esac
        done

exit 0


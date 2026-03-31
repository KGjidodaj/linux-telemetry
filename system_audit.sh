#!/usr/bin/env bash

# ==================================================================
# System Specs & Security Script
# Author: Kristian Gjidodaj
# Description: It gathers metrics and logs according to user choice.
# ==================================================================


## Seperating docker containers
if [[ -f /.dockerenv ]];then
        machine="Docker"
else
        machine="NDocker"
fi


## Seperating os-releases if they are not compatible.

if grep -q "ID_LIKE=debian" /etc/os-release ;then
        OS="Deb"
else
        echo -e "Sorry but only Debian compatability exists (at least for now).\nExiting"
        exit 0
fi




clear # Keeping the terminal clean
location=$(find $HOME -name "system_audit.sh") #reached some scenarios with directory errors so saving location

#Modifying .bashrc file when it is run for the first time so telemetry command is active and can be run with the command telemetry
#Since it is being run for the first time also asking user for how big they want the audit.log size

if ! grep -q "alias telemetry=" ~/.bashrc  ;then 

	echo -e "How many lines would you want the log file to be?"
	read log_lines
	echo "export log_lines="$log_lines"" >> ~/.bashrc

        echo -e "alias telemetry='$location'" >> ~/.bashrc
        echo "Restarting session"
        echo "Script can be run via the (telemetry) command."
        sleep 1
        first_time=true
        exec bash
fi

# Variables:

## Date_var - session_date_var : Updates with every loop to show the time in the correct format ISO 8601.
## answer : Checks user answer in the first read.
## user_choice : Checks user choice for the case statement.
## user : checking who the user is when running the script
## LOG_FILE : a specific directory for the audit.log file to be created and updated

session_date_var=$(date "+%Y-%m-%d %H:%M:%S")
user=$(whoami)

### checking if linux-telemetry directory exists in case user copied file (e.g. to a docker container) without the directory
directory_location=$(find $HOME -name linux-telemetry)

if [[ directory_location="" ]];then
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
        command -v $program > /dev/null 2>&1

        if [[ $? -ne 0 ]];then

                echo "Dependencies missing!!!"
                echo "Trying to install iproute2:"
                echo "Might update first and take some time"
                clear

                $sudo_cmd apt update >/dev/null 2>&1 #updating in case machine has not been updated
                $sudo_cmd apt install iproute2 -y >/dev/null 2>&1 #trying to install the program in the background

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



## Checking audit.log file for too many lines and limiting the size of the file to avoid memory problems

if [[ -f "$LOG_FILE" ]];then
	tail -n $log_lines "$LOG_FILE" > "audit.tmp"
	$sudo_cmd mv "audit.tmp" "$LOG_FILE"
fi



# ==========================================
# Starting while loop  with the menus
# ==========================================



while :
        do

        echo "What would you like to do"
        echo -e "1.system-telemetrics (check info about cpu/ram/disk/network)\n2.security-forensics (check possible security breach)\n3.active remediation (check what is causing the system to crash and resolve it)\n4.Exit\n"
        read answer
        clear

        { echo "$DIVIDER"
        echo -e "[SESSION STARTED: $session_date_var]"  #Session date that states when the user started the script
        echo "$DIVIDER"
} | tee -a "$LOG_FILE"

        case $answer in

                1)
                        #### Logging the metrics into system_audit.log along with showing them to the screen for the user

                        while :
                                do

                                echo "What would you like to do? Here are the options:"
                                echo -e "1.CPU Info\n2.Ram Info\n3.Disk Info\n4.Network Info\n5.Exit\n"

                                read user_choice1


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
                                           check_dependencies "ss,"
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
                                           echo -e "             USER: $user EXITED\n " | tee -a "$LOG_FILE" 
                                           break ;;

                                        *)
                                           echo "Invalid input"  | tee -a "$LOG_FILE" ;;

                                esac
                                {
                                echo ""
                                echo "$DIVIDER"
                                echo -e "       Audit Successfully Completed.\n\n"
        } | tee -a "$LOG_FILE"

                        done ;;

                2)
                        while :
                                do

                                echo "What would you like to check?"
                                echo -e "1.Who is connected\n2.The command history\n3.Check of potential ssh attempts\n4.Files changed\n5.Kernel Logs\n6.socket statistics\n7.Exit\n"
                                read user_choice2

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
                                                cat ~/.bash_history 2> /dev/null | tail -n 100
                } | tee -a "$LOG_FILE" ;;

                                        3)

                                                echo -e "\n$DIVIDER                       [Log Attempts]:                       $DIVIDER\n" | tee -a "$LOG_FILE"

                                                if command -v journalctl>/dev/null 2>&1 ;then

                                                        echo "Add date from to search from in date format (e.g. 2026-03-30 21:00:00) or string format (e.g. 5 hours ago )"
                                                        read search_date
                                                        $sudo_cmd journalctl --since "$search_date" | tee -a "$LOG_FILE"

                                                elif [[ -f /var/log/auth.log ]];then

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

                                                { echo -e "$DIVIDER\n                       [Kernel Logs]:                       $DIVIDER\n"
                                                if dmesg -T | tail -n 50 >/dev/null 2>&1;then
                                                        $sudo_cmd dmesg -T | tail -n 50
                                                else
                                                        echo "Error: If in docker try running in privilaged mode"
                                                fi
                } | tee -a "$LOG_FILE" ;;


                                        6)

                                                check_dependencies "ss"

                                                { echo "$DIVIDER$DIVIDER"
                                                echo "Checking socket statistics..."
                                                echo "$DIVIDER$DIVIDER"

                                                ss -tulpan
                } | tee -a "$LOG_FILE" ;;

                                        7)

                                                echo "Exiting..." | tee -a "$LOG_FILE"
                                                break ;;
                                        *)

                                                echo "Invalid Input" ;;

                                esac
                                        echo "                                    [END OF ACTIVITY]                                              "
                                        echo -e "$DIVIDER$DIVIDER\n"
                                done ;;

                3)
                       { while :
                                do
                                echo -e "Would you like to check option 3? (yes/no)\n"
                                read answer3

                                if [[ "$answer3" == "Yes" || "$answer3" == "yes" ]];then

                                        echo "$DIVIDER$DIVIDER"
                                        echo "Here is a list of processes that could be the cause of system slowdown"
                                        echo "$DIVIDER$DIVIDER"

                                        # -b in batch mode, -n 1 for there to only be one iteration and head to limit the output
                                        top -b -n 1 | head -n 25

                                        echo "What PID  would you like to terminate? (To skip press enter): "
                                        read PID_tokill

                                        if  [[ $PID_tokill == "" ]];then
                                                echo "Skipping..."
                                        else
                                                $sudo_cmd kill "$PID_tokill" > /dev/null 2>&1
                                                if [[ $? -ne 0 ]];then

                                                        $sudo_cmd kill -9 "$PID_tokill" > /dev/null 2>&1

                                                                if [[ $? -ne 0 ]];then
                                                                        echo "Could not kill process"
                                                                else
                                                                        echo "Killed process successesfully"
                                                                fi
                                                else
                                                        echo "Killed process successesfully"
                                                fi

                                                if [[ $machine == "Docker" ]];then
                                                        echo "stopping here for dockers"
                                                else
                                                        read -p "Would you like to restart the process?(yes/no): " restart
                                                        if [[ $restart == "y" || $restart == "yes" ]];then

                                                                echo ""
                                                                echo "(You can find <service_name> by running systemctl status PID)"
                                                                read -p "Add <service_name> you want to restart:  " service_name
                                                                $sudo_cmd systemctl restart $service_name
                                                        fi

                                                        echo "(You can find <service_name> by running systemctl status PID)"
                                                        echo -e "Would you like to check the logs of the processes? Input <service_name>: \n"
                                                        read service_name

                                                        # -u and -n to provide logs about a specific service and --no-pager to outup directly to the terminal
                                                        $sudo_cmd journalctl -u $service_name -n 50 --no-pager
                                                fi
                                        fi

                                elif [[ $answer3 == "No" || $answer3 == "no" ]];then
                                         echo "$DIVIDER"
                                         echo "Exiting..."


                                         break
                                 else

                                        echo "$DIVIDER"
                                        echo "Invalid Input "
                                fi

                        done
	} | tee -a "$LOG_FILE" ;;

                4)

                        echo "$DIVIDER"
                        echo "Exiting..."
                        exit 0 ;;

                *)
                        echo "Invalid Input " ;;

                esac
        done



exit 0

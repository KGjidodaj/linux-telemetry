#Mock Data Generation Pipeline

##Overview
This project is a simple built for my HomeLab for me to advance in my scripting abilities.
It generates mock user accounts (usernames and passwords) to simulate real-world data generation for testing environments.

##Architecture
The pipeline consists of three components:
1. `username_generator.py`: A python script that creates a random string as a mock username.
2. `password_generator.py`: A python script that creates a secure random mock password.
3. `account_creation.sh`: A Bash script that calls the previous 2 scripts in a loop and outputs a combination of mock accounts with usernames and passwords.

##Why this approach?
I tried to experiment with my own version of secure random password generators and had an idea!
"Why don't I include a Bash script into this project with another python script to create a mock data generation pipeline?"
I then tweaked the password generator and coded a username generator alongside a bash script (that combines them in a loop).
Thus, this project was created

##Usage
You are free to change the ammount of accounts created and  
Make sure all files have executable permissions:
```bash
chmod +x account_builder.sh username_generator.py password_generator.py

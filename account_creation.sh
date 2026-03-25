#!/usr/bin/env bash

read -p "How many accounts do you want to create?" number
echo "Generating..."

for ((i=1; i<=number; i++))
do
	echo "Account number: $i"
	./username_generator.py
	./password_generator.py
	echo "----------------------------" ##Divider 
done >> "account_generator.log"

echo "Done."

#!/usr/bin/env python3
# as r just to help with writing
import random as r

#creating the function that generates the code
def gen_password(length):
    ##specifying pool of characters to choose from
    pool = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    ##setting the variable equal to a string to avoid future errors
    password = ""

    for i in range(length): #the loop that appends the random characters to the password
        random_parameter = r.randint(0,1000)
        a = r.randint(0,9)
        b= r.choice(pool)
        ###creating a randomizer to pick between adding a character or a integer
        if random_parameter <= 500:
            password = str(a) + password
        else:
            password = b+ password

    return password ## returning it to output the finalized password

while True:

    print("Do you want to create a password (Yes/No)")
    answer = input()

    if answer == "Yes":

        print("How many characters should your password be?")
        print("Please add an integer else there will be an error ")
        length = int(input())
        print(f"Password: {gen_password(length)}\n")

    elif answer == "No":

        print("Goodbye then...exiting.")
        break

    else:
        print("WARNING: Try again answering with the correct format")


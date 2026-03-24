#!/usr/bin/env python3
# as r just to help with writing
import random as r

def username_generator(length):
    pool = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    username = "" #reset of the username
    for i in range(length): #to loop and append a character each time to the string
        character = r.choice(pool)
        username = username + character
    return username

def thank_you(length):
    ##the pool to choose from with r.choice(pool) below
    pool = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ12345"
    count = 0 #count to see how many times it took 
    while True:

        username = "" #reset of the username
        for i in range(length): #to loop and append a character each time to the string
            character = r.choice(pool)
            username = username + character
        check = username_checker(username)
        if check == True:
            print(f"Here is the count for the times it took: {count}")
            return username #no need for else in a while true
        if check == False:
            count = count + 1

def username_checker(username):
    flag = True
    ##Fun check of the username for numbers in my version of .isalpha() for numbers
    for i in range(len(username)):
        if username[i].isdigit():
            print(f"Stopping process found number in username: {username[i]}\n Loop restarted ")
            flag = False #could be anything except True
            break

    if flag != False:
        print("Check Done no numbers in string")
        flag = True #changing the flag to true as no numbers where found
    return flag


#While True so the loop doesnt stop running (except if answer = "No")
while True:

    print ("Would you like to generate a username?(Yes/No)")
    answer = input()
    if answer == "Yes":

        print("How many characters would you like the password to be?")
        length = int(input()) 
        print("Would you like to test my version of .isalpha() for numbers?(Yes/No)")
        answer = input()
        if answer == "Yes":
            print(f"Username: {thank_you(length)}\n")
        else:
            print(f"Username: {username_generator(length)}\n")

    elif answer == "No":

        print("Goodbye Then...Exiting.")
        break

    else:

        print("Please input the correct format")

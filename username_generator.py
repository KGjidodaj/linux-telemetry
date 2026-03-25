#!/usr/bin/env python3

# as r just to help with writing
import random as r

def username_generator(length):
    pool = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    username = ""
    for i in range(length):
        character = r.choice(pool)
        username = username + character
    return username

length = 10 ###change length for a bigger or smaller username

print(username_generator(length))



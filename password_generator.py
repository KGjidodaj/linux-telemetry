#!/usr/bin/env python3

# as r just to help with writing
import random as r

def gen_password(length):
    pool = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$%^&*()_-+={[}]|:;<,>.?"
    password = ""

    for i in range(length):
        random_parameter = r.randint(0,1000)
        a = r.randint(0,9)
        b= r.choice(pool)
        if random_parameter <= 500:
            password = str(a) + password
        else:
            password = b+ password

    return password

length = 20 ## change length for a bigger or smaller password

print(gen_password(length))

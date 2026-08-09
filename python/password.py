# Simple password generator

import random
import string

lowercase = string.ascii_lowercase
uppercase = string.ascii_uppercase
numbers = string.digits
symbols = string.punctuation

def main():
    # Clear screen
    print("\033[2J\033[1;1H")

    print("Welcome to a password generator!\n")

    length = ask_user(12, "int", "How many characters long should the password be")
    while True:
        print("\n\nCharacters to include:")
        include_lc = ask_user(True, "bool", "Use lowercase letters?")
        include_uc = ask_user(True, "bool", "Use uppercase letters?")
        include_nu = ask_user(True, "bool", "Use numbers?          ")
        include_sy = ask_user(False, "bool", "Use symbols?          ")

        if not include_lc and not include_uc and not include_nu and not include_sy:
            print("You did not select any character types to include! Please try again.\n\n")
        else:
            break

    passwd = generate_passwd(include_lc, include_uc, include_nu, include_sy, length)
    
    print(f"\n\nPassword: {passwd}")


def ask_user(default, input_type, prompt):
    if input_type == "int":
        while True:
            user_choice = input(f"{prompt}? (Default: {default}) ")

            if user_choice == "":
                return default

            try:
                return int(user_choice)
            except KeyboardInterrupt:
                exit(0)
            except:
                print("Invalid input! Please try again.\n")
    elif input_type == "bool":
        while True:
            if default == True:
                user_choice = input(f"{prompt} [Y/n] ")
            else:
                user_choice = input(f"{prompt} [y/N] ")

            if user_choice == "":
                return default
            
            if user_choice[0].lower() == "y":
                return True
            elif user_choice[0].lower() == "n":
                return False
            else:
                print("Invalid input! Please try again.\n")

    else:
        print("Error: Wrong input type in function call.")
        exit(1)

def generate_passwd(lc, uc, nu, sy, len):
    chars = []

    if lc:
        chars.extend(lowercase)
    if uc:
        chars.extend(uppercase)
    if nu:
        chars.extend(numbers)
    if sy:
        chars.extend(symbols)
    
    return "".join(random.choices(chars, k=len))
    

main()
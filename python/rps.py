# Rock, Paper, Scisors game

from os import error
import random
import signal
import time

# Clear screen
print("\033[2J\033[1;1H")

print("Let's play Rock, Paper, Scisors!\n")
time.sleep(0.5)

options = ["rock", "paper", "scisors"]

while True:
    try:
        turns = int(input("How many rounds should we play?\n"))
        break
    except:
        print("Not a valid number, fool!")

turn = 1

wins = 0
ourWins = 0

while turn <= turns:
    ourChoice = random.choice(options)

    while True:
        choice = input(f"Round {turn} / {turns}\nScore: {wins} / {ourWins}\n\nYour choice: ").strip(" ").strip(".").lower()

        if choice in options:
            break
        else:
            print("Thats not an option, I'm afraid...")

    print(f"You chose: {choice}, I chose: {ourChoice}.")

    if choice == ourChoice:
        print("This round is a draw!")
        wins += 1
        ourWins += 1
    elif choice == "rock":
        if ourChoice == "paper":
            print("You lost this round!")
            ourWins += 1
        else:
            print("You won this round!")
            wins+= 1
    elif choice == "paper":
        if ourChoice == "rock":
            print("You won this round!")
            wins += 1
        else:
            print("You lost this round!")
            ourWins += 1
    elif choice == "scisors":
        if ourChoice == "rock":
            print("You lost this round!")
            ourWins += 1
        else:
            print("You won this round!")
            wins += 1
    
    turn += 1
    time.sleep(0.7)
    
    # Clear screen
    print("\033[2J\033[1;1H")

print(f"Final score:\nYou {wins}\nMe {ourWins}")

if wins == ourWins:
    print("We tied!")
elif wins > ourWins:
    print("You won!")
else:
    print("I won!!")
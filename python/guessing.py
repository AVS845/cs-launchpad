# Random number guessing game
import random

x = random.randrange(1, 10)

print("I have picked a number between 1 and 10. Try to guess it!\n")

guesses = 0


while (True):
    guesses += 1
    guess = input("Your guess: ")

    if(int(guess) == x):
        break
    print("Not quite.")
    if(int(guess) > x):
        print(f"My number is lower than {guess}.")
    else:
        print(f"My number is higher than {guess}.")

print(f"\nYou are right! My number was {x}.\nIt took you {guesses} guesses.")
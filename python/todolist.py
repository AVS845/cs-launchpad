# Simple to-do list

import time


choices = [1, 2, 3, 4]
tasks = []


def menu():
    # Clear screen
    print("\033[2J\033[1;1H")

    choice = input("TO-DO List:\n\n1. Add task\n2. Remove task\n3. Show tasks\n4. Exit\n\nWhat would you like to do?\n")

    try:
        selection = int(choice)
        if selection in choices:
            if selection == 1:
                add_task()
            elif selection == 2:
                remove_task()
            elif selection == 3:
                list_tasks()
            else:
                exit(0)
        else:
            print("Invalid selection.")
            time.sleep(0.6)
            menu()
    except:
        print("Invalid selection.")
        time.sleep(0.6)
        menu()

def add_task():
    # Clear screen
    print("\033[2J\033[1;1H")

    task = input("New task:\n")
    tasks.append(task)

    print(f"{task} succesfully added!")

    menu()

def remove_task():
    # Clear screen
    print("\033[2J\033[1;1H")

    i = 1
    for t in tasks:
        print(f"{i}. {t}")
        i += 1
    
    while True:
        taskToRemove = input("What task do you want to remove?\n")
    
        try:
            tasks.remove(tasks[int(taskToRemove)])
            print("Task succesfully removed!")

            break
        except:
            print("Invalid number entered. Please try again.\n")

    menu()

def list_tasks():
    # Clear screen
    print("\033[2J\033[1;1H")

    i = 1
    for t in tasks:
        print(f"{i}. {t}")
        i += 1
    
    input("Press enter to return to menu.")
    menu()

menu()

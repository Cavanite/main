import os
import subprocess
import ctypes
import sys


def is_admin():
    try:
        return ctypes.windll.shell32.IsUserAnAdmin()
    except:
        return False


def get_local_admins():
    output = subprocess.check_output("net localgroup administrators", shell=True)
    output = output.decode("utf-8")
    lines = output.split('\n')
    admins = []

    for line in lines:
        line = line.strip()
        if line.startswith("*") or line.startswith("The command completed successfully"):
            continue
        if line:
            admins.append(line)

    return admins


def remove_user_from_admins(username):
    if not is_admin():
        print("This script requires administrative privileges.")
        sys.exit(1)

    subprocess.call(['net', 'localgroup', 'administrators', username, '/delete'])
    print(f"The user '{username}' has been removed from the local administrators group.")


def main():
    current_user = os.getlogin()
    admins = get_local_admins()

    if current_user in admins:
        admins.remove(current_user)
        remove_user_from_admins(current_user)
    else:
        print(f"The user '{current_user}' is not part of the local administrators group.")

    print("Script execution complete.")


if __name__ == '__main__':
    main()

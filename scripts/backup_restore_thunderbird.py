import os
import shutil
import glob
from datetime import datetime
import zipfile
import configparser


def get_directory_size(path):
    total_size = 0
    for dirpath, dirnames, filenames in os.walk(path):
        for f in filenames:
            fp = os.path.join(dirpath, f)
            try:
                total_size += os.path.getsize(fp)
            except OSError as e:
                print(f"Warning: Could not access file {fp}. Error: {e}")
    return total_size


def get_active_profile():
    home = os.path.expanduser("~")
    thunderbird_dir = os.path.join(home, ".thunderbird")
    profiles_ini = os.path.join(thunderbird_dir, "profiles.ini")

    if not os.path.exists(profiles_ini):
        print(f"Error: profiles.ini file not found at {profiles_ini}")
        return None

    config = configparser.ConfigParser()
    config.read(profiles_ini)

    default_release_profile = None
    default_profile = None
    available_profiles = []

    for section in config.sections():
        if section.startswith("Profile"):
            name = config.get(section, "Name", fallback="Unknown")
            path = config.get(section, "Path", fallback=None)

            if path:
                full_path = os.path.join(thunderbird_dir, path)
                print(f"Analyzing profile: {name} at {full_path}")
                if os.path.exists(full_path):
                    size = get_directory_size(full_path)
                    available_profiles.append((name, path, size))
                    print(f"  Profile size: {size/1024/1024:.2f} MB")
                    if "default-release" in path:
                        default_release_profile = path
                    elif "default" in path:
                        default_profile = path
                else:
                    print(f"  Warning! Profile directory does not exist: {full_path}")

    available_profiles.sort(key=lambda x: x[2], reverse=True)

    if default_release_profile:
        print(f"'default-release' profile detected: {default_release_profile}")
        confirm = input("Do you want to use this profile? (y/n): ").lower()
        if confirm == "y":
            return default_release_profile

    if default_profile:
        print(f"'default' profile detected: {default_profile}")
        confirm = input("Do you want to use this profile? (y/n): ").lower()
        if confirm == "y":
            return default_profile

    print("Available profiles (sorted by size, largest to smallest):")
    for i, (name, path, size) in enumerate(available_profiles):
        print(f"{i+1}. {name} ({path}) - Size: {size/1024/1024:.2f} MB")
    choice = input("Select the number of the profile you want to use: ")
    try:
        chosen_profile = available_profiles[int(choice) - 1][1]
        print(f"Selected profile: {chosen_profile}")
        return chosen_profile
    except (ValueError, IndexError):
        print("Invalid selection.")
        return None


def backup_thunderbird_profile(profile_name):
    home = os.path.expanduser("~")
    thunderbird_dir = os.path.join(home, ".thunderbird")
    profile_dir = os.path.join(thunderbird_dir, profile_name)
    backup_dir = os.path.join(home, "OneDrive", "Backups")

    if not os.path.exists(profile_dir):
        print(f"Error: Profile directory not found at {profile_dir}")
        return None

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_filename = f"Thunderbird_{profile_name}_{timestamp}.zip"
    backup_path = os.path.join(backup_dir, backup_filename)

    print(f"Creating full profile backup at: {backup_path}")

    try:
        with zipfile.ZipFile(backup_path, "w", zipfile.ZIP_DEFLATED) as zipf:
            for root, dirs, files in os.walk(profile_dir):
                for file in files:
                    file_path = os.path.join(root, file)
                    arcname = os.path.relpath(file_path, profile_dir)
                    if file == "lock":
                        print(f"Ignoring lock file: {file_path}")
                        continue
                    try:
                        zipf.write(file_path, arcname)
                    except OSError as e:
                        print(
                            f"Warning: Could not add file {file_path} to backup. Error: {e}"
                        )

        print(f"Backup completed: {backup_path}")
        return backup_path
    except Exception as e:
        print(f"Error creating backup: {str(e)}")
        return None


def get_latest_backup(backup_dir):
    backup_pattern = os.path.join(backup_dir, "Thunderbird_*.zip")
    backups = glob.glob(backup_pattern)
    if not backups:
        print("No existing backups found.")
        return None
    return max(backups, key=os.path.getctime)


def extract_backup(zip_path, extract_dir):
    if not os.path.exists(zip_path):
        print(f"Error: Backup file not found: {zip_path}")
        return None

    try:
        with zipfile.ZipFile(zip_path, "r") as zip_ref:
            zip_ref.extractall(extract_dir)
        return extract_dir
    except Exception as e:
        print(f"Error extracting backup: {str(e)}")
        return None


def restore_thunderbird_filters(backup_dir, profile_dir):
    imap_mail_dir = os.path.join(profile_dir, "ImapMail")
    backup_imap_dir = os.path.join(backup_dir, "ImapMail")

    if not os.path.exists(backup_imap_dir):
        print(f"Warning: ImapMail directory not found in backup: {backup_imap_dir}")
        return

    for account_dir in os.listdir(backup_imap_dir):
        backup_account_path = os.path.join(backup_imap_dir, account_dir)
        if os.path.isdir(backup_account_path):
            filter_file = os.path.join(backup_account_path, "msgFilterRules.dat")
            if os.path.exists(filter_file):
                dest_dir = os.path.join(imap_mail_dir, account_dir)
                os.makedirs(dest_dir, exist_ok=True)
                shutil.copy2(filter_file, os.path.join(dest_dir, "msgFilterRules.dat"))
                print(f"Restored filters for {account_dir}")
            else:
                print(f"Filter file not found for {account_dir}")


def restore_config_files(backup_dir, profile_dir):
    config_files = [
        "prefs.js",
        "user.js",
        "persdict.dat",
        "cert9.db",
        "key4.db",
        "logins.json",
    ]
    for file in config_files:
        src = os.path.join(backup_dir, file)
        dst = os.path.join(profile_dir, file)
        if os.path.exists(src):
            shutil.copy2(src, dst)
            print(f"Restored configuration file: {file}")
        else:
            print(f"Warning: Configuration file not found: {file}")


def handle_msg_filter_rules_by_account(profile_dir):
    imap_mail_dir = os.path.join(profile_dir, "ImapMail")

    for account_dir in os.listdir(imap_mail_dir):
        filter_file = os.path.join(imap_mail_dir, account_dir, "msgFilterRules.dat")
        if os.path.exists(filter_file):
            print(f"Found filter file for account: {account_dir}")
            handle = input(
                f"Do you want to backup and recreate filters for {account_dir}? (y/n): "
            ).lower()
            if handle == "y":
                backup_path = filter_file + ".bak"
                print(f"Backing up {filter_file} to {backup_path}")
                shutil.copy2(filter_file, backup_path)
                print(f"Removing {filter_file} for Thunderbird to recreate")
                os.remove(filter_file)
            else:
                print(f"Skipping filter handling for {account_dir}")
        else:
            print(f"No filter file found for account: {account_dir}")


def backup_thunderbird():
    print("Starting Thunderbird backup process...")

    active_profile = get_active_profile()
    if not active_profile:
        print("Could not select a valid profile. Exiting...")
        return

    home = os.path.expanduser("~")
    thunderbird_dir = os.path.join(home, ".thunderbird")
    profile_dir = os.path.join(thunderbird_dir, active_profile)

    if not os.path.exists(profile_dir):
        print(f"Error: Profile directory not found at {profile_dir}")
        return

    backup_dir = os.path.join(home, "OneDrive", "Backups")
    os.makedirs(backup_dir, exist_ok=True)

    # Perform full backup
    backup_zip_path = backup_thunderbird_profile(active_profile)
    if not backup_zip_path:
        print("Could not create backup. Exiting...")
        return

    print(f"Backup completed successfully: {backup_zip_path}")


def restore_thunderbird():
    print("Starting Thunderbird restoration process...")

    active_profile = get_active_profile()
    if not active_profile:
        print("Could not select a valid profile. Exiting...")
        return

    home = os.path.expanduser("~")
    thunderbird_dir = os.path.join(home, ".thunderbird")
    profile_dir = os.path.join(thunderbird_dir, active_profile)

    if not os.path.exists(profile_dir):
        print(f"Error: Profile directory not found at {profile_dir}")
        return

    backup_dir = os.path.join(home, "OneDrive", "Backups")

    # Get the latest backup
    latest_backup = get_latest_backup(backup_dir)
    if not latest_backup:
        print("No backups found to restore. Exiting...")
        return

    print(f"Using the most recent backup: {latest_backup}")

    # Ask if msgFilterRules.dat should be handled
    handle_filters = input(
        "Do you want to backup msgFilterRules.dat and let Thunderbird recreate it? (y/n): "
    ).lower()
    if handle_filters == "y":
        handle_msg_filter_rules_by_account(profile_dir)

    # Extract backup to a temporary directory
    temp_extract_dir = os.path.join(os.path.dirname(latest_backup), "temp_extract")
    os.makedirs(temp_extract_dir, exist_ok=True)
    extracted_backup_dir = extract_backup(latest_backup, temp_extract_dir)
    if not extracted_backup_dir:
        print("Could not extract backup. Exiting...")
        return

    # Restore filters
    print("Restoring filters...")
    restore_thunderbird_filters(extracted_backup_dir, profile_dir)

    # Restore configuration files
    print("Restoring configuration files...")
    restore_config_files(extracted_backup_dir, profile_dir)

    # Clean up temporary directory
    print("Cleaning up temporary files...")
    if os.path.exists(temp_extract_dir):
        shutil.rmtree(temp_extract_dir)

    print("Restoration process completed.")
    print("Please restart Thunderbird to apply the changes.")
    if handle_filters == "y":
        print("Thunderbird will create new msgFilterRules.dat files upon startup.")
        print(
            "If filters still don't appear, you can manually restore the backups (.bak) files."
        )


def main():
    while True:
        print("\nThunderbird Backup and Restore Manager")
        print("1. Perform Backup")
        print("2. Restore from Backup")
        print("3. Exit")

        choice = input("Select an option (1-3): ")

        if choice == "1":
            backup_thunderbird()
        elif choice == "2":
            restore_thunderbird()
        elif choice == "3":
            print("Exiting the program...")
            break
        else:
            print("Invalid option. Please try again.")


if __name__ == "__main__":
    main()

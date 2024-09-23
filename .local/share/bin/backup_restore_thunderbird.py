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
                print(f"Advertencia: No se pudo acceder al archivo {fp}. Error: {e}")
    return total_size


def get_active_profile():
    home = os.path.expanduser("~")
    thunderbird_dir = os.path.join(home, ".thunderbird")
    profiles_ini = os.path.join(thunderbird_dir, "profiles.ini")

    if not os.path.exists(profiles_ini):
        print(f"Error: No se encontró el archivo profiles.ini en {profiles_ini}")
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
                print(f"Analizando perfil: {name} en {full_path}")
                if os.path.exists(full_path):
                    size = get_directory_size(full_path)
                    available_profiles.append((name, path, size))
                    print(f"  Tamaño del perfil: {size/1024/1024:.2f} MB")
                    if "default-release" in path:
                        default_release_profile = path
                    elif "default" in path:
                        default_profile = path
                else:
                    print(
                        f"  ¡Advertencia! El directorio del perfil no existe: {full_path}"
                    )

    available_profiles.sort(key=lambda x: x[2], reverse=True)

    if default_release_profile:
        print(f"Perfil 'default-release' detectado: {default_release_profile}")
        confirm = input("¿Desea usar este perfil? (s/n): ").lower()
        if confirm == "s":
            return default_release_profile

    if default_profile:
        print(f"Perfil 'default' detectado: {default_profile}")
        confirm = input("¿Desea usar este perfil? (s/n): ").lower()
        if confirm == "s":
            return default_profile

    print("Perfiles disponibles (ordenados por tamaño, de mayor a menor):")
    for i, (name, path, size) in enumerate(available_profiles):
        print(f"{i+1}. {name} ({path}) - Tamaño: {size/1024/1024:.2f} MB")
    choice = input("Seleccione el número del perfil que desea usar: ")
    try:
        chosen_profile = available_profiles[int(choice) - 1][1]
        print(f"Perfil seleccionado: {chosen_profile}")
        return chosen_profile
    except (ValueError, IndexError):
        print("Selección inválida.")
        return None


def backup_thunderbird_profile(profile_name):
    home = os.path.expanduser("~")
    thunderbird_dir = os.path.join(home, ".thunderbird")
    profile_dir = os.path.join(thunderbird_dir, profile_name)
    backup_dir = os.path.join(home, "OneDrive", "Backups")

    if not os.path.exists(profile_dir):
        print(f"Error: No se encontró el directorio del perfil en {profile_dir}")
        return None

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_filename = f"Thunderbird_{profile_name}_{timestamp}.zip"
    backup_path = os.path.join(backup_dir, backup_filename)

    print(f"Creando backup completo del perfil en: {backup_path}")

    try:
        with zipfile.ZipFile(backup_path, "w", zipfile.ZIP_DEFLATED) as zipf:
            for root, dirs, files in os.walk(profile_dir):
                for file in files:
                    file_path = os.path.join(root, file)
                    arcname = os.path.relpath(file_path, profile_dir)
                    if file == "lock":
                        print(f"Ignorando el archivo de bloqueo: {file_path}")
                        continue
                    try:
                        zipf.write(file_path, arcname)
                    except OSError as e:
                        print(
                            f"Advertencia: No se pudo añadir el archivo {file_path} al backup. Error: {e}"
                        )

        print(f"Backup completado: {backup_path}")
        return backup_path
    except Exception as e:
        print(f"Error al crear el backup: {str(e)}")
        return None


def get_latest_backup(backup_dir):
    backup_pattern = os.path.join(backup_dir, "Thunderbird_*.zip")
    backups = glob.glob(backup_pattern)
    if not backups:
        print("No se encontraron backups existentes.")
        return None
    return max(backups, key=os.path.getctime)


def extract_backup(zip_path, extract_dir):
    if not os.path.exists(zip_path):
        print(f"Error: No se encontró el archivo de backup: {zip_path}")
        return None

    try:
        with zipfile.ZipFile(zip_path, "r") as zip_ref:
            zip_ref.extractall(extract_dir)
        return extract_dir
    except Exception as e:
        print(f"Error al extraer el backup: {str(e)}")
        return None


def restore_thunderbird_filters(backup_dir, profile_dir):
    imap_mail_dir = os.path.join(profile_dir, "ImapMail")
    backup_imap_dir = os.path.join(backup_dir, "ImapMail")

    if not os.path.exists(backup_imap_dir):
        print(
            f"Advertencia: No se encontró el directorio ImapMail en el backup: {backup_imap_dir}"
        )
        return

    for account_dir in os.listdir(backup_imap_dir):
        backup_account_path = os.path.join(backup_imap_dir, account_dir)
        if os.path.isdir(backup_account_path):
            filter_file = os.path.join(backup_account_path, "msgFilterRules.dat")
            if os.path.exists(filter_file):
                dest_dir = os.path.join(imap_mail_dir, account_dir)
                os.makedirs(dest_dir, exist_ok=True)
                shutil.copy2(filter_file, os.path.join(dest_dir, "msgFilterRules.dat"))
                print(f"Restaurados los filtros para {account_dir}")
            else:
                print(f"No se encontró el archivo de filtros para {account_dir}")


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
            print(f"Restaurado el archivo de configuración: {file}")
        else:
            print(f"Advertencia: No se encontró el archivo de configuración: {file}")


def main():
    print("Iniciando el proceso de backup y restauración de Thunderbird...")

    active_profile = get_active_profile()
    if not active_profile:
        print("No se pudo seleccionar un perfil válido. Saliendo...")
        return

    home = os.path.expanduser("~")
    thunderbird_dir = os.path.join(home, ".thunderbird")
    profile_dir = os.path.join(thunderbird_dir, active_profile)

    if not os.path.exists(profile_dir):
        print(f"Error: No se encontró el directorio del perfil en {profile_dir}")
        return

    backup_dir = os.path.join(home, "OneDrive", "Backups")
    os.makedirs(backup_dir, exist_ok=True)

    # Realizar backup completo
    backup_zip_path = backup_thunderbird_profile(active_profile)
    if not backup_zip_path:
        print("No se pudo crear el backup. Saliendo...")
        return

    # Obtener el último backup (que debería ser el que acabamos de crear)
    latest_backup = get_latest_backup(backup_dir)
    if latest_backup != backup_zip_path:
        print(
            f"Advertencia: El backup más reciente ({latest_backup}) no coincide con el recién creado ({backup_zip_path})"
        )
        use_latest = input(
            "¿Desea usar el backup más reciente para la restauración? (s/n): "
        ).lower()
        if use_latest == "s":
            backup_zip_path = latest_backup

    # Extraer el backup en un directorio temporal
    temp_extract_dir = os.path.join(os.path.dirname(backup_zip_path), "temp_extract")
    os.makedirs(temp_extract_dir, exist_ok=True)
    extracted_backup_dir = extract_backup(backup_zip_path, temp_extract_dir)
    if not extracted_backup_dir:
        print("No se pudo extraer el backup. Saliendo...")
        return

    # Restaurar filtros
    print("Restaurando filtros...")
    restore_thunderbird_filters(extracted_backup_dir, profile_dir)

    # Restaurar archivos de configuración
    print("Restaurando archivos de configuración...")
    restore_config_files(extracted_backup_dir, profile_dir)

    # Limpiar el directorio temporal
    print("Limpiando archivos temporales...")
    if os.path.exists(temp_extract_dir):
        shutil.rmtree(temp_extract_dir)

    print("Proceso de backup y restauración completado.")
    print("Por favor, reinicie Thunderbird para aplicar los cambios.")


def handle_msg_filter_rules_by_account(profile_dir):
    imap_mail_dir = os.path.join(profile_dir, "ImapMail")

    for account_dir in os.listdir(imap_mail_dir):
        filter_file = os.path.join(imap_mail_dir, account_dir, "msgFilterRules.dat")
        if os.path.exists(filter_file):
            print(f"Encontrado archivo de filtros para la cuenta: {account_dir}")
            handle = input(
                f"¿Desea hacer una copia de seguridad y recrear los filtros para {account_dir}? (s/n): "
            ).lower()
            if handle == "s":
                backup_path = filter_file + ".bak"
                print(f"Haciendo copia de seguridad de {filter_file} a {backup_path}")
                shutil.copy2(filter_file, backup_path)
                print(f"Eliminando {filter_file} para que Thunderbird lo recree")
                os.remove(filter_file)
            else:
                print(f"Saltando el manejo de filtros para {account_dir}")
        else:
            print(f"No se encontró archivo de filtros para la cuenta: {account_dir}")


def backup_thunderbird():
    print("Iniciando el proceso de backup de Thunderbird...")

    active_profile = get_active_profile()
    if not active_profile:
        print("No se pudo seleccionar un perfil válido. Saliendo...")
        return

    home = os.path.expanduser("~")
    thunderbird_dir = os.path.join(home, ".thunderbird")
    profile_dir = os.path.join(thunderbird_dir, active_profile)

    if not os.path.exists(profile_dir):
        print(f"Error: No se encontró el directorio del perfil en {profile_dir}")
        return

    backup_dir = os.path.join(home, "OneDrive", "Backups")
    os.makedirs(backup_dir, exist_ok=True)

    # Realizar backup completo
    backup_zip_path = backup_thunderbird_profile(active_profile)
    if not backup_zip_path:
        print("No se pudo crear el backup. Saliendo...")
        return

    print(f"Backup completado exitosamente: {backup_zip_path}")


def restore_thunderbird():
    print("Iniciando el proceso de restauración de Thunderbird...")

    active_profile = get_active_profile()
    if not active_profile:
        print("No se pudo seleccionar un perfil válido. Saliendo...")
        return

    home = os.path.expanduser("~")
    thunderbird_dir = os.path.join(home, ".thunderbird")
    profile_dir = os.path.join(thunderbird_dir, active_profile)

    if not os.path.exists(profile_dir):
        print(f"Error: No se encontró el directorio del perfil en {profile_dir}")
        return

    backup_dir = os.path.join(home, "OneDrive", "Backups")

    # Obtener el último backup
    latest_backup = get_latest_backup(backup_dir)
    if not latest_backup:
        print("No se encontraron backups para restaurar. Saliendo...")
        return

    print(f"Se utilizará el backup más reciente: {latest_backup}")

    # Preguntar si se desea manejar msgFilterRules.dat
    handle_filters = input(
        "¿Desea hacer una copia de seguridad de msgFilterRules.dat y permitir que Thunderbird lo recree? (s/n): "
    ).lower()
    if handle_filters == "s":
        handle_msg_filter_rules_by_account(profile_dir)

    # Extraer el backup en un directorio temporal
    temp_extract_dir = os.path.join(os.path.dirname(latest_backup), "temp_extract")
    os.makedirs(temp_extract_dir, exist_ok=True)
    extracted_backup_dir = extract_backup(latest_backup, temp_extract_dir)
    if not extracted_backup_dir:
        print("No se pudo extraer el backup. Saliendo...")
        return

    # Restaurar filtros
    print("Restaurando filtros...")
    restore_thunderbird_filters(extracted_backup_dir, profile_dir)

    # Restaurar archivos de configuración
    print("Restaurando archivos de configuración...")
    restore_config_files(extracted_backup_dir, profile_dir)

    # Limpiar el directorio temporal
    print("Limpiando archivos temporales...")
    if os.path.exists(temp_extract_dir):
        shutil.rmtree(temp_extract_dir)

    print("Proceso de restauración completado.")
    print("Por favor, reinicie Thunderbird para aplicar los cambios.")
    if handle_filters == "s":
        print("Thunderbird creará nuevos archivos msgFilterRules.dat al iniciar.")
        print(
            "Si los filtros aún no aparecen, puede restaurar las copias de seguridad (.bak) manualmente."
        )


def main():
    while True:
        print("\nGestor de Backup y Restauración de Thunderbird")
        print("1. Realizar Backup")
        print("2. Restaurar desde Backup")
        print("3. Salir")

        choice = input("Seleccione una opción (1-3): ")

        if choice == "1":
            backup_thunderbird()
        elif choice == "2":
            restore_thunderbird()
        elif choice == "3":
            print("Saliendo del programa...")
            break
        else:
            print("Opción no válida. Por favor, intente de nuevo.")


if __name__ == "__main__":
    main()

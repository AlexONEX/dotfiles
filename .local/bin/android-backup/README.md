# Android Backup & Restore System

Sistema completo de backup y restauración para Android (especialmente optimizado para Samsung S23).

## 📋 Contenido

- **backup.sh**: Script de backup completo
- **restore.sh**: Script de restauración automatizada
- **debloat.sh**: Script mejorado de debloat con logging
- **backups/**: Directorio donde se guardan los backups

## 🚀 Uso Rápido

### 1. Preparar el dispositivo

Antes de hacer el backup, habilita USB debugging en tu Android:

```bash
# En tu Android:
# Ajustes → Acerca del teléfono → Información del software
# Toca 7 veces en "Número de compilación"
# Vuelve atrás → Opciones de desarrollador
# Activa "Depuración USB"
```

Conecta tu dispositivo y autoriza la conexión:

```bash
adb devices
# Deberías ver: RFCW41TBBNF    device
```

### 2. Hacer el Backup (ANTES del factory reset)

```bash
cd /Users/alex/Github/me/dotfiles/.local/bin/android-backup/scripts
chmod +x backup.sh
./backup.sh
```

El script creará un backup completo que incluye:

- ✅ Lista de apps instaladas
- ✅ APKs de todas las apps
- ✅ Datos de aplicaciones
- ✅ Fotos y videos (DCIM)
- ✅ Documentos
- ✅ Descargas
- ✅ Música
- ✅ SMS y registro de llamadas (si tiene permisos)
- ✅ Configuraciones del sistema
- ✅ Configuraciones WiFi (si tiene root)

**Ubicación del backup:**
```
/Users/alex/Github/me/dotfiles/.local/bin/android-backup/backups/backup_YYYYMMDD_HHMMSS/
```

### 3. Factory Reset

Una vez que el backup esté completo:

1. **Verifica que el backup se completó correctamente**
2. En tu Android: Ajustes → Administración General → Restablecer → Restablecer datos de fábrica
3. Confirma y espera a que termine

### 4. Restaurar (DESPUÉS del factory reset)

```bash
cd /Users/alex/Github/me/dotfiles/.local/bin/android-backup/scripts
chmod +x restore.sh

# Ver backups disponibles
ls -lt ../backups/

# Restaurar desde el backup más reciente
./restore.sh ../backups/backup_YYYYMMDD_HHMMSS
```

El script de restauración:

1. ✅ **Ejecuta el debloat** (elimina bloatware de Samsung/Google/Facebook)
2. ✅ **Reinstala todas tus apps**
3. ✅ **Restaura los datos de las apps**
4. ✅ **Restaura fotos, documentos, música, etc.**
5. ✅ **Restaura configuraciones del sistema** (opcional)
6. ✅ **Reinicia el dispositivo**

## 🛠️ Scripts Individuales

### Solo Debloat (sin backup/restore)

Si solo quieres eliminar bloatware sin hacer backup:

```bash
cd /Users/alex/Github/me/dotfiles/.local/bin/android-backup/scripts
chmod +x debloat.sh
./debloat.sh
```

Este script:
- Elimina Bixby, Samsung Health, Samsung Pay, AR Emoji, etc.
- Elimina apps de Google innecesarias (Chrome, Gmail, YouTube, Maps)
- Elimina Facebook y sus servicios
- Elimina Microsoft OneDrive y Your Phone
- Elimina Netflix preinstalado
- **NO elimina**: Play Store, Play Services, componentes críticos del sistema

Los logs se guardan en: `backups/debloat_YYYYMMDD_HHMMSS.log`

## ⚠️ Notas Importantes

### Durante el Backup

- **Desbloquea tu dispositivo** cuando se te pida autorizar el backup
- El proceso puede tardar 15-30 minutos dependiendo de cuántas apps tengas
- Asegúrate de tener suficiente espacio en tu Mac (al menos 20GB libres)

### Durante el Restore

- **El dispositivo debe estar recién reseteado** para mejores resultados
- El proceso de restore puede tardar 30-60 minutos
- **Desbloquea tu dispositivo** cuando se te pida autorizar la restauración
- Algunas apps pueden necesitar login manual después

### Apps que NO se pueden restaurar automáticamente

Estas apps requieren instalación manual desde Play Store:
- Apps de bancos (por seguridad)
- Apps con protección SafetyNet
- Apps del sistema que fueron actualizadas

### Configuraciones WiFi

Las contraseñas WiFi requieren acceso root para respaldarse. Si no tienes root, deberás reconfigurar WiFi manualmente.

## 📂 Estructura de un Backup

```
backup_20260315_120000/
├── README.txt                    # Resumen del backup
├── device_info.txt               # Info del dispositivo
├── installed_apps.txt            # Lista de apps instaladas
├── all_packages.txt              # Todos los paquetes
├── app_data.ab                   # Datos de apps (formato Android Backup)
├── apks/                         # APKs de las apps
│   ├── com.example.app1.apk
│   └── com.example.app2.apk
├── storage/                      # Almacenamiento interno
│   ├── DCIM/                     # Fotos y videos
│   ├── Pictures/
│   ├── Documents/
│   ├── Download/
│   └── Music/
├── sms_backup.txt                # SMS (si tiene permisos)
├── call_log.txt                  # Registro de llamadas
├── settings_system.txt           # Configuraciones del sistema
├── settings_secure.txt           # Configuraciones seguras
├── settings_global.txt           # Configuraciones globales
└── wifi_config.xml               # WiFi (solo con root)
```

## 🔧 Solución de Problemas

### "No device found or device unauthorized"

```bash
# Revoca autorizaciones y vuelve a intentar
adb kill-server
adb start-server
adb devices
# Acepta el popup en tu Android
```

### "Backup failed" o archivo app_data.ab vacío

- Desbloquea el dispositivo
- Acepta el popup de backup cuando aparezca
- Asegúrate de no tener contraseña de backup configurada

### Algunas apps no se instalan durante restore

- Normal para apps del sistema o apps con protección especial
- Instálalas manualmente desde Play Store

### El debloat eliminó algo que necesito

Puedes reinstalar paquetes individuales:

```bash
# Ver paquetes eliminados
adb shell pm list packages -u | grep samsung

# Reinstalar un paquete específico
adb shell cmd package install-existing com.samsung.android.calendar
```

## 📊 Estadísticas Típicas

Un backup típico de Samsung S23:
- **Tiempo de backup**: 15-30 minutos
- **Tamaño del backup**: 10-30 GB (depende de fotos/videos)
- **Apps respaldadas**: 50-150 apps
- **Tiempo de restore**: 30-60 minutos
- **Apps eliminadas en debloat**: ~80-100 paquetes

## 🔗 Scripts Relacionados

- **Script original de debloat**: `/Users/alex/Github/me/dotfiles/.local/bin/android_debloat.sh`
- Este sistema usa una versión mejorada con mejor logging y manejo de errores

## 📝 Tips

1. **Haz backups regulares** (al menos mensualmente)
2. **Verifica el backup** antes de hacer factory reset
3. **Mantén los backups antiguos** por si necesitas restaurar algo específico
4. **Limpia backups viejos** después de 3-6 meses para ahorrar espacio
5. **Considera usar Google Photos** para backup automático de fotos (además de este sistema)

## 🆘 Ayuda

Si encuentras problemas:

1. Revisa los logs en `backups/debloat_*.log`
2. Verifica que adb funcione: `adb devices`
3. Asegúrate de tener permisos de ejecución: `chmod +x *.sh`
4. Verifica espacio disponible: `df -h`

---

**Última actualización**: 2026-03-15
**Compatible con**: Samsung S23, Android 13+
**Requiere**: ADB instalado, USB debugging habilitado

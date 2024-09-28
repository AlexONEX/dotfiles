#!/bin/bash

# Definir el prefijo a eliminar via input
prefix=""

# Iterar sobre todos los archivos en el directorio actual
for file in $prefix*; do
    # Verificar si el archivo existe (para evitar errores si no hay coincidencias)
    if [ -e "$file" ]; then
        # Obtener el nuevo nombre eliminando el prefijo
        newname="${file#$prefix}"
        # Renombrar el archivo
        mv "$file" "$newname"
        echo "Renombrado: $file -> $newname"
    fi
done

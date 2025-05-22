#!/usr/bin/env python3
"""
Convertidor mejorado de cuentas de GnuCash a hledger
Este script toma un archivo CSV exportado de GnuCash y genera las declaraciones
de cuentas en el formato que hledger espera, con los tipos correctos.
"""

import csv
import sys


def clean_account_name(name):
    """Limpia y corrige nombres de cuentas."""
    # Corrige errores comunes como "Assests" por "Assets"
    name = name.replace("Assests", "Assets")
    return name


def determine_type_code(gnucash_type):
    """
    Determina el código de tipo para hledger basado en el tipo de GnuCash.

    Mapeo según la documentación de hledger:
    - A (Asset): Activos
    - L (Liability): Pasivos
    - E (Equity): Patrimonio
    - R (Revenue): Ingresos
    - X (Expense): Gastos
    - C (Cash): Efectivo (subtipo de activo)
    - V (Conversion): Conversión (subtipo de patrimonio)
    """
    type_mapping = {
        "ASSET": "A",  # Activo
        "BANK": "A",  # Banco es un tipo de activo
        "CASH": "C",  # Efectivo es un tipo especial de activo
        "CREDIT": "L",  # Tarjeta de crédito es un pasivo
        "CURRENCY": "A",  # Moneda es un activo
        "EXPENSE": "X",  # Gasto
        "INCOME": "R",  # Ingreso/Revenue
        "LIABILITY": "L",  # Pasivo
        "EQUITY": "E",  # Patrimonio
        "RECEIVABLE": "A",  # Por cobrar es un activo
        "STOCK": "A",  # Acciones son activos
    }
    return type_mapping.get(gnucash_type, "A")  # Default to Asset if unknown


def process_gnucash_csv(csv_file, output_file=None):
    """
    Procesa el archivo CSV de GnuCash y genera declaraciones de cuentas para hledger.
    """
    accounts = []
    commodities = set()  # Para almacenar las commodities únicas

    with open(csv_file, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            gnucash_type = row["Type"]
            full_account = clean_account_name(row["Full Account Name"])
            description = row.get("Description", "")
            symbol = row.get("Symbol", "")  # La moneda/commodity

            if symbol:
                commodities.add(symbol)

            # Determina el tipo de cuenta para hledger
            type_code = determine_type_code(gnucash_type)

            # Añade esta cuenta a nuestra lista
            accounts.append(
                {
                    "full_name": full_account,
                    "type": type_code,
                    "description": description,
                }
            )

    # Ordenar las cuentas por nombre completo para mantener la jerarquía
    accounts.sort(key=lambda x: x["full_name"])

    # Generar la salida
    output = []
    output.append("; Declaraciones de cuentas para hledger")
    output.append("; Generado automáticamente desde CSV de GnuCash")
    output.append("")

    # Agregar las declaraciones de commodities
    output.append("; Commodities")
    for commodity in sorted(commodities):
        if commodity:  # Solo si no está vacío
            output.append(f"commodity {commodity}")
    output.append("")

    # Agregar las declaraciones de cuentas
    output.append("; Cuentas")
    for account in accounts:
        output.append(f"account {account['full_name']}  ; type:{account['type']}")
        if account["description"]:
            output.append(f"; {account['description']}")

    # Escribir salida
    if output_file:
        with open(output_file, "w", encoding="utf-8") as f:
            f.write("\n".join(output))
        print(f"Archivo de declaraciones de cuentas generado: {output_file}")
    else:
        print("\n".join(output))


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(
            "Uso: python gnucash_to_hledger.py archivo_gnucash.csv [archivo_salida.txt]"
        )
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else None

    process_gnucash_csv(input_file, output_file)

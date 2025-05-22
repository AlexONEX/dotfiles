#!/usr/bin/env python3
import os
import sys
import datetime
from decimal import Decimal

def main():
    """Función principal del script."""
    # Obtener la variable de entorno LEDGER_FILE
    ledger_file = os.environ.get('LEDGER_FILE')
    if not ledger_file:
        print("Error: LEDGER_FILE environment variable is not set.")
        print("Please set it to the path of your hledger journal file.")
        sys.exit(1)

    # Crear un archivo temporal para almacenar las transacciones
    temp_file = ledger_file + ".temp"
    transactions = []

    print("Credit Card Transaction Recording for hledger")
    print(f"Journal file: {ledger_file}")
    print("\nEnter transactions one by one. Enter 'q' when finished.")

    # Seleccionar la tarjeta
    print("\nSelect credit card:")
    print("1. Visa Galicia (ARS)")
    print("2. Visa Galicia (USD)")
    print("3. Galicia Mastercard")

    card_choice = input("Enter choice (1-3): ")
    if card_choice == "1":
        card_account = "Liabilities:Tarjeta de Crédito:Galicia Visa:Visa Credito (ARS)"
        currency = "ARS"
    elif card_choice == "2":
        card_account = "Liabilities:Tarjeta de Crédito:Galicia Visa:Visa Credito (USD)"
        currency = "USD"
    elif card_choice == "3":
        card_account = "Liabilities:Tarjeta de Crédito:Galicia Mastercard"
        currency = "ARS"
    else:
        print("Invalid choice. Using Visa Galicia (ARS) by default.")
        card_account = "Liabilities:Tarjeta de Crédito:Galicia Visa:Visa Credito (ARS)"
        currency = "ARS"

    # Ingresar transacciones
    transaction_count = 0
    while True:
        print(f"\nTransaction #{transaction_count+1}")
        print("--------------------------")

        # Fecha
        date_input = input("Date [YYYY-MM-DD] (or 'q' to finish): ")
        if date_input.lower() == 'q':
            break

        # Validar el formato de fecha
        try:
            # Intentar parsear la fecha para validarla
            datetime.datetime.strptime(date_input, "%Y-%m-%d")
        except ValueError:
            print("Invalid date format. Please use YYYY-MM-DD.")
            continue

        # Descripción
        description = input("Description: ")
        if not description:
            print("Description is required.")
            continue

        # Monto
        amount_input = input(f"Amount ({currency}): ")
        try:
            amount = Decimal(amount_input)
        except:
            print("Invalid amount. Please enter a numeric value.")
            continue

        # Categoría de gasto
        print("\nExpense categories:")
        categories = [
            "Alimentos y bebidas no alcohólicas",
            "Bebidas alcohólicas y tabaco",
            "Bienes y servicios varios",
            "Comisiones",
            "Comunicación",
            "Educación",
            "Equipamiento y mantenimiento del hogar",
            "Impuestos",
            "Recreación y cultura",
            "Regalos",
            "Restaurantes y Hoteles",
            "Rodados",
            "Salud",
            "Seguros",
            "Transporte",
            "Vivienda, agua, electricidad, gas y otros combustibles"
        ]

        for i, category in enumerate(categories, 1):
            print(f"{i}. {category}")

        # Solicitar categoría
        cat_choice = input("Select category (1-16) or enter a custom one: ")
        try:
            cat_index = int(cat_choice) - 1
            if 0 <= cat_index < len(categories):
                category = f"Expenses:{categories[cat_index]}"
            else:
                category = input("Enter custom expense category: ")
                if not category.startswith("Expenses:"):
                    category = "Expenses:" + category
        except ValueError:
            category = input("Enter custom expense category: ")
            if not category.startswith("Expenses:"):
                category = "Expenses:" + category

        # Subcategoría (opcional)
        subcategory = input("Enter subcategory (optional): ")
        if subcategory:
            category = f"{category}:{subcategory}"

        # Comentario (opcional)
        comment = input("Comment (optional): ")
        comment_str = f" ; {comment}" if comment else ""

        # Crear la transacción
        transaction = f"""{date_input} * {description}
    {category}{' ' * (50 - len(category))}{currency} {amount}{comment_str}
    {card_account}
"""

        # Agregar a la lista de transacciones
        transactions.append(transaction)
        transaction_count += 1
        print(f"Transaction #{transaction_count} added.")

    # Si no hay transacciones, salir
    if not transactions:
        print("No transactions entered. Exiting.")
        return

    # Mostrar todas las transacciones ingresadas
    print("\nTransactions to be added:")
    print("=" * 50)
    for i, txn in enumerate(transactions, 1):
        print(f"Transaction #{i}:")
        print(txn)
    print("=" * 50)

    # Confirmar la adición al archivo
    confirm = input("Add these transactions to your journal file? (y/n): ")
    if confirm.lower() == 'y':
        with open(ledger_file, 'a') as f:
            f.write("\n; Credit card transactions added on " + datetime.datetime.now().strftime("%Y-%m-%d") + "\n")
            for txn in transactions:
                f.write("\n" + txn)
        print(f"{transaction_count} transactions added to {ledger_file}")
    else:
        print("Operation cancelled. No transactions were added.")

if __name__ == "__main__":
    main()

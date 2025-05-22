#!/usr/bin/env python3
"""
Script para automatizar el registro de sueldos en hledger.
Parametriza los valores y genera la entrada correcta en el archivo journal.
"""

import os
import sys
import datetime
from decimal import Decimal, ROUND_HALF_UP

# Valor por defecto para el salario bruto
DEFAULT_GROSS_SALARY = "1834099.20"

def round_decimal(value, decimal_places=2):
    """Redondea un número decimal a los lugares decimales especificados."""
    if isinstance(value, str):
        value = Decimal(value)
    return value.quantize(Decimal(10) ** -decimal_places, rounding=ROUND_HALF_UP)

def calculate_payroll(gross_salary):
    """Calcula las deducciones basadas en el salario bruto."""
    # Convertir a Decimal si se proporciona un string
    if isinstance(gross_salary, str):
        gross_salary = Decimal(gross_salary)

    # Porcentajes de deducciones
    retirement_pct = Decimal('0.11')  # Jubilación 11%
    law_19032_pct = Decimal('0.03')   # Ley 19032 (PAMI) 3%
    health_ins_pct = Decimal('0.03')  # Obra Social 3%

    # Calcular deducciones
    retirement = round_decimal(gross_salary * retirement_pct)
    law_19032 = round_decimal(gross_salary * law_19032_pct)
    health_ins = round_decimal(gross_salary * health_ins_pct)

    # Para este ejemplo, asumimos que el préstamo es un valor fijo
    loan_payment = Decimal('17470.00')

    # Calcular neto antes de ajustes
    net_before_adjustment = gross_salary - retirement - law_19032 - health_ins - loan_payment

    # El neto final debe ser redondeado
    net_salary = round_decimal(net_before_adjustment)

    # Calcular el redondeo
    rounding = net_salary - net_before_adjustment

    return {
        'gross': gross_salary,
        'retirement': retirement,
        'law_19032': law_19032,
        'health_ins': health_ins,
        'loan_payment': loan_payment,
        'net_salary': net_salary,
        'rounding': rounding
    }

def generate_hledger_entry(date, period, department, gross_salary, loan_payment=None):
    """Genera una entrada para hledger con los datos proporcionados."""
    # Calcular todos los valores basados en el salario bruto
    salary_data = calculate_payroll(gross_salary)

    # Si se proporciona un valor específico de préstamo, reemplazar el calculado
    if loan_payment is not None:
        salary_data['loan_payment'] = Decimal(loan_payment)
        # Recalcular el neto y el redondeo
        net_before_adjustment = salary_data['gross'] - salary_data['retirement'] - \
                               salary_data['law_19032'] - salary_data['health_ins'] - \
                               salary_data['loan_payment']
        salary_data['net_salary'] = round_decimal(net_before_adjustment)
        salary_data['rounding'] = salary_data['net_salary'] - net_before_adjustment

    # Formatear la entrada de hledger
    entry = f"""{date} * Salary {department} {period}
    Assets:Current Assets:Savings Account:Galicia (ARS)    ARS {salary_data['net_salary']}
    Income:Salary:Allaria                                  ARS -{salary_data['gross']}
    Expenses:Taxes:Retirement                              ARS {salary_data['retirement']}
    Expenses:Taxes:Law 19032                               ARS {salary_data['law_19032']}
    Expenses:Health:Health Insurance                       ARS {salary_data['health_ins']}
    Expenses:Loans:Allaria                                 ARS {salary_data['loan_payment']}
    Expenses:Adjustments                                   ARS {salary_data['rounding']}
"""
    return entry

def main():
    """Función principal del script."""
    # Obtener la variable de entorno LEDGER_FILE
    ledger_file = os.environ.get('LEDGER_FILE')
    if not ledger_file:
        print("Error: LEDGER_FILE environment variable is not set.")
        print("Please set it to the path of your hledger journal file.")
        sys.exit(1)

    print("Automated Salary Recording for hledger")
    print(f"Journal file: {ledger_file}")
    print("\nEnter the following information (press Enter for defaults):")

    # Obtener fecha
    today = datetime.date.today()
    date_str = input(f"Date [YYYY-MM-DD] (default: {today.strftime('%Y-%m-%d')}): ")
    if not date_str:
        date_str = today.strftime("%Y-%m-%d")

    # Obtener periodo
    default_period = (today.replace(day=1) - datetime.timedelta(days=1)).strftime("%m/%Y")
    period = input(f"Period (default: {default_period}): ")
    if not period:
        period = default_period

    # Obtener departamento
    department = input("Department (default: ALLARIA): ")
    if not department:
        department = "ALLARIA"

    # Obtener salario bruto - ahora con el valor por defecto que pasaste
    gross_salary = input(f"Gross Salary (default: {DEFAULT_GROSS_SALARY}): ")
    if not gross_salary:
        gross_salary = DEFAULT_GROSS_SALARY

    # Obtener cuota de préstamo (opcional)
    loan_payment = input("Loan Payment (default: 17470.00): ")
    if not loan_payment:
        loan_payment = "17470.00"

    # Generar la entrada
    entry = generate_hledger_entry(date_str, period, department, gross_salary, loan_payment)

    # Mostrar la entrada generada
    print("\nGenerated hledger entry:")
    print("-" * 50)
    print(entry)
    print("-" * 50)

    # Preguntar si se debe agregar al archivo
    confirm = input("Add this entry to your journal file? (y/n): ")
    if confirm.lower() == 'y':
        with open(ledger_file, 'a') as f:
            f.write("\n" + entry + "\n")
        print(f"Entry added to {ledger_file}")
    else:
        print("Entry not added.")

if __name__ == "__main__":
    main()

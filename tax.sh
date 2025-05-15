#!/bin/bash

# Get user input
read -p "Enter total hours worked this month: " hours
read -p "Enter hourly pay rate (£): " rate
read -p "Enter pension contribution (%): " pension_percent

# Calculate gross monthly and annual income
gross_monthly=$(echo "$hours * $rate" | bc)
gross_annual=$(echo "$gross_monthly * 12" | bc)

# Pension contribution
pension_amount=$(echo "$gross_annual * $pension_percent / 100" | bc)
taxable_income=$(echo "$gross_annual - $pension_amount" | bc)

# ---- Income Tax Calculation (2024/25 UK) ----
# Personal allowance: £12,570
# Basic rate: 20% on £12,571 to £50,270
# Higher rate: 40% on £50,271 to £125,140
# Additional rate: ignored for simplicity

if (( $(echo "$taxable_income <= 12570" | bc -l) )); then
tax=0
elif (( $(echo "$taxable_income <= 50270" | bc -l) )); then
tax=$(echo "($taxable_income - 12570) * 0.2" | bc)
else
basic_tax=$(echo "(50270 - 12570) * 0.2" | bc)
higher_tax=$(echo "($taxable_income - 50270) * 0.4" | bc)
tax=$(echo "$basic_tax + $higher_tax" | bc)
fi

# ---- National Insurance (NI) Calculation (Class 1, 2024/25) ----
# Primary threshold: £12,570/year (~£1,048/month)
# 12% between £12,570 and £50,270
# 2% above £50,270

if (( $(echo "$gross_annual <= 12570" | bc -l) )); then
ni=0
elif (( $(echo "$gross_annual <= 50270" | bc -l) )); then
ni=$(echo "($gross_annual - 12570) * 0.12" | bc)
else
ni_basic=$(echo "(50270 - 12570) * 0.12" | bc)
ni_high=$(echo "($gross_annual - 50270) * 0.02" | bc)
ni=$(echo "$ni_basic + $ni_high" | bc)
fi

# Net income calculation
net_annual=$(echo "$gross_annual - $tax - $ni - $pension_amount" | bc)
net_monthly=$(echo "$net_annual / 12" | bc)

# ---- Output ----
echo ""
echo "---- Summary ----"
echo "Gross Monthly Income: £$gross_monthly"
echo "Gross Annual Income: £$gross_annual"
echo "Pension Contribution: £$pension_amount"
echo "Income Tax: £$tax"
echo "National Insurance: £$ni"
echo "Net Annual Income: £$net_annual"
echo "Net Monthly Income: £$net_monthly"

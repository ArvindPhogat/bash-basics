#!/bin/bash
# 04-variables.sh - Demonstrate variables in Bash

# Assign a value to a variable
a=10
b=20

# Print variable values
echo "Value of a: $a"
echo "Value of b: $b"

# Dynamic variable
today=$(date +%Y-%m-%d)
echo "Today's date is $today"

# Unset a variable
unset a
echo "Value of a after unset: $a"

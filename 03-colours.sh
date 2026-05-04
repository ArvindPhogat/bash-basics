#!/bin/bash
# 03-colours.sh - Bash script to demonstrate colored output

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
RESET='\033[0m'

# Print colored text

echo -e "${RED}This is RED${RESET}"
echo -e "${GREEN}This is GREEN${RESET}"
echo -e "${YELLOW}This is YELLOW${RESET}"
echo -e "${BLUE}This is BLUE${RESET}"
echo -e "${MAGENTA}This is MAGENTA${RESET}"
echo -e "${CYAN}This is CYAN${RESET}"

echo -e "${YELLOW}You can combine ${RED}multiple${RESET}${YELLOW} colors!${RESET}"

# Example: Print a warning message
echo -e "${YELLOW}Warning:${RESET} This is a warning message."

# Example: Print a success message
echo -e "${GREEN}Success:${RESET} Operation completed successfully."

# Example: Print an error message
echo -e "${RED}Error:${RESET} Something went wrong."

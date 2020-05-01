#!/usr/bin/env bash
# Environment variables SETUP_ROOT_DIR, OS_DIR and TEMP_DIR are available

[[ -z "$MARIADB_INTEREST" ]] && exit 0

echo -e "${COLOR_SECTION}*** Phalcon ***${TEXT_RESET}"

sudo apt-get install --quiet=2 mariadb-server mariadb-client

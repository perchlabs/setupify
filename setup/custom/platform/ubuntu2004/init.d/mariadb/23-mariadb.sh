#!/usr/bin/env bash
# Environment variables SETUP_DIR, CUSTOM_DIR, PLATFORM_DIR and TEMP_DIR are available

[[ -z "$MARIADB_INTEREST" ]] && exit 0

echo -e "${COLOR_SECTION}*** MariaDB ***${TEXT_RESET}"

sudo apt-get install --quiet=2 mariadb-server mariadb-client

# mariadb may not be automatically started, only enabled after package install.
systemctl -q is-active mariadb
[[ $? -ne 0 ]] && sudo systemctl restart mariadb

exit 0

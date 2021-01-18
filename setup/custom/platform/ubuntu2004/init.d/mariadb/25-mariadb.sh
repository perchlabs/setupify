#!/usr/bin/env bash
# Environment variables SETUP_DIR, CUSTOM_DIR, PLATFORM_DIR and TEMP_DIR are available

[[ -z "$MARIADB_INTEREST" ]] && exit 0

echo -e "${COLOR_SECTION}*** MariaDB ***${TEXT_RESET}"

# MariaDB 10.4+ has a new method to initialize the system
# using a sudo login through the local socket.

# Delete built in test tables.
sudo mysql --protocol=socket <<EOF
DELETE FROM mysql.db WHERE db LIKE 'tes%' AND user='';
EOF

# Delete annonymous users
sudo mysql --protocol=socket <<EOF
DROP USER IF EXISTS ''@'localhost';
DROP USER IF EXISTS ''@'$(hostname)';
EOF

if [[ ! -z "$MARIADB_ADMIN_USERNAME" && ! -z "$MARIADB_ADMIN_PASSWORD" ]]; then
  # Create root user and set the password.
  sudo mysql --protocol=socket <<EOF
  CREATE USER IF NOT EXISTS "$MARIADB_ADMIN_USERNAME"@'$MARIADB_HOST';
  ALTER USER "$MARIADB_ADMIN_USERNAME"@'$MARIADB_HOST' IDENTIFIED BY '$MARIADB_ADMIN_PASSWORD';
  GRANT ALL PRIVILEGES ON *.* TO "$MARIADB_ADMIN_USERNAME"@'$MARIADB_HOST';
EOF
fi

if [[ ! -z "$MARIADB_NORMAL_USERNAME" && ! -z "$MARIADB_NORMAL_PASSWORD" ]]; then
  # Create normal user and set the password.
  sudo mysql --protocol=socket <<EOF
  CREATE USER IF NOT EXISTS "$MARIADB_NORMAL_USERNAME"@'$MARIADB_HOST';
  ALTER USER "$MARIADB_NORMAL_USERNAME"@'$MARIADB_HOST' IDENTIFIED BY '$MARIADB_NORMAL_PASSWORD';
  GRANT ALL PRIVILEGES ON *.* TO "$MARIADB_NORMAL_USERNAME"@'$MARIADB_HOST';
EOF
fi

# Flush prilileges
sudo mysql --protocol=socket <<EOF
FLUSH PRIVILEGES;
EOF

if [[ ! -z "$MARIADB_DBNAME" && ! -z "$MARIADB_DUMP" ]]; then
  sudo mysqlshow --protocol=socket "$MARIADB_DBNAME" | grep "Database: ${MARIADB_DBNAME}" > /dev/null 2>&1
  if [[ "$?" -ne 0 ]]; then
    sudo mysql --protocol=socket -e "CREATE DATABASE IF NOT EXISTS $MARIADB_DBNAME"
    sudo mysql --protocol=socket "$MARIADB_DBNAME" < "$MARIADB_DUMP"
  fi
fi

exit 0

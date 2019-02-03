
PHP_VERSION=${PHP_VERSION:=7.2}
PHP_ETC=${PHP_ETC:=/etc/php/$PHP_VERSION}
DEBIAN_FRONTEND=${DEBIAN_FRONTEND:=noninteractive}

# Definitions to skip conf.d scripts. This belongs here because the skips
# are only used to skip portions or the entirety of a conf.d script.
# These can be deleted if you do not wish to use the menu functionality.
SKIPDEFS=(
  PACKAGES
  PECL
  PHALCON
  ZCOMPILER
  ZPARSER
)

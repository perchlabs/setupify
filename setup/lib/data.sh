
VERSION=0.1.0
ZPARSER_DEFAULT_VERSION=1.2.0
ZCOMPILER_DEFAULT_VERSION=0.11.9
PHALCON_DEFAULT_VERSION=3.4.2

# Install defaults
PHALCON_DEFAULT=repository:stable
ZPARSER_DEFAULT=tarball:$ZPARSER_DEFAULT_VERSION
ZCOMPILER_DEFAULT=phar:$ZCOMPILER_DEFAULT_VERSION

# Install
ZPARSER_INSTALL="${ZPARSER_INSTALL:=$ZPARSER_DEFAULT}"
ZCOMPILER_INSTALL="${ZCOMPILER_INSTALL:=$ZCOMPILER_DEFAULT}"
PHALCON_INSTALL="${PHALCON_INSTALL:=$PHALCON_DEFAULT}"

# PHP SAPI list, default is cli only.
PHP_SAPI_LIST="${PHP_SAPI_LIST:=cli}"

SOFTWARE_INSTALL_ROOT=${SOFTWARE_INSTALL_ROOT:=~/opt}

# Colorize provisioning.
COLOR_SECTION='\e[94m'
COLOR_NOTICE='\e[32m'
COLOR_ERROR='\e[91m'

###########################################################################
# This is the Menu data. Turn back unless you are either wise in your ways
# or drink too much. If you are both wise and drunk then your enemies shall
# will be crushed as you rejoice in the lamentation of their women.
###########################################################################

MENU_BACKTITLE="Perch Foundation Setupifier Menu v${VERSION}"

# Phalcon menu.
MENU_PHALCON_NAME=Phalcon
MENU_PHALCON_GIT_BRANCH_DEFAULT=3.4.x
MENU_PHALCON_GIT_URL_DEFAULT=https://github.com/phalcon/cphalcon.git
MENU_PHALCON_BRANCHES=https://github.com/phalcon/cphalcon/branches
MENU_PHALCON_VERSIONS=https://github.com/phalcon/cphalcon/releases
MENU_PHALCON_REPOSITORY_DEFAULT=stable
MENU_PHALCON_REPOSITORY_LIST="stable mainline nightly"
MENU_PHALCON_TARBALL_EXAMPLES="
  $PHALCON_DEFAULT_VERSION
  https://github.com/phalcon/cphalcon/archive/v${PHALCON_DEFAULT_VERSION}.tar.gz
  file://${HOME}/v${PHALCON_DEFAULT_VERSION}.tar.gz
"

# zephir_parser menu.
MENU_ZPARSER_NAME=zephir_parser
MENU_ZPARSER_GIT_BRANCH_DEFAULT=development
MENU_ZPARSER_GIT_URL_DEFAULT=https://github.com/phalcon/php-zephir-parser.git
MENU_ZPARSER_BRANCHES=https://github.com/phalcon/php-zephir-parser/branches
MENU_ZPARSER_VERSIONS=https://github.com/phalcon/php-zephir-parser/releases
MENU_ZPARSER_TARBALL_EXAMPLES="
  $ZPARSER_DEFAULT_VERSION
  https://github.com/phalcon/php-zephir-parser/archive/v${ZPARSER_DEFAULT_VERSION}.tar.gz
  file://${HOME}/v${ZPARSER_DEFAULT_VERSION}.tar.gz
"

# Zephir menu
MENU_ZCOMPILER_NAME=Zephir
MENU_ZCOMPILER_GIT_BRANCH_DEFAULT=development
MENU_ZCOMPILER_GIT_URL_DEFAULT=https://github.com/phalcon/zephir.git
MENU_ZCOMPILER_BRANCHES=https://github.com/phalcon/zephir/branches
MENU_ZCOMPILER_VERSIONS=https://github.com/phalcon/zephir/releases
MENU_ZCOMPILER_TARBALL_EXAMPLES="
  $ZCOMPILER_DEFAULT_VERSION
  https://github.com/phalcon/zephir/archive/v${ZCOMPILER_DEFAULT_VERSION}.tar.gz
  file://${HOME}/v${ZCOMPILER_DEFAULT_VERSION}.tar.gz
"
MENU_ZCOMPILER_PHAR_EXAMPLES="
  $ZCOMPILER_DEFAULT_VERSION
  https://github.com/phalcon/zephir/releases/download/${ZCOMPILER_DEFAULT_VERSION}/zephir.phar
  file://${HOME}/zephir.phar
"


MENU_BACKTITLE="Perch Foundation Setupifier Menu v${VERSION}"

# Nodejs menu.
MENU_NODEJS_NAME=Node.js
MENU_NODEJS_VERSIONS=https://github.com/nodejs/node/releases
MENU_NODEJS_REPOSITORY_DEFAULT=10
MENU_NODEJS_REPOSITORY_LIST="10 11"
MENU_NODEJS_TARBALL_EXAMPLES="
  $NODEJS_DEFAULT_VERSION
  https://github.com/nodejs/node/archive/v${NODEJS_DEFAULT_VERSION}.tar.gz
  file://${HOME}/v${NODEJS_DEFAULT_VERSION}.tar.gz
"

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


initCommon() {
  local osName=$1
  local shouldLoadInstallers=$2

  if [[ -z "$osName" ]]; then
    >&2 echo "An OS name must be specified for installation."
    >&2 echo "Possible OS names include:"
    >&2 ls -1 "$SETUP_ROOT_DIR/os"
    exit 1
  fi

  export OS_DIR="$SETUP_ROOT_DIR/os/$osName"
  if [[ ! -d "$OS_DIR" ]]; then
    >&2 echo "An installation directory does not exist for '$osName'."
    exit 1
  fi
  export TEMP_DIR=$(mktemp -d)

  # Reset all font settings
  export TEXT_RESET='\e[0m'

  # Automatically export the variables in these files.
  set -a
  source "$SETUP_ROOT_DIR/settings.sh"
  source "$LIB_DIR/data.sh"
  set +a

  [[ ! -z "$shouldLoadInstallers" ]] && loadInstallers

  set -a
  source "$OS_DIR/os.sh"
  set +a
}
export -f initCommon


loadInstallers() {
  set -a
  source "$LIB_DIR/data_installer.sh"
  set +a
}
export -f loadInstallers


clearInstallers() {
  local installVarList=$(compgen -v | grep -e '_INSTALLER$')
  local installVar

  set -a
  for installVar in $installVarList; do
    unset "$installVar"
  done
  set +a
}
export -f clearInstallers


startInstallation() {
  # Source OS functions
  local functions=$(find "$OS_DIR/functions" -maxdepth 1 -type f)
  local fscript
  for fscript in $functions; do
    source "$fscript"
  done

  # Find all of the files that begin with two digits and sort them.
  local scripts=$(find "$OS_DIR/conf.d" -maxdepth 1 -type f -name "[0-9][0-9]-*" | sort)
  local script
  for script in $scripts; do
    "$script"
    if [[ "$?" -ne 0 ]]; then
      >&2 echo -e "${COLOR_ERROR}ERROR${TEXT_RESET} in conf.d script ${script}"
      return 1
    fi
  done

  echo "All Installation resources are located at: $TEMP_DIR"
  printf "${COLOR_NOTICE}SUCCESS!\n${TEXT_RESET}"
}
export -f startInstallation


readlist() {
  echo $(grep -v -e '^#' -e '^$' "$OS_DIR/lists/$1")
}
export -f readlist


# Take only the first method field.
takeMethod() {
  [[ -z "$1" ]] && echo "" || echo "$1" | cut -d: -f1
}
export -f takeMethod


takeRef() {
  echo "$1" | cut -d: -f2-
}
export -f takeRef


# Take everything after the first field.
takeRefFirst() {
  echo "$1" | cut -d: -f2
}
export -f takeRefFirst


takeRefRest() {
  echo "$1" | cut -d: -f3-
}
export -f takeRefRest


function isUrl() {
  local ref=$1
  local regex='^[a-z]+://'
  [[ "$ref" =~ $regex ]];
  return $?
}
export -f isUrl

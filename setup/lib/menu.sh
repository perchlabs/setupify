
menuInit() {
  export DIALOG=$(which dialog whiptail 2> /dev/null | head -n 1)
  if [[ -z "$DIALOG" ]]; then
    >&2 echo "The dialog or whiptail command could not be found."
    exit 1
  fi

  export DIALOG_OK=0
  export DIALOG_CANCEL=1
  export DIALOG_ESC=255
}
export -f menuInit


menuOsname() {
  local osName=$1

  if [[ ! -z "$osName" ]]; then
    echo "$osName"
    exit 0
  fi

  local tag
  local pairs
  local osArr=($(ls -1 "$SETUP_ROOT_DIR/os"))
  for tag in ${osArr[@]}; do
    pairs="$pairs $tag $tag"
  done

  local numItems=${#osArr[@]}
  local totalLines=$(($numItems + 7))
  local option
  option=$("$DIALOG" \
    --backtitle "$MENU_BACKTITLE" \
    --title "Choose OS for provisioning" \
    --notags \
    --nocancel \
    --menu "Choose which OS to us for provisioning." $totalLines 70 $numItems \
      $pairs \
    3>&1 1>&2 2>&3)
  [[ $? -ne "$DIALOG_OK" ]] && return 1

  echo $option
}
export -f menuOsname


menuStart() {
  # Load menu data.
  set -a
  source "$LIB_DIR/menu_data.sh"
  set +a

  local menuCustomList
  local fileName
  local fileNames=$(find "$LIB_DIR"/menu/*.sh -printf "%f\n")
  for fileName in $fileNames; do
    source "$LIB_DIR/menu/$fileName"
    menuCustomList="$menuCustomList ${fileName%%.*}"
  done

  local choice
  while true; do
    choice=$(menuOverview)
    [[ $? -ne 0 ]] && return;

    case "$choice" in
      "install")
        startProvision
        break;
        ;;
      "customize")
        while true; do
          menuCustomize "$menuCustomList"
          [[ $? -ne 0 ]] && break;
        done
        ;;
      *)
        exit 0
        ;;
    esac
  done
}
export -f menuStart


menuOverview() {
  local status
  status=$(printInstallStatus)
  local statusLines=$?

  local msg
  read -r -d '' msg << EOM
Would you like to provision using the current settings?

$status
EOM

    local totalLines=$(($statusLines + 10))
    local option
    option=$("$DIALOG" \
      --backtitle "$MENU_BACKTITLE" \
      --title "Provision Overview" \
      --notags \
      --yes-button Install \
      --cancel-button Exit \
      --menu "$msg" $totalLines 110 2 \
        install Install \
        customize Customize \
    3>&1 1>&2 2>&3)
    [[ $? -ne "$DIALOG_OK" ]] && return 1
    echo $option
}
export -f menuOverview


menuCustomize() {
  local menuList="$1"

  local status
  status=$(printInstallStatus)
  local statusLines=$?

  local msg
  read -r -d '' msg << EOM
Choose which feature to customize.

$status
EOM

  local item
  local menuVar
  local pairs
  local tag
  for tag in $menuList; do
    menuVar="MENU_${tag^^}_NAME"
    [[ -z "${!menuVar}" ]] && item=$tag || item="${!menuVar}"
    pairs="$pairs $tag $item"
  done

  local itemArr=($menuList)
  local numItems=${#itemArr[@]}
  local totalLines=$(($statusLines + $numItems + 8))
  totalLines=$(($totalLines > 24 ? 24 : $totalLines))
  local option
  option=$("$DIALOG" \
    --backtitle "$MENU_BACKTITLE" \
    --title "Customize Provision" \
    --notags \
    --cancel-button "Return to Overview" \
    --menu "$msg" $totalLines 110 $numItems \
      $pairs \
    3>&1 1>&2 2>&3)
  [[ $? -ne "$DIALOG_OK" ]] && return 1
  "menu_${option}"
}
export -f menuCustomize


printInstallStatus() {
  local installArr=($(compgen -v | grep -e '_INSTALL$'))
  local nameArr=()
  local regex='(.+)_INSTALL$'

  local installVar
  local maxLen=0
  local len
  local name
  for installVar in ${installArr[@]}; do
    [[ "$installVar" =~ $regex ]] && name=${BASH_REMATCH[1]}
    nameArr+=($name)
    len=${#name}
    maxLen=$(( len > maxLen ? len : maxLen ))
  done

  # Print PHP version
  printf "%${maxLen}s" PHP
  echo ": $PHP_VERSION"

  for i in ${!nameArr[@]}; do
    installVar=${installArr[$i]}
    name=${nameArr[$i]}

    printf "%${maxLen}s" $name
    printf ": "
    [[ -z "${!installVar}" ]] && echo "---" || echo "${!installVar}"
  done

  # Return the number of status lines
  local installCount=${#installArr[@]}
  return $((installCount + 1))
}
export -f printInstallStatus


menuTarball() {
  local project=$1

  local installVar=${project}_INSTALL
  local nameVar=MENU_${project}_NAME
  local versionsVar=MENU_${project}_VERSIONS
  local examplesVar=MENU_${project}_TARBALL_EXAMPLES
  local defaultVersionVar=${project}_DEFAULT_VERSION

  local msg="
Enter either an official ${!nameVar} release version or the URL of a ${!nameVar} tarball.

See ${!versionsVar}

Examples; ${!examplesVar}
"

  # If the installation method was something other than this
  # then the defaults for this method will need to be used instead.
  local method=$(takeMethod "${!installVar}")
  [[ "$method" = tarball ]] && local ref=$(takeRef "${!installVar}") || local ref=${!defaultVersionVar}

  local numExamples=$(echo -n "${!examplesVar}" | grep -c '^')
  local totalLines=$(($numExamples + 12))
  local input
  input=$("$DIALOG" \
    --backtitle "$MENU_BACKTITLE" \
    --title "Choose ${!nameVar} version or tarball URL" \
    --inputbox "$msg" $totalLines 110 \
      "$ref" \
      3>&1 1>&2 2>&3)
  [[ $? -ne "$DIALOG_OK" ]] && return 1

  # Trim whitespace
  input="${input#"${input%%[![:space:]]*}"}"
  input="${input%"${input##*[![:space:]]}"}"
  # Don't allow empty input
  [[ -z "$input" ]] && return 1

  echo "$input"
}
export -f menuTarball


menuGit() {
  local project=$1

  local url
  url=$(menuGitUrl "$project")
  [[ $? -ne 0 ]] && return 1

  local branch
  branch=$(menuGitBranch "$project")
  [[ $? -ne 0 ]] && return 1

  echo "${branch}:${url}"
}
export -f menuGit


menuGitUrl() {
  local project=$1

  local installVar=${project}_INSTALL
  local nameVar=MENU_${project}_NAME
  local defaultUrlVar=MENU_${project}_GIT_URL_DEFAULT

  local msg="
Enter a ${!nameVar} git URL.

Examples;
  ${!defaultUrlVar}
"

  # If the installation method was something other than this
  # then the defaults for this method will need to be used instead.
  local method=$(takeMethod "${!installVar}")
  if [[ "$method" = git ]]; then
    local url=$(takeRefRest "${!installVar}")
  else
    local url=${!defaultUrlVar}
  fi

  local input
  input=$("$DIALOG" \
    --backtitle "$MENU_BACKTITLE" \
    --title "Choose ${!nameVar} git URL" \
    --inputbox "$msg" 13 110 \
      "$url" \
      3>&1 1>&2 2>&3)
  [[ $? -ne "$DIALOG_OK" ]] && return 1

  # Trim whitespace
  input="${input#"${input%%[![:space:]]*}"}"
  input="${input%"${input##*[![:space:]]}"}"
  # Don't allow empty input
  [[ -z "$input" ]] && return 1

  echo "$input"
}
export -f menuGitUrl


menuGitBranch() {
  local project=$1

  local installVar=${project}_INSTALL
  local nameVar=MENU_${project}_NAME
  local branchesVar=MENU_${project}_BRANCHES
  local defaultBranchVar=MENU_${project}_GIT_BRANCH_DEFAULT

  local msg="
Enter a ${!nameVar} git branch.

See ${!branchesVar}

Examples;
  ${!defaultBranchVar}
"

  # If the installation method was something other than this
  # then the defaults for this method will need to be used instead.
  local method=$(takeMethod "${!installVar}")
  if [[ "$method" = git ]]; then
    local branch=$(takeRefFirst "${!installVar}")
  else
    local branch=${!defaultBranchVar}
  fi

  local input
  input=$("$DIALOG" \
    --backtitle "$MENU_BACKTITLE" \
    --title "Choose ${!nameVar} git branch" \
    --inputbox "$msg" 15 100 \
      "$branch" \
      3>&1 1>&2 2>&3)
  [[ $? -ne "$DIALOG_OK" ]] && return 1

  # Trim whitespace
  input="${input#"${input%%[![:space:]]*}"}"
  input="${input%"${input##*[![:space:]]}"}"
  # Don't allow empty input
  [[ -z "$input" ]] && return 1

  echo "$input"
}
export -f menuGitBranch


menuRepository() {
  local project=$1

  local installVar=${project}_INSTALL
  local nameVar=MENU_${project}_NAME
  local repositoryDefaultVar=MENU_${project}_REPOSITORY_DEFAULT
  local repositoriesVar=MENU_${project}_REPOSITORY_LIST

  # If the installation method was something other than this
  # then the defaults for this method will need to be used instead.
  local method=$(takeMethod "${!installVar}")
  if [[ "$method" = repository ]]; then
    local ref=$(takeRef "${!installVar}")
  else
    local ref=${!repositoryDefaultVar}
  fi

  local repositoriesArr=(${!repositoriesVar})
  local pairs
  local repository
  for repository in ${repositoriesArr[@]}; do
    pairs="$pairs $repository $repository"
  done

  local numRepositories=${#repositoriesArr[@]}
  local totalLines=$(($numRepositories + 7))
  local option
  option=$("$DIALOG" \
    --backtitle "$MENU_BACKTITLE" \
    --title "Choose ${!nameVar} Repository" \
    --notags \
    --default-item $ref \
    --menu "Choose the ${!nameVar} repository for system packages." $totalLines 75 $numRepositories \
      $pairs \
      3>&1 1>&2 2>&3)
  [[ $? -ne "$DIALOG_OK" ]] && return 1

  echo "$option"
}
export -f menuRepository


menuPhar() {
  local project=$1

  local installVar=${project}_INSTALL
  local nameVar=MENU_${project}_NAME
  local versionsVar=MENU_${project}_VERSIONS
  local examplesVar=MENU_${project}_PHAR_EXAMPLES
  local defaultVersionVar=${project}_DEFAULT_VERSION

  local msg
  read -r -d '' msg << EOM
Enter either an official ${!nameVar} release version or the URL of a ${!nameVar} phar.

See ${!versionsVar}

Examples; ${!examplesVar}
EOM

  # If the installation method was something other than this
  # then the defaults for this method will need to be used instead.
  local method=$(takeMethod "${!installVar}")
  [[ "$method" = phar ]] && local ref=$(takeRef "${!installVar}") || local ref=${!defaultVersionVar}

  local numExamples=$(echo -n "${!examplesVar}" | grep -c '^')
  local totalLines=$(($numExamples + 11))
  local input
  input=$("$DIALOG" \
    --backtitle "$MENU_BACKTITLE" \
    --title "Choose ${!nameVar} version" \
    --cancel-button "Return to Customize" \
    --inputbox "$msg" $totalLines 110 \
      "$ref" \
      3>&1 1>&2 2>&3)
  ret=$?
  [[ $ret -ne "$DIALOG_OK" ]] && return 1

  # Trim whitespace
  input="${input#"${input%%[![:space:]]*}"}"
  input="${input%"${input##*[![:space:]]}"}"
  # Don't allow empty input
  [[ -z "$input" ]] && return 1

  echo "$input"
  return 0
}
export -f menuPhar

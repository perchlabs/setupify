
menuInit() {
  export DIALOG=$(which dialog whiptail 2> /dev/null | head -n 1)
  # export DIALOG=$(which whiptail dialog 2> /dev/null | head -n 1)
  if [[ -z "$DIALOG" ]]; then
    >&2 echo "The dialog or whiptail command could not be found."
    exit 1
  fi

  export DIALOG_OK=0
  export DIALOG_CANCEL=1
  export DIALOG_ESC=255

  local sectionName
  local sectionNames=$(getSectionNames)

  # Load menu data.
  set -a
    local sectionPathFrags=$(getSectionPathFrags)
    local sectionPathFrag
    for sectionPathFrag in $sectionPathFrags; do
      local sectionName=$(basename $sectionPathFrag)
      local sectionDataPath="$SETUP_ROOT_DIR/${sectionPathFrag}/menu_${sectionName}.sh"
      if [[ -f "$sectionDataPath" ]]; then
        source "$sectionDataPath"
      fi
    done
  set +a
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
    --title "Choose OS for installation" \
    --notags \
    --nocancel \
    --menu "Choose which OS to us for installation." $totalLines 70 $numItems \
      $pairs \
    3>&1 1>&2 2>&3)
  [[ $? -ne "$DIALOG_OK" ]] && return 1

  echo $option
}
export -f menuOsname


menuStart() {
  local choice
  while true; do
    choice=$(menuOverview)
    [[ $? -ne 0 ]] && return;

    case "$choice" in
      "proceed")
        startInstallation
        break;
        ;;
      "sections")
        menuSections
        ;;
      "interests")
        menuInterests
        ;;
      "load_installers")
        loadInstallers
        enableAllInterests
        ;;
      "clear_installers")
        clearInstallers
        disableAllInterests
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
  status=$(printInstallerStatus)
  local statusLines=$?

  local msg
  read -r -d '' msg << EOM
Would you like to install using the current settings?

$status
EOM

    local totalLines=$(($statusLines + 13))
    local option
    option=$("$DIALOG" \
      --backtitle "$MENU_BACKTITLE" \
      --title "Installation Overview" \
      --notags \
      --ok-button Ok \
      --cancel-button Exit \
      --menu "$msg" $totalLines 110 5 \
        proceed Proceed \
        sections Sections \
        interests Interests \
        load_installers '** Load everything **' \
        clear_installers '** Clear everything **' \
    3>&1 1>&2 2>&3)
    [[ $? -ne "$DIALOG_OK" ]] && return 1
    echo $option
}
export -f menuOverview


menuInterests() {
  local interestName
  local interestStatus
  local interestVar

  # Create an array of all enabled interests.
  local interestNameArr=()
  local interestVarList=$(compgen -v | grep -E '^[A-Z]+_INTEREST$')
  local regex='^(.+)_INTEREST$'
  for interestVar in $interestVarList; do
    [[ "$interestVar" =~ $regex ]] && interestNameArr+=(${BASH_REMATCH[1]})
  done

  # Create the triplet tuples for the checklist dialog.
  local triples
  for interestName in ${interestNameArr[*]}; do
    interestVar="${interestName}_INTEREST"
    [[ -z "${!interestVar}" ]] && interestStatus=off || interestStatus=on
    triples="$triples $interestName $interestName $interestStatus"
  done

  local numInterests=${#interestNameArr[@]}
  local totalLines=$(($numInterests > 12 ? 20 : $numInterests + 7))
  local checks
  checks=$("$DIALOG" \
    --backtitle "$MENU_BACKTITLE" \
    --title "Choose steps of interest" \
    --notags \
    --ok-button "Ok" \
    --nocancel \
    --checklist "Choose the provision steps of interest." $totalLines 70 $numInterests \
    $triples \
    3>&1 1>&2 2>&3)
  [[ $? -ne "$DIALOG_OK" ]] && return 1

  # First assume that all interests are disabled.
  local -A interestMap
  for interestName in ${interestNameArr[*]}; do
    interestMap["${interestName}_INTEREST"]=off
  done

  # Next turn on interests that were checked.
  for interestName in $checks; do
    # Clean quotes from whiptail (dialog behaves differently)
    interestName="${interestName%\"}"
    interestName="${interestName#\"}"

    interestMap["${interestName}_INTEREST"]=on
  done

  # Set the new interest values.
  local newInterest
  for interestVar in ${!interestMap[@]}; do
    local interestVal=${interestMap[$interestVar]}
    [[ "$interestVal" = on ]] && newInterest=1 || newInterest=''
    declare -g "$interestVar"="$newInterest"
  done
}
export -f menuInterests


menuSections() {
  while true; do
  _menuSections
    [[ $? -ne 0 ]] && break;
  done
}
export -f menuSections


_menuSections() {
  local sectionList="$(getSectionNames)"

  local status
  status=$(printInstallerStatus)
  local statusLines=$?

  local msg
  read -r -d '' msg << EOM
Choose which section to customize.

$status
EOM

  local item
  local menuVar
  local pairs
  local tag
  for tag in $sectionList; do
    menuVar="MENU_${tag^^}_NAME"
    [[ -z "${!menuVar}" ]] && item=$tag || item="${!menuVar}"
    pairs="$pairs $tag $item"
  done

  local itemArr=($sectionList)
  local numItems=${#itemArr[@]}
  local totalLines=$(($statusLines + $numItems + 9))
  totalLines=$(($totalLines > 24 ? 24 : $totalLines))
  local option
  option=$("$DIALOG" \
    --backtitle "$MENU_BACKTITLE" \
    --title "Customize Sections" \
    --notags \
    --cancel-button "Return to Overview" \
    --menu "$msg" $totalLines 110 $numItems \
      $pairs \
    3>&1 1>&2 2>&3)
  [[ $? -ne "$DIALOG_OK" ]] && return 1

  set -a
  "menu_${option}"
  set +a
}


printInstallerStatus() {
  local installerArr=($(compgen -v | grep -E '[A-Z]+_INSTALLER$'))
  local installerCount=${#installerArr[@]}
  local nameArr=()
  local regex='(.+)_INSTALLER$'

  local installerVar
  local maxLen=0
  local len
  local name
  for installerVar in ${installerArr[@]}; do
    [[ "$installerVar" =~ $regex ]] && name=${BASH_REMATCH[1]}
    nameArr+=($name)
    len=${#name}
    maxLen=$(( len > maxLen ? len : maxLen ))
  done

  # Print PHP version
  printf "%${maxLen}s" PHP
  echo ": $PHP_VERSION"

  let outputLineCount=$((installerCount + 1))

  if [[ "$installerCount" -eq 0 ]]; then
    outputLineCount=$((outputLineCount + 1))
    echo "No installers are configured"
  else
    for i in ${!nameArr[@]}; do
      installerVar=${installerArr[$i]}
      name=${nameArr[$i]}

      printf "%${maxLen}s" $name
      printf ": "
      [[ -z "${!installerVar}" ]] && echo "---" || echo "${!installerVar}"
    done
  fi

  # Return the number of status lines
  return $outputLineCount
}
export -f printInstallerStatus




menuPecl() {
  local project=$1
  local installer=$2

  local nameVar=MENU_${project}_NAME
  local versionsVar=MENU_${project}_VERSIONS
  local defaultVersionVar=${project}_DEFAULT_VERSION

  local msg="
Enter an official ${!nameVar} release version.

See ${!versionsVar}
"

  # If the installation method was something other than this
  # then the defaults for this method will need to be used instead.
  local method=$(takeMethod "$installer")
  [[ "$method" = tarball ]] && local ref=$(takeRef "$installer") || local ref="${!defaultVersionVar}"

  local totalLines=12
  local input
  input=$("$DIALOG" \
    --backtitle "$MENU_BACKTITLE" \
    --title "Choose ${!nameVar} version" \
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
export -f menuPecl


menuTarball() {
  local project=$1
  local installer=$2

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
  local method=$(takeMethod "$installer")
  [[ "$method" = tarball ]] && local ref=$(takeRef "$installer") || local ref="${!defaultVersionVar}"

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
  local installer=$2

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
  local installer=$2

  local nameVar=MENU_${project}_NAME
  local defaultUrlVar=MENU_${project}_GIT_URL_DEFAULT

  local msg="
Enter a ${!nameVar} git URL.

Examples;
  ${!defaultUrlVar}
"

  # If the installation method was something other than this
  # then the defaults for this method will need to be used instead.
  local method=$(takeMethod "$installer")
  if [[ "$method" = git ]]; then
    local url=$(takeRefRest "$installer")
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
  local installer=$2

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
  local method=$(takeMethod "$installer")
  if [[ "$method" = git ]]; then
    local branch=$(takeRefFirst "$installer")
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
  local installer=$2

  local nameVar=MENU_${project}_NAME
  local repositoryDefaultVar=MENU_${project}_REPOSITORY_DEFAULT
  local repositoriesVar=MENU_${project}_REPOSITORY_LIST

  # If the installation method was something other than this
  # then the defaults for this method will need to be used instead.
  local method=$(takeMethod "$installer")
  if [[ "$method" = repository ]]; then
    local ref=$(takeRef "$installer")
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
  local installer=$2

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
  local method=$(takeMethod "$installer")
  [[ "$method" = phar ]] && local ref=$(takeRef "$installer") || local ref="${!defaultVersionVar}"

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

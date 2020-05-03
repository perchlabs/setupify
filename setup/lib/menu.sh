
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

  # Load menu resources.
  set -a
    local menuFiles=$(ls "$LIB_DIR/menu")
    local menuFile
    for menuFile in $menuFiles; do
      local menuFilePath="$LIB_DIR/menu/$menuFile"
      source "$menuFilePath"
    done

    local sectionPathFrags=$(getSectionPathFrags)
    local sectionPathFrag
    for sectionPathFrag in $sectionPathFrags; do
      local sectionName=$(basename $sectionPathFrag)
      local sectionDataPath="$SETUP_ROOT_DIR/${sectionPathFrag}/menu_${sectionName}.sh"
      [[ -f "$sectionDataPath" ]] && source "$sectionDataPath"
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
  status=$(printMenuStatus)
  local statusLines=$?

  local msg
  read -r -d '' msg << EOM
Would you like to install using the current settings?

$status
EOM

  local totalLines=$(($statusLines + 14))
  local option
  option=$("$DIALOG" \
    --backtitle "$MENU_BACKTITLE" \
    --title "Installation Overview" \
    --notags \
    --ok-button Ok \
    --cancel-button Exit \
    --menu "$msg" $totalLines 110 5 \
      proceed Proceed \
      interests Interests \
      sections Sections \
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
  status=$(printMenuStatus)
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


printMenuStatus() {
  printMenuInterestStatus
  local interestStatusLines=$?

  printMenuInstallerStatusLines
  local installerStatusLines=$?

  local outputLineCount=$((interestStatusLines + installerStatusLines))

  # Return the number of status lines
  return $outputLineCount
}
export -f printMenuStatus


printMenuInterestStatus() {
  local interestArr=($(compgen -v | grep -E '[A-Z]+_INTEREST$'))
  local regex='(.+)_INTEREST$'

  local interestVar
  local name
  local nameArr=()
  for interestVar in ${interestArr[@]}; do
    [[ "$interestVar" =~ $regex ]] && name=${BASH_REMATCH[1]}
    [[ ! -z "${!interestVar}" ]] && nameArr+=($name)
  done

  if [[ ${#nameArr[@]} -eq 0 ]]; then
    printf "No interests have been enabled"
  else
    printf "INTERESTS:"
    for i in ${!nameArr[@]}; do
      interestVar=${interestArr[$i]}
      name=${nameArr[$i]}
      printf " $name"
    done
  fi

  printf "\n"

  return 1
}
export -f printMenuInterestStatus


printMenuInstallerStatusLines() {
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

  local outputLineCount=$((installerCount))

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

  # Return the number of installer lines
  return $outputLineCount
}
export -f printMenuInstallerStatusLines

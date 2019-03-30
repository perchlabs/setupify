
menu_interests() {
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

  local numSkips=${#interestNameArr[@]}
  local totalLines=$(($numSkips > 12 ? 20 : $numSkips + 7))
  local checks
  checks=$("$DIALOG" \
    --backtitle "$MENU_BACKTITLE" \
    --title "Choose steps of interest" \
    --notags \
    --ok-button "Ok" \
    --cancel-button "Return to Customize" \
    --checklist "Choose the provision steps of interest." $totalLines 70 $numSkips \
    $triples \
    3>&1 1>&2 2>&3)
  [[ $? -ne "$DIALOG_OK" ]] && return 0

  # First assume that all interests are disabled.
  local -A interestMap
  for interestName in ${interestNameArr[*]}; do
    # Clean quotes from whiptail (dialog behaves differently)
    interestName=${interestName//\"}
    interestMap["${interestName}_INTEREST"]=off
  done

  # Next turn on interests that were checked.
  for interestName in $checks; do
    interestMap["${interestName}_INTEREST"]=on
  done

  # Set the new interest values.
  for interestVar in ${!interestMap[@]}; do
    local interestVal=${interestMap[$interestVar]}
    [[ "$interestVal" = on ]] && local newSkip=1 || local newSkip=''
    declare -g $interestVar=$newSkip
  done
}
export -f menu_interests


menu_skips() {
  local skipName
  local skipStatus
  local skipVar

  # First define skips using default values to preserve
  # existing values.
  for skipName in ${SKIPDEFS[@]}; do
    skipVar=SKIP_$skipName
    declare -g $skipVar=${!skipVar:=}
    export "$skipVar"
  done

  # Create an array of all set skips.
  local skipNameArr=()
  local skipVarList=$(compgen -v | grep -E '^SKIP_[A-Z]+$')
  local regex='^SKIP_(.+)$'
  for skipVar in $skipVarList; do
    [[ "$skipVar" =~ $regex ]] && skipNameArr+=($BASH_REMATCH[1])
  done

  # Create the triplet tuples for the checklist dialog.
  local triples
  for skipName in ${skipNameArr[*]}; do
    skipVar=SKIP_$skipName
    [[ -z "${!skipVar}" ]] && skipStatus=off || skipStatus=on
    triples="$triples $skipName $skipName $skipStatus"
  done

  local numSkips=${#skipNameArr[@]}
  local totalLines=$(($numSkips > 12 ? 20 : $numSkips + 7))
  local checks
  checks=$("$DIALOG" \
    --backtitle "$MENU_BACKTITLE" \
    --title "Skip Provision Steps" \
    --notags \
    --ok-button "Ok" \
    --cancel-button "Return to Customize" \
    --checklist "Choose provision features to skip." $totalLines 70 $numSkips \
    $triples \
    3>&1 1>&2 2>&3)
  [[ $? -ne "$DIALOG_OK" ]] && return 0

  # First assume that all skips are off.
  local -A skipMap
  for skipName in ${skipNameArr[*]}; do
    # Clean quotes from whiptail (dialog behaves differently)
    skipName=${skipName//\"}
    skipMap["SKIP_$skipName"]=off
  done

  # Next turn on skips that were checked.
  for skipName in $checks; do
    skipMap["SKIP_$skipName"]=on
  done

  # Set the new skip values.
  for skipVar in ${!skipMap[@]}; do
    local skipVal=${skipMap[$skipVar]}
    [[ "$skipVal" = on ]] && local newSkip=1 || local newSkip=''
    declare -g $skipVar=$newSkip
  done
}
export -f menu_skips


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

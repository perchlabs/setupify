
menuInstallers() {
  while true; do
  _menuInstaller
    [[ $? -ne 0 ]] && break;
  done
}
export -f menuInstallers


_menuInstallers() {
  local menuList="$(getSectionNames)"

  local status
  status=$(printInstallerStatus)
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
  local totalLines=$(($statusLines + $numItems + 9))
  totalLines=$(($totalLines > 24 ? 24 : $totalLines))
  local option
  option=$("$DIALOG" \
    --backtitle "$MENU_BACKTITLE" \
    --title "Customize Installers" \
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

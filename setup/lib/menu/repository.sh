
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

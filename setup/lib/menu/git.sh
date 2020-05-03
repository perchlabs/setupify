
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

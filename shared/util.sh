#!/usr/bin/env bash

deploy() {
  local dir="$1"

  if [[ -d "$dir" ]]; then
    status "\u00b7 Deploying $dir" && echo
    terraform -chdir="$dir" init
    terraform -chdir="$dir" plan
    if [[ "$TFLAG" -eq 1 ]]; then
      status "Skipping terraform apply" && ok
    else
      terraform -chdir="$dir" apply --auto-approve
      status "Done" && ok
    fi
  else
    { error "Error: Directory [$dir] does not exist."; exit 1; }
  fi
}

error() { echo -e >&2 "$@ \e[31;1m\u2717\e[0m"; }

must_have() {
    for cmd in $*; do
        command -v $cmd >/dev/null 2>&1 || { error "$cmd command is required but not installed"; exit 1; }
    done
}

ok() {
    [[ "$@" != "" ]] && echo -n "$@ "
    echo -e "\e[32;1m\u2713\e[0m"
}

recurse_directories() {
  local do=$1
  local dir="$2"

  if [[ -d "$dir" ]]; then
    for sub_dir in "$dir"/*; do
      if [[ -d "$sub_dir" ]]; then
        $do "$sub_dir"
      fi
    done
  else
    echo "Error: Directory '$dir' does not exist."
    exit 1
  fi
}

status() { echo -ne "\e[37;1m$@: \e[0m"; }

test_aws() {
    aws eks list-clusters > /dev/null 2>&1

    return $?
}

warn() { echo -e "$@ \e[33;1m\u26a0\e[0m"; }
#!/bin/bash
# exit when any command fails
set -e

replace_env_vars() {
  while IFS= read -r configFile; do
    echo "replacing environment variables"
    echo "$configFile"
    while IFS= read -r envVar; do
      IFS='=' read -r key envValue <<<"$envVar"
      if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i "" "s|\${$key}|$envValue|g" "${3}/${configFile}"
      else
        sed -i "s|\${$key}|$envValue|g" "${3}/${configFile}"
      fi
    done <"$2"
  done <"$1"
}

copy_files() {
  IFS=$'\n'
  set -f
  source=$1
  destinationDirectory=$2
  for file in $(find "$source" -name '*.*'); do
    if [[ -f "$file" ]]; then

      fileDestination=${file#$source}
      echo "File destination $fileDestination"
      newdestination="${destinationDirectory}${fileDestination}"
      echo $newdestination

      mkdir -p "$(dirname "$newdestination")"

      if test -f "$newdestination"; then
        if ! cmp "${file}" "$newdestination" >/dev/null 2>&1; then
          echo "$file"
          echo "Existing file but changed, overwriting file"
          rm -f "$newdestination"
          cp -r "${file}" "$newdestination"
          counter=$(($counter + 1))
        fi
      else
        echo "$file"
        cp -r "${file}" "$newdestination"
        counter=$(($counter + 1))
        echo "new file copied to dist"
      fi
    fi
  done
  unset IFS
  set +f
  echo "Copying finished: $counter files copied"
}

copy_src_files() {
  shopt -s globstar
  echo "Copying started. This might take some time."
  counter=0
  destinationDirectory=${1:-server_dist}
  mkdir -p "$destinationDirectory"/plugins

  find "${destinationDirectory}"/plugins -maxdepth 1 -type f -name "*" | while read file; do
    echo "checking file for deletion ${file}"
    pluginFile="${file##*/}"
    printf -v quotedFile '%q' "$pluginFile"
    if [[ ! -f "./server_source/plugins/${pluginFile}" ]]; then
      echo "./server_source/plugins/${pluginFile}"
      echo "Jar file not present anymore in repository. Deleting file"
      echo "$pluginFile"
      rm "$file"
    fi
  done
  copy_files "./server_source" "$destinationDirectory"
}

start_server() {

  input=".envfiles"
  envVars=".env"

  case "$(uname -s)" in

  Darwin | Linux)
    echo "Running on unix"
    replace_env_vars "$input" "$envVars" "server_dist"
    ;;

  CYGWIN* | MINGW32* | MSYS* | MINGW*)
    echo "Running on Windows"
    c:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -noprofile -executionpolicy bypass ./build/replace_env_vars "$input" "$envVars" "server_dist"
    ;;
  esac

  cd server_dist && java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005 -jar server.jar
}

deploy() {
  input=".envfiles"
  envVars="${2}/.env"

  CHANGED=$(git status --porcelain)
  if [ -n "${CHANGED}" ]; then
    printf 'Some files have been changed that are not part of the .gitignore file. Manual action is required to rectify the situation.\nFollowing files have changed:\n'
    echo "${CHANGED}"
  else
    git fetch --all --tags
    git checkout $1
    TAG=$(git rev-parse --abbrev-ref HEAD)
    if [[ $TAG == master* ]] || [[ $TAG == hotfix* ]] || [[ $TAG == epic* ]] || [[ $TAG == release* ]]; then
      echo 'Currently on branch. Pulling updates'
      git pull
    fi
    copy_src_files "$2"
    # Assuming we are on the master branch we pull the latest changes.
    replace_env_vars $input $envVars "$2"
  fi
}

if [ "$1" = "deploy" ]; then
  shift
  deploy "$@"
elif [ "$1" = "run" ]; then
  shift
  start_server "$@"
elif [ "$1" = "copy" ]; then
  shift
  copy_src_files "$@"
fi

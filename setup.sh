#!/usr/bin/env bash
VERSION="1.3.0"
TAG=${TAG:-$VERSION}
BRANCH=${BRANCH:-$TAG}
REMOTE=${REMOTE:-https://github.com/garagepoort/mc-server-deployments.git}
TMPDIR=${TMPDIR:-/tmp}
DEST=${DEST:-$TMPDIR/mc-server-deployments-$BRANCH}

## test if command exists
ftest () {
  echo "  info: Checking for $1..."
  if ! type -f "$1" > /dev/null 2>&1; then
    return 1
  else
    return 0
  fi
}

## feature tests
features () {
  for f in "${@}"; do
    ftest "$f" || {
      echo >&2 "  error: Missing \`$f'! Make sure it exists and try again."
      return 1
    }
  done
  return 0
}

## main setup
setup () {
  echo "  info: Welcome to the 'mc-server-deployments' installer!"
  ## test for require features
  features git || return $?

  ## build
  {
    echo
    echo "  info: Creating temporary files..."
    cd "$TMPDIR" || exit
    test -d "$DEST" && { echo "  warn: Already exists: '$DEST'"; }
    rm -rf "$DEST"

    echo "  info: Fetching 'mc-server-deployments@$BRANCH'..."
    git clone --depth=1 --branch "$BRANCH" "$REMOTE" "$DEST" > /dev/null 2>&1
    cd "$DEST" || exit

    echo "  info: Installing..."
    echo
    make_install
    echo "  info: Done!"
  } >&2
  return $?
}

## make targets
BIN="mcsd"
if [ -z "$PREFIX" ]; then
  if [ "$(whoami)" == "root" ]; then
    PREFIX="/usr/local"
  else
    PREFIX="$HOME/.local"
  fi
fi

# All 'mc-server-deployments' supported commands
declare -a CMDS=()
CMDS+=("run")
CMDS+=("deploy")
CMDS+=("copy")

make_install () {
  local source

  ## do 'make uninstall'
  make_uninstall

  echo "  info: Installing $PREFIX/bin/$BIN..."
  install -d "$PREFIX/bin"
  source=$(<$BIN)

  if [ -f "$source" ]; then
    install "$source" "$PREFIX/bin/$BIN"
  else
    install "$BIN" "$PREFIX/bin"
  fi

  for cmd in "${CMDS[@]}"; do
    if test -f "$BIN-$cmd"; then
      source=$(<"$BIN-$cmd")

      if [ -f "$source" ]; then
        install "$source" "$PREFIX/bin/$BIN-$cmd"
      else
        install "$BIN-$cmd" "$PREFIX/bin"
      fi
    fi

  done
  return $?
}

make_uninstall () {
  echo "  info: Uninstalling $PREFIX/bin/$BIN*"
  echo "    rm: $PREFIX/bin/$BIN'"
  rm -f "$PREFIX/bin/$BIN"
  for cmd in "${CMDS[@]}"; do
    if test -f "$PREFIX/bin/$BIN-$cmd"; then
      echo "    rm: $PREFIX/bin/$BIN-$cmd'"
      rm -f "$PREFIX/bin/$BIN-$cmd"
    fi
  done
  return $?
}

make_link () {
  make_uninstall
  echo "  info: Linking $PREFIX/bin/$BIN*"
  echo "  link: '$PWD/$BIN' -> '$PREFIX/bin/$BIN'"
  ln -s "$PWD/$BIN" "$PREFIX/bin/$BIN"
  for cmd in "${CMDS[@]}"; do
    if test -f "$PWD/$BIN-$cmd"; then
      echo "  link: '$PWD/$BIN-$cmd' -> '$PREFIX/bin/$BIN-$cmd'"
      ln -s "$PWD/$BIN-$cmd" "$PREFIX/bin/$BIN-$cmd"
    fi
  done
  return $?
}

make_unlink () {
  make_uninstall
}

## do setup or `make_{install|uninstall|link|unlink}` command
if [ $# -eq 0 ]; then
  setup
else
  "make_$1"
fi

exit $?

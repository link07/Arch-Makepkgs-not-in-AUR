#!/bin/sh

export WINEDEBUG="fixme-all $WINEDBEUG"

if [ -z ${WINEPREFIX+x} ]; then
    export WINEPREFIX="$HOME/.wine"
fi

wine "$WINEPREFIX"/drive_c/"Program\ Files\ \(x86\)"/Steam/steamapps/common/"Path\ of\ Exile"/PathOfExileSteam.exe -gc 100 &>/dev/null & disown

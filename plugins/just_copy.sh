#!/usr/bin/env bash

# Not tested. Report bugs 
t_skf_gen () {
    echo "You are using an untested plugin. Please report bugs "
    echo "to moebiuseye <moebiuseye@jeannedhack.org>"
    
    rm -rf "$DST"
    if command -v rsync 2>&1 > /dev/null
    then
        rsync -a -- "$SRC/" "$DST"
    else
        cp -r -- "$SRC" "$DST"
    fi
    rm "$DST/.skfrc"
}

#!/usr/bin/env bash

# Not tested. Report bugs 
t_skf_gen () {
    echo "You are using an untested plugin. Please report bugs "
    echo "to moebiuseye <moebiuseye@jeannedhack.org>"
    
    rm -rf "$DST"
    cp -r -- "$SRC" "$DST"
    rm "$DST/.skfrc"
}

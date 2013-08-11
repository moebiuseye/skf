
# Not tested. Report bugs 
t_skf_gen () {
    echo "You are using an untested plugin. Please report bugs "
    echo "to moebiuseye <moebiuseye@jeannedhack.org>"
    find "$SRC" -maxdepth 1 -type d | while read d 
    do 
        if ! [ -f "$d/.skfrc" ] || [ "$d" == "$SRC" ]
        then
            cp -R "$d" "$DST${d#$SRC}" 
        fi
    done
}

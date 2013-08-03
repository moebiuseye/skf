#!/bin/bash

# Setting the echoerr function. 
if [ -z "$DEBUG" ]
then
    echoerr () { :; }
else
    echoerr () { echo -e "[$0]\t$@" 1>&2; }
fi
export -f echoerr

list_subfolders () {
    # Previous ? 
    [ "$SRC_DIR" == "$SRC" ] || echo ".."
    # Next ?
    pages=$(find "$SRC"/* -maxdepth 0 -type d | while read dir
    do
        [ -f "$dir/.skfrc" ] && echo "$dir"
    done)
    echo "$pages" | while read page 
    do
        [ -z "$page" ] && break
        [ -f "$page/.skfrc" ] || break
        page=${page#$SRC}
        pagename=${page#/}
        pagename=${pagename%/}
        echo "$pagename"
    done
}

# Will be replaced by "generate_header_links"
list_css_links () {
    if [ "$style_inherit" == "true" ]  && [ "$DST" != "$DST_DIR" ]
    then
        CURR_DIR="${DST#$DST_DIR}"
        echoerr "CURR_DIR:$CURR_DIR"
        dirlist="$(while [ "$CURR_DIR" != "" ]
        do
            
            echo "$DST_DIR$CURR_DIR"
            
            CURR_DIR=$(readlink -f "$DST_DIR/$CURR_DIR/..")
            CURR_DIR="${CURR_DIR#$DST_DIR}"
            
        done | tac )"
        dirlist=("$DST_DIR $dirlist")
    else
        dirlist="$DST"
    fi

    for dir in $dirlist
    do
        dir=$(readlink -f "$dir")
        [ -d "$dir/css" ] || break
        find "$dir/css/"* -name "*.css" 2> /dev/null |\
        while read cssfile
        do 
            cssfile=$(readlink -f "$cssfile")
            cssfile="${cssfile#$DST_DIR}"
            cssfile="${cssfile#/}"
            echo "$base_url$cssfile"
        done
    done
}

generate_header () {
    i=0
    folder="$SRC"
    while [ $((i+=1)) -lt 100 ]
    do
        [ -f "$folder/header.${1}" ] && cat "$folder/header.${1}"
        [ "$folder" == "$SRC_DIR" ] && break
        folder="$(readlink -f "$folder/..")"
    done
}
generate_header_head () { generate_header head ; }
generate_header_tail () { generate_header tail ; }

htmlentities () {
    sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g'
}

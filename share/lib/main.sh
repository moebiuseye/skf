#!/usr/bin/env bash

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
    readarray -t pages< <(find "$SRC"/* -maxdepth 1 -type f -name '.skfrc' -exec dirname '{}' \; )
    for key in ${!pages[@]}
    do
        page="${pages[$key]}"
        [ -z "$page" ] && continue
        [ -f "$page/.skfrc" ] || continue
        page="${page#$SRC}"
        pagename=${page#/}
        printf "$pagename\n"
        echoerr "pagename:$pagename"
    done
}

list_subfolder_titles () {
        for key in ${!vSubfolders[@]}
        do
            subfolder="${vSubfolders[$key]}"
            [[ "$subfolder" == ".." ]] && echo "$subfolder" && continue
            subfolder="${subfolder%/}"
            subfolder="$(echo "$subfolder" | sed "s/\.[a-z]*$//")"
            subfolder="${subfolder#??_}"
            echo "$subfolder"
            echoerr "subfolder:$subfolder"
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
        [ -d "$dir/css" ] || continue
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

cp_tree () {
    cp_src="$1"
    cp_dst="$2"
    mkdir -p -- "$(dirname $(dirname "$1"))"
    if command -v rsync 2>&1 > /dev/null
    then
        rsync -r --copy-unsafe-links -- "$cp_src" "$cp_dst"
    else
        cp -r -L -- "$cp_src" "$cp_dst"
    fi
}

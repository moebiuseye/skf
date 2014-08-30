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
    local key
    local page
    local pagename
    local pages
    # Previous ? 
    [ "$SRC_DIR" == "$SRC" ] || echo "../index.html"
    # Next ?
    readarray -t pages< \
        <(find "$SRC"/* -maxdepth 1 \
            -type f -name '.skfrc' -exec dirname '{}' \; )
    for key in ${!pages[@]}
    do
        page="${pages[$key]}"
        [ -z "$page" ] && continue
        [ -f "$page/.skfrc" ] || continue
        page="${page#$SRC}"
        pagename=${page#/}
        printf '%s/index.html\n' "$pagename"
        echoerr "pagename:$pagename"
    done
}

list_subfolder_titles () {
    local key
    local subfolder
    for key in ${!vSubfolders[@]}
    do
        subfolder="${vSubfolders[$key]}"
        [[ "$subfolder" == "../index.html" ]] && echo ".." && continue
        subfolder="${subfolder%/index.html}"
        subfolder="${subfolder%/}"
        subfolder="$(printf '%s\n' "$subfolder" | sed 's/\.[a-z]\{1,\}$//')"
        subfolder="${subfolder#??_}"
        echo "$subfolder"
        echoerr "subfolder:$subfolder"
    done
}

# Will be replaced by "generate_header_links"
list_css_links () {
    local dirlist
    local CURR_DIR
    if [ "$style_inherit" == "true" ] && [ "$DST" != "$DST_DIR" ]
    then
        CURR_DIR="${DST#$DST_DIR}"
        echoerr CURR_DIR "$CURR_DIR"
        readarray -t dirlist < <(
            {
            while [ "$CURR_DIR" != "" ]
            do
                echo "$DST_DIR$CURR_DIR"
                
                CURR_DIR=$(readlink -f "$DST_DIR/$CURR_DIR/..")
                CURR_DIR="${CURR_DIR#$DST_DIR}"
            done ; echo "$DST_DIR" ; 
            } | tac
        )
    else
        dirlist="$DST"
    fi
    
    local k
    local l
    local dir
    local cssfiles
    local cssfile
    for k in ${!dirlist[@]]}
    do
        dir=$(readlink -f "${dirlist[$k]}")
        echoerr dir "$dir"
        [ -d "$dir/css" ] || continue
        readarray -t cssfiles < <(find "$dir/css/" -name "*.css" 2> /dev/null )
        echoerr cssfiles "${!cssfiles[@]}"
        echoerr cssfile0 "${cssfiles[0]}"
        for l in ${!cssfiles[@]}
        do 
            cssfile=$(readlink -f "${cssfiles[$l]}")
            cssfile="${cssfile#$DST_DIR}"
            cssfile="${cssfile#/}"
            echoerr CSSURL "$base_url$cssfile"
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
    local cp_src="$1"
    local cp_dst="$2"
    mkdir -p -- "$(dirname $(dirname "$cp_src"))"
    if command -v rsync 2>&1 > /dev/null
    then
        rsync -r --copy-unsafe-links -- "$cp_src" "$cp_dst"
    else
        cp -r -L -- "$cp_src" "$cp_dst"
    fi
}

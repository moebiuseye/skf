#!/usr/bin/env bash


# The whole idea of plugins here, is to set some variables 
# and `source`ing a view file, redirecting it's output into the desired 
# target file. 
# You should also "prepare" the destination directory 
# ( mkdir -p -- "$DST" and touch -- "$DST/$dstfile" ) before 
# you use the view files. 
# You should read the view file your plugin is made for, 
# before writing a plugin. Everytime you write a line without 
# having read the view file, a kitty dies. 
#
#
# vTitle        # if not set, $title is used 
# vSubTitle     # if not set, $subtitle is used 
#               # 
# vUrl          # if not set, $base_url is used
# vBaseUrl      # if not set, $base_url is used 
# 
# vStylesheets  # if not set, nothing is used 
#               # IMPORTANT : it should be an itterable array 
#               # You should prefer absolute urls to relative ones. 
#               # $vBaseUrl is NOT prepended. It's used as is. 
# 
# vSubfolders   # if not set, we assume there are no subfolders. 
#               # IMPORTANT : it should be an itterable array 
#               # 
# 
# vLeftMarkdown # if not set, $vLeftHtml is used.
#               # IMPORTANT : it should either be an existing 
#               # markdown file or some markdown in itself. 
#               
#  or
# vLeftHtml     # if neither this nor vLeftMarkdown is set, 
#               # then you end up with no left text at all. 
#               # IMPORANT : it should either be an existing 
#               # html file or some html in itself. 
# 
# vMainMarkdown # This behaves exctly like vLeftMarkdown (see above)
#  or
# vMainHtml     # Same ... 
#
# vHeaderHead   # echoed right after  the openning <head>  tag
# vHeaderTail   # echoed right before the closing  </head> tag

cp_images () {
    mkdir -p -- "$DST/images"
    if command -v rsync 2>&1 > /dev/null
    then
        rsync -r --copy-unsafe-links -- "$SRC/images/" "$DST/images"
    else
        cp -r -L -- "$SRC/images/" "$DST/images"
    fi
}

t_skf_gen () {
    # Preparing destination 
    mkdir -p -- "$DST"
    touch -- "$DST/index.html"
    
    # Setting variables
    #vTitle="$title"
    #vSubTitle="$subtitle"
    
    vUrl="${base_url%/}${DST#$DST_DIR}"
    #vBaseUrl="$base_url"

    readarray -t vStylesheets< <(list_css_links)
    readarray -t vSubfolders< <(list_subfolders)
    readarray -t vSubfolderTitle< <(list_subfolder_titles)

    vPlugin="$plugin"

    vLeftMarkdown="$([ -f "$SRC/left.md"  ] && echo "$SRC/left.md" )"
    
    n=0
    readarray -t imglist< <(find "$SRC/images" -maxdepth 1 | grep -E "(jpg|png|jpeg)$" | sort)
    
    for key in ${!imglist[@]}
    do
        image="${imglist[$key]}"
        vMainMarkdown=""
        vSubTitle=""
        
        # TODO : come up with another idea than readlink -m
        image="$(readlink -m "$image")"
        image="${image#$SRC}"
        imgname="${image%\.*}"
        pagename="${imgname#/images/}"
        
        next="/index.html"
        if [[ "${imglist[n+1]}" != "" ]]
        then
            next="$(readlink -m "${imglist[n+1]}")"
            next="${next#$SRC}"
            next="${next%\.*}"
            next="${next#/images/}.html"
        fi
        
        vSubTitle="$pagename"
        mdfile="${SRC}/images/${pagename}.md"
        echoerr "mdfile: $mdfile"
        if [[ -f "${mdfile}" ]]
        then
            echoerr "mdfile $mdfile exists. Processing."
            vSubTitle=$((grep -E '^title:' | head -n 1) < "${mdfile}" )
            vSubTitle=${vSubTitle#title:}
            vMainMarkdown="$(tail -n +2 "${mdfile}" | sed -n "/^$/,$ p")"
        fi
        
        imgurl="$(echo ${base_url}${image} | sed 's#//#/#g')"
        vMainMarkdown="$(echo "
[![$imgname]($imgurl)](${base_url}${next})
")
$vMainMarkdown"

        if [ $n -eq 0 ]
        then
            touch -- "$DST/index.html"
            source "$SHARE_DIR/themes/${theme:-default}/index" > "$DST/index.html"
        fi
        touch -- "$DST/$pagename.html"
        source "$SHARE_DIR/themes/${theme:-default}/index" > "$DST/$pagename.html"
        
        ((n+=1))
    done
    
    # And finaly, copy the images. 
    cp_images
}
export staticlist="css/*.css
img/*
fonts/*
"

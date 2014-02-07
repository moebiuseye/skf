#!/usr/bin/env bash

cat << EOF
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
 ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  #
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  
#  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  
##  ##  ## This plugin is not yet ready! Don't USE IT!  ##  ##  ##  ##  ##
 ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  #
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  
#  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ## 
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
Well, you've been warned, pal! Now, will you or will you not comply? 
Press 'Y' to be a nice guy. Press 'N' to be a jerk.
EOF

read response
if [[ $response == "Y" || $response == "y" ]]
then
    exit 0
fi

t_git_compress () {
    readarray -t gitsubs< <(find "$SRC" -name '.git' -type d)
    
    for key in ${!gitsubs[@]}
    do
        gitsub="${gitsubs[$key]}"
        folder="${gitsub/\/.git}"
        case $compression_method in
            "zip")
                zip -r "$DST${folder#$SRC}.zip" "$folder"
                ;;
            "gzip")
                .
                ;;
            "copy")
                # NOTICE : tree command 
                # tree -H http://gittest.jeannedhack.org/ | sed -n '/^<body>$/,$ p' | grep -v '</html>' | grep -v -E '<(|/)body>'
                rm -rf "$DST${folder#$SRC}/git/"
                cp -R -- "$folder" "$DST${folder#$SRC}/git"
                ;;
            *)
                printf '[WARNING]\tYou should set the \$compression_method variable!\n'
                printf '[WARNING]\tPossible values: zip,gzip,copy\n'
                ;;
        esac
    done
}

t_git_repo_main () {
    
    printf "<fieldset>"
    READMEFILE=$(find $PWD -maxdepth 1 -iname README.md)
    if [[ -f "$READMEFILE" ]] 
    then
        printf "<legend>README.md</legend>"
        markdown < "$READMEFILE"
    fi
    printf "</fieldset>"
    case $compression_method in
        "zip")
            printf "<small><a href='%s%s'>%s</a></small>" "$base_url" "${PWD#$SRC/}.zip" "Télécharger le zip"
            ;;
        "gzip")
            printf "<small><a href='%s%s'>%s</a></small>" "$base_url" "${PWD#$SRC/}.tar.gz" "Télécharger le tarball"
            ;;
        "copy")
            printf "<small><a href='%s%s'>%s</a></small>" "$base_url" "${PWD#$SRC/}/git/" "Voir les fichiers."
            ;;
    esac
}

# This generates every git repositorie files in repodir/index.html
t_git_repo_gen () {
    readarray -t gitsubs< <(find "$SRC" -name '.git' -type d )
    PrevPWD="$PWD"
    
    local vUrl="$vUrl/posts"
    for key in ${!gitsubs[@]}
    do
        gitsub="${gitsubs[key]}"
        subfolder="${gitsub/\/.git}"
        
        cd ${subfolder}
        
        # setting variables
        vSubTitle="${subfolder#$SRC/}"
        
        vMainHtml=$(t_git_repo_main)
        #vBaseUrl="$base_url"
        
        readarray -t vSubfolders< <(printf '..\n%s' "$(list_subfolders)")
        readarray -t vSubfolderTitle< <( 
            for key in ${!vSubfolders[]@}
            do
                subfolder="${vSubfolders[$key]}"
                [ "$subfolder" == ".." ] && echo "$subfolder" && continue
                subfolder="$(echo "$subfolder" | sed "s/\.[a-z]*$//")"
                subfolder="${subfolder#??_}"
                echo "$subfolder"
                echoerr "subfolder:$subfolder"
            done
        )
        
        page="$DST/${subfolder#$SRC}/index.html"
        mkdir -p -- "$DST/${subfolder#$SRC}"
        touch -- "$page"
        source $SHARE_DIR/themes/${theme:-default}/index > "$page"
    done
    cd "$PrevPWD"
}

t_git_gen_main () {
    readarray -t gitsubs< <(find "$SRC" -name '.git' -type d )
    
    prevPWD=$(pwd)
    
    for key in ${!gitsubs[@]}
    do
        gitsub="${gitsubs[$key]}"
        cd -- "$prevPWD"
        subfolder="${gitsub/\/.git}"
        
        printf "<article>"
        printf "<h3><a href='%s%s'>%s</a></h3>" \
            "${base_url%/}" "${subfolder#$SRC}/index.html" "${subfolder#$SRC/}"
        cd -- "$subfolder"
        printf "<pre>%s</pre>" "$(git log)"
        printf "</article>"
        
    done
    
    cd -- "$prevPWD"
}

t_skf_gen () {
    # Preparing destination 
    mkdir -p -- "$DST"
    touch -- "$DST/index.html"
    
    export vLeftMarkdown="$([ -f "$SRC/left.md"  ] && echo "$SRC/left.md"  )"
    export vUrl="${base_url%/}${DST#$DST_DIR}"
    export vStylesheets
    readarray -t vStylesheets< <(list_css_links)
    
    # Compressing/copying repo directory
    t_git_compress
    # Generating the git repo pages
    t_git_repo_gen
    
    # Setting variables
    #vTitle="$title"
    #vSubTitle="$subtitle"
    
    #vBaseUrl="$base_url"
    
    readarray -t vSubfolders< <(list_subfolders)
    readarray -t vSubfolderTitle< <(list_subfolder_titles)

    vMainHtml="$(t_git_gen_main)"

    vPlugin="$plugin"
    
    
    # generating main page
    source $SHARE_DIR/themes/${theme:-default}/index > "$DST/index.html"
    
}
export staticlist="css/*.css
img/*
fonts/*
"

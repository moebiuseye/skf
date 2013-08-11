#!/bin/bash

# The whole idea of plugins here, is to set some variables 
# and `source`ing a view file, redirecting it's output into the desired 
# target file. 
# You should also "prepare" the destination directory 
# ( mkdir -p "$DST" and touch "$DST/$dstfile" ) before 
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


t_skf_gen () {
    # Preparing destination 
    mkdir -p "$DST"
    touch "$DST/index.html"
    
    # Setting variables
    #vTitle="$title"
    #vSubTitle="$subtitle"
    
    vUrl="${base_url%/}${DST#$DST_DIR}"
    #vBaseUrl="$baseurl"

    echoerr "STOP"
    vStylesheets=("$(list_css_links)")
    
    vSubfolders="$(list_subfolders)"
    
    vSubfolderTitle="$(list_subfolder_titles)"

    vMainMarkdown="$([ -f "$SRC/index.md" ] && echo "$SRC/index.md" )"
    vLeftMarkdown="$([ -f "$SRC/left.md"  ] && echo "$SRC/left.md"  )"

    vPlugin="$plugin"
    
    echoerr "$SHARE_DIR/themes/default/index" ">" "$DST/index.html"
    source "$SHARE_DIR/themes/default/index" > "$DST/index.html"
    
}
export staticlist="css/*.css
img/*
"

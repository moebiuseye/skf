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

t_markdown_blog_gen_rss () {
    # preparing destintion
    touch -- "$DST/rss.xml"
    
    blogposts=$(find $SRC/posts/*-*-*-*.md)
    
    source $SHARE_DIR/themes/default/rss > "$DST/rss.xml"
}

t_markdown_blog_gen_posts () {
    # Preparing destination 
    mkdir -p -- "$DST/posts"
    
    find $SRC/posts/*-*-*-*.md | while read blogpost 
    do
        # setting variables
        vSubTitle=$(head -n 1 $blogpost)
        vSubTitle=${vSubTitle#title:}
        
        vUrl="$vUrl/posts"
        #vBaseUrl="$baseurl"
        
        vSubfolders="$(list_subfolders)"
        vSubfolderTitle="$( 
            echo "$vSubfolders" | while read subfolder
            do
                [ "$subfolder" == ".." ] && echo "$subfolder" && continue
                subfolder="$(echo "$subfolder" | sed "s/\.[a-z]*$//")"
                subfolder="${subfolder#??_}"
                echo "$subfolder"
                echoerr "subfolder:$subfolder"
            done
        )"

        vMainMarkdown="$(tail -n +2 "$blogpost" | sed -n "/^$/,$ p" | markdown)"

        vPlugin="$plugin"
        
        # preparing destination 
        bpHtmlFile="${blogpost/$SRC_DIR/$DST_DIR/}.html"
        touch -- "$bpHtmlFile"
        
        # generating blog post page
        source $SHARE_DIR/themes/default/index > "$bpHtmlFile"
    done
}

t_markdown_blog_gen_main () {

    find $SRC/posts/*-*-*-*.md | sort -r | while read blogpost 
    do
        [ -f "$DST${blogpost#$SRC}.html" ] || echo "<small>article copy seems to have failed!</small>" 
        # Setting variables
        bpUrl=$(echo ${blogpost#$SRC_DIR})
        tmp=$(echo ${blogpost#$SRC/posts/} | tr "-" '\n')
        bpDate=($tmp)
        bpYear=${bpDate[0]}
        bpMonth=${bpDate[1]}
        bpDay=${bpDate[2]}
        
        bpTitle=$(head -n 1 $blogpost)
        bpTitle=${bpTitle#title:}
        
        # Echoing some html
        echo "<article>"
        echo "<h3><a href='${base_url%/}$bpUrl.html'>$bpTitle</a></h3>"
        echo "<small>$(date --date="$bpYear-$bpMonth-$bpDay 00:00:00" +'%x')</small>"
        tail -n +2 "$blogpost" | sed -n "/^$/,$ p" | markdown
        echo "</article>"
    done
    

}

t_skf_gen () {
    # Preparing destination 
    mkdir -p -- "$DST"
    touch -- "$DST/index.html"
    
    export vLeftMarkdown="$([ -f "$SRC/left.md"  ] && echo "$SRC/left.md"  )"
    export vUrl="${base_url%/}${DST#$DST_DIR}"
    export vStylesheets=("$(list_css_links)")
    
    # Generating the blog posts 
    t_markdown_blog_gen_posts
    # Generating the rss feed
    t_markdown_blog_gen_rss
    
    # Setting variables
    #vTitle="$title"
    #vSubTitle="$subtitle"
    
    #vBaseUrl="$baseurl"
    
    vSubfolders="$(echo "$(list_subfolders)
rss.xml")"
    vSubfolderTitle="$(list_subfolder_titles)"

    vMainHtml="$(t_markdown_blog_gen_main)"

    vPlugin="$plugin"
    
    # generating main page
    source $SHARE_DIR/themes/default/index > "$DST/index.html"
    
}
export staticlist="css/*.css
img/*
"

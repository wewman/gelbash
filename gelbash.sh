#!/bin/bash

################### USAGE #################
##                                       ##
##    sh gelbash.sh tag1 tag2 tag3 ...   ##
##                                       ##
###########################################

# Take every parameter
input=$*

# Replace spaces with + to fit the URL
tags="${input// /+}"

# Appropriate directory
#   though, if you put the tags in
#   a different way, it will probably
#   re-download the same stuff but in
#   a different directory
mkdir -p $tags

echo Leeching everything with: $tags
echo Prepare yourself.

# Page number
pid=0

# Loop forever until break
while true; do

    # Display current page number
    #   but will get lost due to wget output
    echo -n $pid ' '

    # Command in the variable to be used by eval
    #   TODO Make it so it saves it to a file
    #     and evaluates from that file
    #     because this is inefficient,
    #     evaling the command more than once, that is.
    get="curl -s 'https://gelbooru.com/index.php?page=dapi&s=post&tags=$tags&q=index&pid=$pid' \
        | grep -ioE 'file_url=\"\/\/assets\.gelbooru\.com\/images\/.{1,3}\/.{1,3}\/.{32}\.(jpg|png|jpeg|webm|gif)' \
        | cut -c11-\
        | sed -e 's/^/https:/'"
#        > image_$pid.files"

    # Check if the output is alive.
    if [[ ! $(eval "$get") ]]; then
        # If the output is empty (empty string)
        #   it will clean and break
        echo \nDone, no more files
        echo Cleaning...
        rm image_*
        break;
    else
        # saves the URLs in an appropriate file
        #   NOTE Every file has 100 links
        #     due to Gelbooru's max limit being 100
        #     so, every 10 files is 1000 images downloaded
        $(eval "$get" > image_$pid.files)

        # Downloads the files to an appropriate directory
        wget -nc -P $tags/ -c -i image_$pid.files

        # Increment and continue
        (( pid++ ))
        continue;
    fi

done

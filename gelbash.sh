#!/bin/bash

################### USAGE #################
##                                       ##
##   sh gelbash.sh tag1 tag2 -tag3 ...   ##
##                                       ##
###########################################

################### NOTES #################
##                                       ##
##            Note the -tag3.            ##
##                                       ##
##  This is if you want to exclude a tag ##
##                                       ##
##    For safety, you have to exclude    ##
##             more tags                 ##
##                                       ##
###########################################

################# EXAMPLE #################
##                                       ##
## sh gelbash.sh touhou -hat yellow_hair ##
##                                       ##
##    This will download touhous with    ##
##        no hats and yellow hair        ##
##                                       ##
##      in the directory:                ##
##         touhou+-hat+yellow_hair       ##
##                                       ##
###########################################


# Take every parameter
input="$@"

# Replace spaces with + to fit the URL
tags="${input// /+}"

# Appropriate directory
#   though, if you put the tags in
#   a different way, it will probably
#   re-download the same stuff but in
#   a different directory
mkdir -p "$tags"

echo Leeching everything with: "$tags"
echo Prepare yourself.

# Page number
pid=0

# Loop forever until break
while true; do

    # Display current page number
    #   but will get lost due to wget output
    echo -n "$pid" ' '

    # What it does:
    #  1 Gets the XML document with the given tags
    #  2 Greps out the line with file_url with its random
    #     numbers and directories so there are no duplicates
    #  3 Cuts the file_url=" from the beginning of every line
    #  4 Appends https: in the beginning of every line
    #  5 Put everything to a file so wget can download them
    #     NOTE Every file has 100 links
    #       due to Gelbooru's max limit being 100
    #       so, every 10 files is 1000 images downloaded
    get=$(curl -s "https://gelbooru.com/index.php?page=dapi&s=post&tags=$tags&q=index&pid=$pid" \
        | grep -ioE "file_url=\"\/\/gelbooru\.com\/images\/.{1,3}\/.{1,3}\/.{32}\.(jpg|png|jpeg|webm|gif)" \
        | cut -c11- \
        | sed -e "s/^/https:/" \
        | tee image_$pid.files)


    # Check if the output is alive.
    if [[ ! ${get} ]]; then
        # If the output is empty (empty string)
        #   it will clean and break
        echo Done, no more files
        #echo Cleaning...
        #rm image_*
        break;
    else
        # Downloads the files to an appropriate directory
        wget -nc -P $tags/ -c -O $tags/image_$pid.files

        # Increment and continue
        (( pid++ ))
        continue;
    fi

done

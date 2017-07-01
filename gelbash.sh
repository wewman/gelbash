#!/bin/bash

input=$*
tags="${input// /+}"

mkdir -p $tags
echo Lurking tags: $input

pid=0
while true; do

    echo -n $pid

    #Best thing to do here is to save it to a file
    # read from the file
    # then eval from there
    get="curl -s 'https://gelbooru.com/index.php?page=dapi&s=post&tags=$tags&q=index&pid=$pid' \
        | grep -ioE 'file_url=\"\/\/assets\.gelbooru\.com\/images\/.{1,3}\/.{1,3}\/.{32}\.(jpg|png|jpeg|webm|gif)' \
        | cut -c11-\
        | sed -e 's/^/https:/'"
#        > image_$pid.files"

    if [[ ! $(eval "$get") ]]; then
        echo
        echo Done, no more files
        break;
    else
        $(eval "$get" > image_$pid.files)

        wget -nc -P $tags/ -c -i image_$pid.files
        (( pid++ ))
        continue;
    fi

done

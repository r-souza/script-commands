#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Upload Latest Screenshot to ImgBB
# @raycast.mode silent
# @raycast.packageName Upload to ImgBB
#
# Optional parameters:
# @raycast.icon ☁️
#
# Documentation:
# @raycast.description Upload your last screenshot to ImgBB and copy the image link to clipboard
# @raycast.author Rodrigo de Souza
# @raycast.authorURL https://github.com/r-souza


# Script based on imgur-upload-latest-screenshot.sh from Fahim Faisal (https://github.com/i3p9)
# https://github.com/raycast/script-commands/blob/master/commands/productivity/imgur/imgur-upload-latest-screenshot.template.sh

# Get screenshot location and latest screenshot
DIR=$(defaults read com.apple.screencapture location)
FILE=$(find "$DIR" -type f | sort -r | head -n 1)

#Api Key, use your own Api Key. Get it from https://api.imgbb.com/
api_key="" #CAN NOT BE EMPTY

if [ "$api_key" == "" ]; then
    echo "No API Key found. Configure your own key before running"
    exit 1
fi

function upload {
	curl --location --request POST "https://api.imgbb.com/1/upload?key=${api_key}" --form "image=$1"
}

remove_backslashes() {
    echo "${1//\\/}"
}

output=$(upload "@$FILE") 2>/dev/null

if echo "$output" | grep -q 'Bad Request'; then
    echo "From ImgBB: Upload Error, try again" >&2
else
    #grab the image url from curl response
    url="${output##*\"display_url\":\"}"
    url=$(echo "$url" | cut -d '"' -f 1)
    url=$(remove_backslashes "$url")

    #Copy to clipboard   
    echo -n "$url" | pbcopy
    echo "Link copied to clipboard"
fi
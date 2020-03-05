#!/bin/bash

# MOVE TO /usr/local/bin/hdc, REMEMBER TO chmod +x /usr/local/bin/hdc

# user config
PASSWORD=
URL=

# internal vars
VERSION=1.0
TITLE="HARRY DOT CITY upload tool v${VERSION}"

# text functions
bold=$(tput bold)
normal=$(tput sgr0)

help() {
    echo "${bold}${TITLE}${normal} - upload temporary files to files.harry.city"
    echo
    echo "${bold}usage:${normal} hdc [--version] [--help] [-p <password> | --password <password>] [-u <url> | --url <url>] [-x] [-c | --clip] <file path>"
    echo
    echo "${bold}options:${normal}"
    echo "  ${bold}<file path> | clipboard${normal}"
    echo "      If no file path is provided then the image in the clipboard will be used."
    echo
    echo "  ${bold}--version${normal}"
    echo "      Prints the tool version."
    echo
    echo "  ${bold}--help${normal}"
    echo "      Prints description and tool arguments."
    echo
    echo "  ${bold}-p <password>, --password <password>"
    echo "      Password for the server. Can also be provided at the top of the script."
    echo
    echo "  ${bold}-u <url>, --url <url>${normal}"
    echo "      Uses a different upload URL than the one embedded in the tool. Can be used for debugging purposes."
    echo
    echo "  ${bold}-x${normal}"
    echo "      Generates a URL using the 'x' id scheme."
    echo
    echo "  ${bold}-c, --clip${normal}"
    echo "      Upload an image clip (uses maim on Linux)."
}

# handle arguments
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    --version)
    echo "$TITLE"
    exit 0
    ;;
    --help)
    help
    exit 0
    ;;
    -p|--password)
    PASSWORD="$2"
    shift # past argument
    shift # past value
    ;;
    -u|--url)
    URL="$2"
    shift # past argument
    shift # past value
    ;;
    -x)
    X=1
    shift # past argument
    ;;
    -c|--clip)
    if ! [ -x "$(command -v maim)" ]; then
        echo "hdc: maim is required for screenshot clipping on Linux."
        exit 1
    fi
    maim -s | tee /tmp/screenshot.png &> /dev/null
    FILE_PATH=/tmp/screenshot.png
    shift
    shift
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

# get file path from argument or clipboard
if [[ -n $1 ]]; then
    FILE_PATH="$1"
elif [[ -z $FILE_PATH ]]; then
    ERR_MSG="hdc: Couldn't get image from clipboard. See 'hdc --help' for other options."
    case "$(uname -s)" in
        Linux)
        if ! [ -x "$(command -v xclip)" ]; then
            echo "hdc: xclip is required for clipboard upload on Linux."
            exit 1
        fi

        if xclip -selection clipboard -t image/png -o > /tmp/screenshot.png; then
            FILE_PATH=/tmp/screenshot.png
        else
            echo $ERR_MSG
            exit 1
        fi        
        ;;
        Darwin)
        if ! [ -x "$(command -v pngpaste)" ]; then
            echo "hdc: pngpaste is required for clipboard upload on Linux."
            exit 1
        fi

        if pngpaste /tmp/screenshot.png; then
            FILE_PATH=/tmp/screenshot.png
        else
            echo $ERR_MSG
            exit 1
        fi
        ;;
        *)
        echo "hdc: Cannot determine OS and therefore cannot determine how to get image from clipboard. Try providing a file path."
        exit 0
        ;;
    esac
fi

# file uploading
if [[ -n $FILE_PATH ]]; then
  FORM_DATA="-F password=${PASSWORD}"
  if [[ $X -eq 1 ]]; then
    FORM_DATA="${FORM_DATA} -F x=1"
  fi
  RESULT=$(curl --silent ${FORM_DATA} -F file=@"$FILE_PATH" "$URL")
  if [[ -n $RESULT ]]; then
    GENERIC_FINISH="hdc: Uploaded - $RESULT"
    COPIED_FINISH="hdc: Copied to clipboard - $RESULT"
    case "$(uname -s)" in
        Linux)
        if [ -x "$(command -v xclip)" ]; then
            printf $RESULT | xclip -selection c
            echo $COPIED_FINISH
        else
            echo $GENERIC_FINISH
            echo "hdc: If xclip was installed then would copy URL to clipboard."
        fi
        ;;
        Darwin)
        printf $RESULT | pbcopy
        echo $COPIED_FINISH
        ;;
        *)
        echo $GENERIC_FINISH
        ;;
    esac
  else
    echo "hdc: Failed to upload image. Check given url and see 'hdc --help'."
    exit 1
  fi
  
fi

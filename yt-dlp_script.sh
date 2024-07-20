#!/bin/bash

rename() {
    new_filename=$(echo "$1" | sed 's/\[.*\]/_/g')
    new_filename=${new_filename// /-}
    new_filename=${new_filename//_/-}
    new_filename=${new_filename//,/-}
    new_filename=${new_filename//---/-}
    new_filename=${new_filename//--/-}
}

#sprawdza czy podano link
if [ -z "$1" ]; then
    echo "Usage: $0 <YouTube_URL>"
    exit 1
fi

url="$1"
safe_url=$(echo "$url" | sed 's/[^a-zA-Z0-9]/_/g')
list="format-list-$safe_url"

#sprawdza czy yt-dlp jest zainstalowany
if ! command -v yt-dlp &> /dev/null; then
    echo "yt-dlp is not installed. Please install it and try again."
    exit 1
fi

yt-dlp -F "$url" > "$list"

#sprawdza czy poprawnie załadowano listę formatów
if [ ! -s "$list" ]; then
    echo "Failed to fetch format list. Exiting."
    rm -f "$list"
    exit 1
fi

echo "audio:"
grep "audio" "$list"
echo ""
read -p "audio: " audio

echo -e "\nvideo:"
grep -E "1280x720.*avc|1920x1080.*avc" "$list"
echo ""
read -p "video: " video

yt-dlp -f "$audio"+"$video" "$url"

filename=$(yt-dlp -f "$audio"+"$video" --get-filename "$url")
rename "$filename"

#sprawdza czy plik z nazwą istnieje
if [ -f "$filename" ]; then
    mv "$filename" ~/syncthing/DCIM/YouTube/"$new_filename"
    echo "$new_filename Moved to ~/syncthing/DCIM/YouTube"
else
    echo "File $filename not found."
fi

rm -f "$list"

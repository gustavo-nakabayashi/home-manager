#!/bin/bash

workspace=$1

# Define wallpapers for each workspace
declare -A wallpapers=(
    [1]="/System/Library/Desktop Pictures/Sonoma.heic"
    [2]="/System/Library/Desktop Pictures/Ventura.heic"
    [3]="/System/Library/Desktop Pictures/Monterey.heic"
    [4]="/System/Library/Desktop Pictures/Big Sur.heic"
    [5]="/System/Library/Desktop Pictures/Catalina.heic"
    [6]="/System/Library/Desktop Pictures/Mojave.heic"
    [7]="/System/Library/Desktop Pictures/High Sierra.heic"
)

# Get the wallpaper for the current workspace
wallpaper=${wallpapers[$workspace]}

# Set the wallpaper if defined
if [[ -n "$wallpaper" && -f "$wallpaper" ]]; then
    osascript -e "tell application \"System Events\" to tell every desktop to set picture to \"$wallpaper\""
fi
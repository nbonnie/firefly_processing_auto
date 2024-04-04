#!/bin/bash

# --------------------------------------------------------------------------------
# Chapter to Story Script
#
# Purpose: This script processes GoPro Fusion IR video chapters and stitches them
#          into complete stories based on their numerical IDs. Supports chapters
#          within subdirectories.
#
# Usage:   ./chapter_2_story.sh /path/to/field_season/YYYYMMDD
#
# Input Directory Structure:
#
#   Fusion_IR_Chapters/
#     cam1/  # Camera 1 directory
#       ...  # Chapter files (GPFR0015_stitched.mp4, GP010015_stitched.mp4, etc.)
#     cam2/  # Camera 2 directory (similar structure)
#     ...    # Chapter files (GPFR0016_stitched.mp4, GP010016_stitched.mp4, etc.)
#
# Output:
#    Story videos (e.g., story_15.mp4) are placed in:
#        YYYYMMDD/Fusion_IR_Sphere/
#
# Script Workflow:
# 1. Find Chapters:  Searches for chapter files (ending in '_stitched.mp4')
# 2. Group Chapters: Groups chapters into stories based on the last 2 digits
# 3. Create Chapter Lists: Creates text files listing chapters for each story 
# 4. Story Stitching: Uses ffmpeg to concatenate chapters into story videos.
#
# Notes:
# - Ensure the script has read permissions for the input directory.
#
# Author:      Nolan R. Bonnie
# Contact:     nolan.bonnie@colorado.edu 
# Created:     04/2024
# --------------------------------------------------------------------------------

# Function to process chapters for a single camera directory
function process_camera_dir() {
    camera_dir="$1"
    output_dir="${parent_dir}/Fusion_IR_Sphere"

    # Emulate associative array behavior
    chapter_files=()
    story_ids=() 

    for file in "$camera_dir"/*_stitched.mp4; do 
        if [[ $file =~ ([0-9]{2})_stitched\.mp4 ]]; then
            story_id=${BASH_REMATCH[1]}

            # Check if the story_id is tracked
            if [[ ! " ${story_ids[*]} " =~ " ${story_id} " ]]; then
                story_ids+=("$story_id")
            fi

            chapter_files+=("$story_id $file") # Store story_id + filename
        fi
    done

    # Prints out some useful information for sanity checks
    echo "chapter_files:"  # Add a header
    for file_entry in "${chapter_files[@]}"; do
        echo "$file_entry"  # Print each entry on a new line
    done

    # Process each story
    for story_id in "${story_ids[@]}"; do
        chapter_list="$output_dir/chapters_list_${story_id}.txt"
        rm -f "$chapter_list"  

        gfr_chapter_added=false # Add a flag to track if GPFR is added

        # Add GPFR chapter first (if it exists)
        for file_entry in "${chapter_files[@]}"; do
            if [[ $file_entry =~ ^$story_id.*GPFR && !$gfr_chapter_added ]]; then
                file=$(echo $file_entry | cut -d ' ' -f 2-) 
                echo "file '$file'" >> "$chapter_list"
                gfr_chapter_added=true # Set flag to true
            fi
        done

        # Add the rest of the chapters
        for file_entry in "${chapter_files[@]}"; do
            if [[ $file_entry =~ ^$story_id && !($file_entry =~ GPFR) ]]; then  # Exclude GPFR 
                file=$(echo $file_entry | cut -d ' ' -f 2-) 
                echo "file '$file'" >> "$chapter_list"
            fi
        done

        ffmpeg -f concat -safe 0 -i "$chapter_list" -c copy "$output_dir/story_${story_id}.mp4"
        echo "Story created at: $output_dir/story_${story_id}.mp4"
    done
}

# ------ Main Script -------

if [ -z "$1" ]; then
  echo "Usage: $0 <parent_directory>"
  exit 1
fi

parent_dir="$1"
chapters_dir="${parent_dir}/Fusion_IR_Chapters"

# Validate the input directory's existence
if [ ! -d "$chapters_dir" ]; then
  echo "Error: Chapters directory '$chapters_dir' does not exist."
  exit 1
fi

# Process chapters for cam1 and cam2
process_camera_dir "$chapters_dir/cam1"
process_camera_dir "$chapters_dir/cam2"
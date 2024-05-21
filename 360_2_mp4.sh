#!/bin/bash

# --------------------------------------------------------------------------------
# 360 to MP4 Conversion Script
#
# Purpose: This script automates the conversion of GoPro Max .360 videos to MP4 format
#          using ffmpeg, while skipping files that have already been converted.
#
# Important Note: This script utilizes a custom fork of ffmpeg which needs to be compiled
#          manually. See https://github.com/gmat/goproMax-ffmpeg-v5 and 
#                        https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu
#
# Usage:   ./360_2_mp4.sh <input_directory> <output_directory>
#
# Example: ./360_2_mp4.sh /home/nbonnie/Desktop/360_test/test_input/ /home/nbonnie/Desktop/360_test/test_output/
#
# Input:
#     A directory containing .360 video files.
#
# Output:
#     MP4 video files in the specified output directory. The filenames will be
#     the same as the input files, but with the .mp4 extension.
#
# Script Workflow:
# 1. Validate Input: Checks if the input and output directories exist.
# 2. Find 360 Files: Identifies all .360 files in the input directory.
# 3. Check for Existing Output: Skips conversion if an MP4 file with the same name already exists in the output directory.
# 4. Convert with ffmpeg: Uses ffmpeg to convert each .360 file to .mp4, maintaining metadata and audio.
# 5. Log: Outputs messages indicating which files were converted or skipped.
#
# Notes:
# - This script assumes you have ffmpeg installed with the gopromax_opencl filter (from the custom fork).
# - Ensure ffmpeg has the correct libx264 encorder installed ($ ffmpeg -codecs | grep 264)
#
# Author:       Nolan R. Bonnie
# Contact:      nolan.bonnie@colorado.edu
# Created:      05/2024 
# --------------------------------------------------------------------------------

function convert_to_mp4() {
  input_file="$1"
  output_dir="$2"
  output_file="${output_dir}$(basename "${input_file%.360}.mp4")"

  # Check if MP4 file already exists in the output directory
  if [ -f "$output_file" ]; then
    echo "Skipping: $input_file (MP4 file already exists in $output_dir)"
    return
  fi

  # ffmpeg conversion command (with error checking)
  sudo ffmpeg \
    -hwaccel opencl -v verbose \
    -filter_complex "[0:0]format=yuv420p,hwupload[a], [0:5]format=yuv420p,hwupload[b], [a][b]gopromax_opencl, hwdownload,format=yuv420p" \
    -i "$input_file" \
    -c:v libx264 -pix_fmt yuv420p -map_metadata 0 -map 0:a -map 0:3 \
    "$output_file" || {
        echo "Error converting $input_file" 
        return 
    }

  echo "Converted: $input_file to $output_file"
}

# ----- Main Script -----
if [ $# -ne 2 ]; then
  echo "Usage: $0 <input_directory> <output_directory>"
  exit 1
fi

input_dir="$1"
output_dir="$2"

# Validate input directory
if [ ! -d "$input_dir" ]; then
  echo "Error: Input directory '$input_dir' not found."
  exit 1
fi

# Validate (or create) output directory
if [ ! -d "$output_dir" ]; then
  echo "Output directory '$output_dir' not found. Creating it..."
  mkdir -p "$output_dir" || {
    echo "Error: Could not create output directory."
    exit 1
  }
fi

# Find all .360 files and process them
for file in "$input_dir"*.360; do
  if [ -f "$file" ]; then
    convert_to_mp4 "$file" "$output_dir" 
  fi
done
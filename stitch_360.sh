#!/bin/bash

# --------------------------------------------------------------------------------
# GoPro Fusion IR Stitching Script with Chapter Support
#
# Purpose: This script automates the processing and stitching of GoPro 
#          Fusion IR camera footage, including chapters, into a single
#          spherical video per camera.
#
# Usage:   ./stitch_360.sh /path/to/field_season/YYYYMMDD
#
# Input Directory Structure:
#
# GoPro_Fusion_IR_Raw/
#   cam1/  # Camera 1 directory
#     100GFRNT/  # Front IR video files (including GPFR and GF prefixes)
#     100GBACK/  # Back IR video files (including GPBK and GB prefixes)
#   cam2/  # Camera 2 directory (similar structure)
#   ...     # Additional camera directories (if applicable)
#
# Script Workflow:
# 1. Find Videos: Searches '100GFRNT' and '100GBACK' for front/back videos.
# 2. Chapter Matching: Matches front/back videos based on chapter ID.
# 3. Chapter Stitching: Uses ffmpeg to stitch a chapter's front/back files.
# 4. Chapter List Creation: Creates a list of stitched chapter spheres.
# 5. Story Stitching: Uses ffmpeg to combine stitched chapter spheres into a story.
# 6. Cleanup: Removes temporary files. 
#
# Notes:
# - Replace placeholder 'ffmpeg' command with your actual command.
# - Ensure script has read permissions for the input directory.
#
# Author:      Nolan R. Bonnie
# Contact:     nolan.bonnie@colorado.edu 
# Created:     04/2024
# --------------------------------------------------------------------------------

# Function to process videos for a single camera directory
function process_camera_dir() {
  camera_dir="$1"
  # Extract 'cam1' or 'cam2' from the camera_dir path
  cam=$(basename "$camera_dir") 
  output_dir="${parent_dir}/Fusion_IR_Chapters/${cam}"

  # Create output directory if it doesn't exist
  # mkdir -p "$output_dir"

  # Find front and back videos within the camera directory with correct path
  front_videos=$(find "${camera_dir}/100GFRNT" -name "GPFR*.MP4" -o -name "GF*.MP4")
  back_videos=$(find "${camera_dir}/100GBACK" -name "GPBK*.MP4" -o -name "GB*.MP4")
  # Process matching pairs
  for front_file in $front_videos; do
    # Determine if it's an initial chapter file or a subsequent chapter 
        if [[ $front_file =~ ^.*/(GPFR|GF)(.+)\.MP4 ]]; then
            suffix=${BASH_REMATCH[2]}  # Capture only the part after 'GPFR' or 'GF'        
        # Determine prefix based on whether it's GF or GPFR
        if [[ $front_file =~ GPFR(.+)\.MP4 ]]; then 
            prefix="GPBK" 
        else
            prefix="GB" 
        fi
    else
        echo "Warning: Unexpected filename format for front video: $front_file" 
        continue
    fi

    back_file=$(find "$camera_dir/100GBACK" -name "${prefix}${suffix}.MP4") 

    if [ -n "$back_file" ]; then
        output_name=$(basename "$front_file" | sed -E 's/^.{2}(.*)\.MP4$/GP\1_stitched.mp4/') 
      # Run ffmpeg command with output file directed to the correct output directory
        ffmpeg -i "$front_file" \
            -i ./video-5_2k/fusion2sphere0_x.pgm \
            -i ./video-5_2k/fusion2sphere0_y.pgm \
            -i ./video-5_2k/frontmask.png \
            -i "$back_file" \
            -i ./video-5_2k/fusion2sphere1_x.pgm \
            -i ./video-5_2k/fusion2sphere1_y.pgm \
            -i ./video-5_2k/backmask.png \
            -filter_complex "[0:v][1:v][2:v] remap [front]; [4:v][5:v][6:v] remap [back];\
            [front] format=rgba [frontrgb]; [back] format=rgba [backrgb]; [frontrgb][3:v]\
            blend=all_mode='multiply':all_opacity=1 [frontmask]; \
            [backrgb][7:v] blend=all_mode='multiply':all_opacity=1 [backmask]; \
            [frontmask][backmask] blend=all_mode='addition':all_opacity=1, format=rgba" \
            -pix_fmt yuv420p "$output_dir/$output_name" || {
            echo "Error processing: $front_file and $back_file"
            }
        echo "Stitch created at $output_dir/$output_name"
    else
      echo "Warning: No matching back video found for $front_file"
    fi
  done
}

# ------ Main Script -------

if [ -z "$1" ]; then
  echo "Usage: $0 <parent_directory>"
  exit 1
fi

parent_dir="$1"

# Validation: Check if the input directory exists
if [ ! -d "$parent_dir" ]; then
  echo "Error: Input directory '$parent_dir' does not exist."
  exit 1
fi

# Process cam1 and cam2
process_camera_dir "$parent_dir/Fusion_IR_Raw/cam1" 
process_camera_dir "$parent_dir/Fusion_IR_Raw/cam2"
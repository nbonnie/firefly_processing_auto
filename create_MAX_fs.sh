#!/bin/bash
#--------------------------------------------------------------------------------
# Script Name: create_MAX_fs.sh
# Description: Creates a directory structure for organizing 
#              GoPro MAX camera data with safety checks.
#
# Usage:       chmod +x create_MAX_fs.sh 
#              ./create_MAX_fs.sh /path/to/parent
#
# Example:     ./create_MAX_fs.sh /home/user/.../FieldSiteYYYY/YYYYMMDD/
#
# Author:      Nolan R. Bonnie
# Contact:     nolan.bonnie@colorado.edu 
# Created:     04/2024
#--------------------------------------------------------------------------------

# Check if an input directory is provided
if [[ -z "$1" ]]; then
  echo "Error: Please provide an absolute path to the parent directory."
  exit 1
fi

parent_dir="$1"

# Directories to create
sub_dirs=("MAX_IR_Raw_360" "MAX_IR_mp4_Chapters" "MAX_IR_mp4_Sphere" "MAX_IR_xyt" "MAX_IR_xyzt")
cam_dirs=("cam1" "cam2")

# Create the parent directory if it doesn't exist
mkdir -p "$parent_dir"

# Create subdirectories 
for dir in "${sub_dirs[@]}"; do
  full_path="$parent_dir/$dir"
  mkdir -p "$full_path"  # Create the subdirectory if it doesn't exist

  # Create 'cam1' and 'cam2' directories inside specified subdirectories
  if [[ "$dir" == "MAX_IR_Raw_360" || "$dir" == "MAX_IR_mp4_Chapters" || "$dir" == "MAX_IR_mp4_Sphere" || "$dir" == "MAX_IR_xyt" ]]; then
    for cam in "${cam_dirs[@]}"; do
      cam_path="$full_path/$cam"
      mkdir -p "$cam_path"
    done
  fi
done

echo "Directory structure creation completed."
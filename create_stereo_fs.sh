#!/bin/bash
#--------------------------------------------------------------------------------
# Script Name: create_stereo_fs.sh
# Description: Creates a directory structure for organizing 
#              Sony A7 stereo camera data with safety checks.
#
# Usage:       chmod +x create_stereo_fs.sh 
#              ./create_stereo_fs.sh /path/to/parent
#
# Example:     ./create_stereo_fs.sh /home/user/.../FieldSiteYYYY/YYYYMMDD/
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
sub_dirs=("Sony_A7_Stereo_Raw" "Sony_A7_Stereo_xyt" "Sony_A7_Stereo_xyzt")
cam_dirs=("cam1" "cam2")

# Create the parent directory if it doesn't exist
mkdir -p "$parent_dir"

# Create subdirectories 
for dir in "${sub_dirs[@]}"; do
  full_path="$parent_dir/$dir"
  mkdir -p "$full_path"  # Create the subdirectory if it doesn't exist

  # Create 'cam1' and 'cam2' directories inside specified subdirectories
  if [[ "$dir" == "Sony_A7_Stereo_Raw" || "$dir" == "Sony_A7_Stereo_xyt" ]]; then
    for cam in "${cam_dirs[@]}"; do
      cam_path="$full_path/$cam"
      mkdir -p "$cam_path"
    done
  fi
done

echo "Directory structure creation completed."

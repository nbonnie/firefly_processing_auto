# Converting MP4 video to xyt data files
```
%---------------------------------------------------------------------------
% # Wrapper for Firefly Adaptive Background Subtraction 
%---------------------------------------------------------------------------
% This repository contains MATLAB scripts for processing raw mp4 videos into 
% xyt datafiles. 
%
% Key Features:
% * Adaptive Background Modeling: Dynamically adjusts the background model to 
%   handle complex environments and lighting changes, ensuring accurate 
%   firefly detection.
% * Multi Video Input: Designed to process videos from 2 camera setups.
% * Detailed Output: Provides xyt coordinates of detected fireflies, along with
%   area, eccentricity, intensity, and frame information for each flash.
%
%---------------------------------------------------------------------------
% Usage
%---------------------------------------------------------------------------
% Prerequisites:
% * MATLAB (tested with version 2022b+)
% * MATLAB Image Processing Toolbox
%
% Instructions:
% 1. Clone the repository:
%
% 2. Modify Parameters (Optional):
%	 Update pathing information
%    Adjust processing parameters within the  `fffabc` function, such as:
%     * `blurRadius` 
%     * `bkgrWinWidthSec`
%     * `bwth`
%
% 3. Run the Scripts:
%    * Multiple Videos (with default paths):
%       ```matlab
%       mp4_2_xyt_abc() 
%       ```
%    * Single Video (with input/output):
%       ```matlab
%       mp4_2_xyt_single('input_video.mp4', 'output_data')  
%       ```
%---------------------------------------------------------------------------
% Output
%---------------------------------------------------------------------------
% The scripts generate MATLAB structure files (.mat) containing:
% * `xyt`: xyt coordinates of detected fireflies.
% * Other metadata (parameters, background stack info).
%
%---------------------------------------------------------------------------
% License
%---------------------------------------------------------------------------
% This project is licensed under the MIT License - see the LICENSE file for details.
```

# Camera filesystem sctips
```
%---------------------------------------------------------------------------
% #  Camera Directory Creation Script
%---------------------------------------------------------------------------
% This script facilitates the organization of Sony A7 camera data.

% Key Features:
% * Structured Directory Creation: Generates a hierarchy tailored for Sony A7 
%   camera data and Fusion IR data (including 'cam1' and 'cam2' subdirectories).
% * Safety Checks: Prevents overwriting existing directories, providing warnings
%   to protect data integrity.
% * User-Friendly: Requires a single input (absolute path to the parent directory).

%---------------------------------------------------------------------------
% Usage
%---------------------------------------------------------------------------
% Prerequisites:
% * Bash shell environment

% Instructions:
% 1. Download the script 
% 2. Make the script executable:
%    ```bash
%    chmod +x create_camera_dirs.sh
%    ```
% 3. Run the script, providing the parent directory path:
%    ```bash
%    ./create_IR_fs.sh /path/to/parent 
%    ``` 
%    Example: ./create_IR_fs.sh /home/user/CameraData/2024-04-03

%---------------------------------------------------------------------------
% License
%---------------------------------------------------------------------------
% This project is licensed under the MIT License - see the LICENSE file for details.
```

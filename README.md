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

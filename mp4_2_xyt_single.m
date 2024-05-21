function mp4_2_xyt_single(varargin)
%-------------------------------------------------------------------------------
% Function: mp4_2_xyt_single
%-------------------------------------------------------------------------------
%
% Nolan R. Bonnie, 04/2024
% nolan.bonnie@colorado.edu
%
% Purpose: 
%   * Wrapper to convert a single mp4 video into a MATLAB structure file (.mat) 
%     containing xyt coordinates of tracked fireflies.
%   * Requires explicit input and output file paths.
%   * Handles noise removal and data saving.
%
% Inputs:
%   * PATH: Full path to the input mp4 video file.
%   * OUT_PATH: Full path for the output .mat file (without extension).
%
% File Handling:
%   * Extracts folder path from input to add to MATLAB path.
%   * Handles potential user-provided extensions in the output path.
%-------------------------------------------------------------------------------

disp(nargin)
% Expects a user input for PATH, otherwise use default path
if nargin > 0
    PATH = varargin{1};
else
    PATH = "/Users/nbonnie/MATLAB/Test_Data/20990101/Sony_A7_Stereo_Raw/test.mp4";
end

% Grab folder path to add to MATLAB path
path_parts = strsplit(PATH, "/");
file_name = path_parts(end);
folder_parts = strsplit(PATH, file_name);
path_to_folder = folder_parts(1);

if nargin > 1
    OUT_PATH = varargin{2};
else
    OUT_PATH = "/Users/nbonnie/MATLAB/Test_Data/20990101/Sony_A7_Stereo_Raw/test_xyt.m";
end

% IF user provided extension
if length(strsplit(OUT_PATH, '.')) > 2
    error("CANNOT DETERMINE PATH: OUTPUT MUST NOT HAVE '.' OR AN EXTENSION")
elseif length(strsplit(OUT_PATH, '.')) > 1
    out_parts = strsplit(OUT_PATH, '.');
    OUT_PATH = out_parts(1);
    warning("Attempting to remove provided extension from output path, double check write path is correct.")
end

addpath(genpath(path_to_folder))

ff = fffabc(PATH);

disp(strcat("Writing xyt result to ",OUT_PATH))
save( OUT_PATH , 'ff');


end


%% track
function ff = fffabc(video_path)
%FFFABC Find FireFlies Adaptive Background Compensation
%
% Raphael Sarfati, 01/2022
% raphael.sarfati@aya.yale.edu
%
% Nolan R. Bonnie, Updated 04/2024
% nolan.bonnie@colorado.edu
%
%---------------------------------------------------------------------------
% Nested Function: fffabc 
%---------------------------------------------------------------------------
% Purpose: Processes a single video file for firefly tracking.
%
% Inputs:
%   * video_path: Path to the video file. 
%
% Processing Steps:
%   1. Reads the video.
%   2. Sets up parameters for processing.
%   3. Creates an initial background stack.
%   4. Processes each frame:
%       * Calculates dynamic background.
%       * Extracts foreground (potential fireflies).
%       * Filters foreground.
%       * Detects fireflies.
%       * Stores xyt coordinates and other data.
%---------------------------------------------------------------------------

%% Read in video
v = VideoReader(video_path);
disp(v)
frameRate = v.FrameRate;
disp("Video read in correctly")

%% processing parameters, can be changed
% blurring radius for frame processing (default = 1)
blurRadius = 1; %prm.trk.blurRadiusPxl;
% railing background window size, in seconds (default = 1)
bkgrWinWidthSec = 2; %prm.trk.bkgrStackSec; 
bwth = 0.1; %prm.trk.bwThr;
bkgrWinSize = bkgrWinWidthSec*frameRate;
disp(bkgrWinSize)

%% initial background stack
% create background stack

frmidx = 1;
% build initial background stack
while frmidx <= bkgrWinSize
    % read frame
    frame = readFrame(v);
    
    % use only green channel
    frame = frame(:,:,2);
    
    % use single precision, for speed
    frame = single(frame);
    
    % add to background stack
    bkgrStack(:,:,frmidx) = frame;
    
    % update frame counter
    frmidx = frmidx+1;
    
end
    
% frame index within the stack
bkgrIdx = 1:bkgrWinSize;

% initial background frame
bkgr = mean(bkgrStack,3);

% start time of processing
fprintf('\n')
disp(datetime('now'))
disp(strcat("Processing video at: ",video_path))

% initialize waitbar
w = waitbar(0,"Calculating...");

%% re-initialize movie since using readFrame
v = VideoReader(video_path);    
nFramesApprox = ceil(v.Duration*frameRate);
frmlocidx = 1;

%% processing movie

% process each frame
while hasFrame(v)
    
    % read frame
    newFrame = readFrame(v);
    
    % use only green channel
    newFrame = newFrame(:,:,2);
    
    % use single precision, for speed
    newFrame = single(newFrame);
    
    % calculate new bkgr from old and differential earliest/latest frames (for speed) 
    [~,m] = min(bkgrIdx);
    bkgr = bkgr + (newFrame - bkgrStack(:,:,m))/bkgrWinSize;
    
    % update stack with new frame replacing earliest frame
    bkgrStack(:,:,m) = newFrame;
    bkgrIdx(m) = frmidx;
    
    % grab current frame from stack
    currentFrameIdx = frmidx;
    f = (bkgrIdx == currentFrameIdx);
    currentFrame = bkgrStack(:,:,f);     
    
    % calculate foreground
    frgr = (currentFrame - bkgr);
    frgr = uint8(frgr);
    frgr = imgaussfilt(frgr,blurRadius);
    
    % binarize foreground and analyze connected components
    bw = imbinarize(frgr,bwth);
    rp = regionprops(bw,newFrame,'Centroid','Area','Eccentricity','MeanIntensity');
    
    n = length(rp);
    ff.n(currentFrameIdx) = n;
    ff.xy{currentFrameIdx} = [vertcat(rp.Centroid) repmat(currentFrameIdx,n,1)];
    ff.aei{currentFrameIdx} = [vertcat(rp.Area) vertcat(rp.Eccentricity) vertcat(rp.MeanIntensity) repmat(currentFrameIdx,n,1)];
    ff.i(currentFrameIdx) = mean(newFrame,'all'); %
    
    % progress
    try
        waitbar(frmlocidx/nFramesApprox, w, "Calculating...");
    catch
        continue
    end
    
    % update frame counter
    frmidx = frmidx+1;
    frmlocidx = frmlocidx+1;
       
end
close(w)


%% records all parameters
ff.xyt = vertcat(ff.xy{:}); %xyt coordinates
ff.aeit = vertcat(ff.aei{:}); %area & eccentricity for each flash
ff.processed = datetime('now'); %date & time processed
ff.bwth = bwth;
ff.blurRadius = blurRadius;
ff.bkgrWinWidthSec = bkgrWinWidthSec;
ff.bkgrStack = bkgrStack;
ff.bkgrIdx = bkgrIdx;
ff.mov = get(v{1});
%ff.code = fileread([mfilename('fullpath') '.m']);

% finish time
fprintf('\n')
disp(datetime('now'))

end

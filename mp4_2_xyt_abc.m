function mp4_2_xyt_abc(varargin)
%-------------------------------------------------------------------------------
% Function: mp4_2_xyt_abc
%-------------------------------------------------------------------------------
%
% Nolan R. Bonnie, 04/2024
% nolan.bonnie@colorado.edu
%
% Purpose: 
%   * Wrapper to convert raw mp4 videos into MATLAB structure files (.mat) 
%     containing xyt coordinates of tracked fireflies. 
%   * Handles specific file structure, noise removal, and data saving.
%
% Inputs:
%   * Optional:
%       * PATH: Base path for raw video data (default provided if none)
%
% File Structure:
%   * Expects input in: /PATH/Sony_A7_Stereo_Raw/cam1/ and .../cam2/
%   * Writes output to: /PATH/Sony_A7_Stereo_xyt/cam1/ and .../cam2/
%
% Note:
%   * Can work with different file systems, code will look for
%   /PATH/*Raw/cam1 and will write to /PATH/*xyt/cam1
%-------------------------------------------------------------------------------

% Expects a user input for PATH, otherwise use default path
if nargin > 0
    PATH = varargin{1};
else
    PATH = "/Users/nbonnie/MATLAB/Test_Data/20990101/Sony_A7_Stereo_Raw/";
end
parts = strsplit(PATH,"Raw");

% If unexpected file structure, append _xyt to whatever came before
if length(parts) == 1
    PATH = char(PATH);
    PATH(end) = '_';
    OUT_PATH = strcat(PATH,"xyt/");
else
    OUT_PATH = strcat(parts(1),"xyt/");
end

% Create output_path if doesn't exist
if ~exist(OUT_PATH, 'dir')
    disp(strcat("Creating directory for output at: ",OUT_PATH))
    mkdir(OUT_PATH);
end

% Have this as a user input 
cams = ["cam1/","cam2/"];
for cam = cams
    path_to_folder = strcat(PATH,cam);
    addpath(genpath(path_to_folder))
    fnames = dir(strcat(path_to_folder,"*.mp4"));
    if isempty(fnames)
        fnames = dir(strcat(path_to_folder,"*.MP4"));
    end
    disp(fnames)
    video_path = strcat(path_to_folder + fnames(1).name);
    ff = fffabc(video_path);
    
    % Create output path if doesn't exist
    if ~exist(strcat(OUT_PATH,cam), 'dir')
        disp(strcat("Creating directory for output at: ",strcat(OUT_PATH,cam)))
        mkdir(strcat(OUT_PATH,cam));
    end

    name_parts = strsplit(fnames(1).name, '.');
    disp(strcat("Writing xyt result to ",OUT_PATH, cam, name_parts{1},".m"))
    save( strcat(OUT_PATH, cam, name_parts{1}) , 'ff');


end

end


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

%% processing parameters, can be changed
% blurring radius for frame processing (default = 1)
blurRadius = 1; %prm.trk.blurRadiusPxl;
% railing background window size, in seconds (default = 1)
bkgrWinWidthSec = 2; %prm.trk.bkgrStackSec; 
bwth = 0.1; %prm.trk.bwThr;
bkgrWinSize = bkgrWinWidthSec*frameRate;

disp(frameRate)
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

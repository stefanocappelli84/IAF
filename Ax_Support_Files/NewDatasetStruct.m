% This function creates the skeleton of the data struct
function NewDataset = NewDatasetStruct()


% Overview of the dataset structure

% Dataset
%  > Frame(i)               :: All frames in the experiment
%    > Population(i)        :: Population of certain type of particles
%      > Object(i)          :: Every object

%  > Camera                 :: Properties of the camera used in the
%                               experiment

%  > Settings               :: Settings used in the analysis
%    > BeadTemplate         :: Particle template specific settings
%    > HT                   :: Hough transform settings
%    > HTFilter             :: ???

% Future log system

%  > Log                    :: Place for logs to be saved
%    > General              :: General/main log
%    > Functionlog(i).Log   :: Logfiles for the subfunctions used


NewDataset = struct();

%%%%%%%%%%%%%%%%% STEP 0 %%%%%%%%%%%%%%%%%%%%%%%

NewDataset.N_Frames = [];           % Total number of Frames [int]
% NewDataset.FPS = [];                % Frame number [int] :: dropped in
%   favour of NewDataset.Camera.FPS
NewDataset.Path = '';               % Main path of the location of the movies [char]
NewDataset.Date = datestr(now);     % Dataset creation date
NewDataset.Comment = '';

NewDataset.Frame.Time = [];        % Time in seconds
NewDataset.Frame(1).Filename = ''; % Name of each frame selected - vector of strings (the index is refferred to .Frame(i))

%%%%%%%%%%%%%%%%% STEP 1 %%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%% STEP 2 %%%%%%%%%%%%%%%%%%%%%%%

NewDataset.Frame(1).Population(1).N_Object = []; % Number of object of that population per frame [int]
NewDataset.Frame(1).Population(1).Location = []; %
NewDataset.Frame(1).Population(1).Radius = []; %
NewDataset.Frame(1).Population(1).Name = '';

%---------------% STEP 2A %---------------%

% Definition of the structure used by CreateBeadTemplate

NewDataset.Settings.BeadTemplate.Radius = [];
NewDataset.Settings.BeadTemplate.Center = [];
NewDataset.Settings.BeadTemplate.ROI = [];
NewDataset.Settings.BeadTemplate.sizeROI = [];
NewDataset.Settings.BeadTemplate.CenterValue = [];
NewDataset.Settings.BeadTemplate.EdgeValue = [];

% Parameters needed for the hough transform - these are the output of
% SetHough(Dataset)

NewDataset.Settings.HT.RadRange = [];
NewDataset.Settings.HT.GradBest = [];
NewDataset.Settings.HT.ShapeBest = [];
NewDataset.Settings.HTFilter.FilterType = '';
NewDataset.Settings.HTFilter.FilterSize = [];
NewDataset.Settings.HTFilter.Imadjust = [];

%%%%%%%%%%%%%%%%% STEP 3 %%%%%%%%%%%%%%%%%%%%%%%

% For data analysis
NewDataset.Frame(1).Population(1).Object(1).Centroid = []; % Coordinate of the center point
NewDataset.Frame(1).Population(1).Object(1).Radius = []; % Particle radius
NewDataset.Frame(1).Population(1).PopName = ''; % Name of the population

%%% Definition of setup parameters

% Details of the Camera used
NewDataset.Camera.Name = ''; % name of the camera
NewDataset.Camera.FPS = []; % Recorded frame per second
NewDataset.Camera.xPIX = []; % Size of a pixel in the image in the x-direction
NewDataset.Camera.yPIX = []; % Size of a pixel in the image in the y-direction

% Definition of log
NewDataset.Log.General = StartLog('General dataset log');
% NewDataset.Log.Functionlog(i).Log         :: Defined using the
%                                              AddLogToDataset function
end
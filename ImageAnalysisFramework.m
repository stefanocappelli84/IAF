%% Main script for the image analysis framework (IAF)
%
% This script defines the structure used within the IAF
%
% The modules of the IAF are defined in the code below in the therefore
% indicated locations. Do not edit the rest of the code!

%% General information
%
% The IAF has 5 main steps:
%%
%
% * Step 0: Define dataset
% * Step 1: Image prepocessing (filtering, etc...)
% * Step 2A: Bead locating
% * Step 2B: Bead analysis
% * Step 3: Data analysis
%
% Every step is performed by one or more module(s). A module is a stand-
% alone Matlab function that performs a certain operation on the data. The
% input and output of the modules is highly regulated to keep all the
% modules cross-compartible. Refer to the IAF documentation when you want
% to write/change a module to keep everything compatible.
%
% The data transfer in the IAF is performed by matlab structs. The basic
% structure of the data structs used in IAF is well defined, but can be
% easily extended. Again refer to the documentation.

%% Initializing dataset
%
% Define the (minimal) skeleton of the dataset struct. The dataset struct contains
% the general experimental information and the information about the
% frames.
Dataset = [];
Dataset = NewDatasetStruct(); % Do NOT edit this line
%Dataset.N_Frames = 1;
% Call the module function(s) that perform step 0:
Dataset = LoadDataset(Dataset);

close all;

% Extract the bead profile:
Dataset = CreateBeadTemplate(Dataset, 1);
% Fit the bead profile with Gaussians
Dataset = FitGaussians(Dataset);

%% Frame processing
%
% Perform steps 1 through 2B one by one on the frames
tic
for i_Frame = 1:Dataset.N_Frames % Do NOT edit this line
    
    workbar(i_Frame/Dataset.N_Frames,'Performing Image Analysis')
    
    % FILE LOADING
    % Call the module that loads the file associated with the frame
    % EXAMPLE: FrameData = IAF_LoadFrame(Dataset.Frames(i_Frame).Filename);
%     tic
    FrameData = double(IAF_LoadFrame(Dataset, i_Frame));
    if numel(size(FrameData)) == 3
        FrameData = rgb2gray(FrameData(:,:,1:3));
    end
%     toc
    
    % STEP 1
    % Call the preprocessing modules
    % EXAMPLE: FrameData = PreProcessingModule(FrameData)
    FrameData = BackgroundCorrection_HistogramMaximum(FrameData);
    
    % STEP 2A
    % Call the bead locating modules and save the result
    % EXAMPLE: Beads = LocateBeadsConvolution(FrameData)
    Population = LocateBeadsProfile(FrameData, Dataset.BeadTemplate.BeadFilter, false);
    
    % STEP 2B
    % Call the modules that extracts the relevant information about the
    % beads. The extracted data is placed in the beads struct.
    % EXAMPLE: Beads = BeadCentroidByGaussFit(Beads, FrameData)
    Population = Centroid_CenterOfMass(Population, FrameData, [21 21]);
    
    % Save the bead data in the general data structure
    Dataset.Frame(i_Frame).Population = Population; % Do NOT edit this line
    Dataset.Frame(i_Frame).Population.PopulationName = 'Tracked particles';
    
end % Do NOT edit this line
toc

%% Data analysis
%
% Step 3
% Perform the relevant analysis on the obtained data
% EXAMPLE: Result = TrackBeadsInTime(Dataset);

% Correlate the locations 
Result = CorrelateLocations(Dataset, 1, 20);




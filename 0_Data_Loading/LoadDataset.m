function Dataset=LoadDataset(Dataset, varargin)
% The user select all the images in the SAME FOLDER to be further analyzed.
% In this first version the selecltion is limited to files in the same
% folder.
% This function returns some of the parameters described by the struct
% Dataset.

% FPS NEEDS TO BE REMOVED LATER ON

% if nargin==1
%     FPS=1; % it prevents to divide by zero later when calculating the time for each frame
%     display('FPS not defined! initialized to 1.');
% end


%% Either read the provided filenames and the path, or ask for them using a dialog

if nargin == 3
    fileselector = varargin{1};
    path = varargin{2};
    
    cd(path);
    [file, path] = uigetfile(fileselector,'Select all the frames to be analyzed','MultiSelect','on');
    
else
    [file, path] = uigetfile('*.tif','Select all the frames to be analyzed','MultiSelect','on');
end

if ~iscell(file) && ~isstr(file)
    
    disp('File selection canceled');
    Dataset = 0;    
    
else
    
    
    Dataset.Path = path;
    if ischar(file);
        file = {file};
    end
    
    
    Dataset.N_Frames = numel(file);
    
%     Dataset.Camera.FPS = FPS;
    
    Dataset.Frame(1).Time = 0; % The first frame is the reference/starting frame and it is initialized at 0 sec
    
    % Read all the filenames and store it in Dataset.Frames(i).Filename
    for i=1:Dataset.N_Frames
        Dataset.Frame(i).Filename = file{i};
        %      Dataset.Frame(i).Time = (i-1)./Dataset.Camera.FPS; %In this way the time is computed considering the first frame to be at 0 sec
    end
   

end
function OutputLog(Log, varargin)

% Input
%
%   Three input options:
%       OutputLog(Log)              :: Write log to command line
%       OutputLog(Log, Filename)    :: Write log to file
%       OutputLog(Log, false, fileHandle)   :: Write log to provided file
%                                               handle
% 
%   Log         :: Log to output (cell array)
%   Filename    :: Filename that should be written (string)
%   fileHandle  :: 
%       
%     > Set to false if the function should write to a file (using the
%       fprintf function) with the provided handle

% Check input
narginchk(1,3);


N_Lines = numel(Log);

% Plot to command line if no filename provided
if nargin == 1
    for i_ndex = 1:N_Lines
        disp(Log{i_ndex});
    end
end

if nargin > 1
    
    % Open and close file?
    DoOpenCloseFile = true;
    if islogical(varargin{1}) && varargin{1} == false
        if isnumeric(varargin{2})
            DoOpenCloseFile = false;
            fileHandle = varargin{2};
        else
            error('IAF:OutputLog', 'Invalid filehandle');
        end
    end
    
    if DoOpenCloseFile
        if ischar(varargin{1})
            FileName = varargin{1};
        else
            error('IAF:OutputLog','Filename is not a string! Check you input');
        end
    end
    
    % Write log
    try
        if DoOpenCloseFile
            fileHandle = fopen(FileName,'w');
        end
        for i_ndex = 1:N_Lines
            fprintf(fileHandle, [Log{i_ndex} '\n']);
        end
        if DoOpenCloseFile
            fclose(fileHandle);
        end
    catch
        error('IAF:OutputLog','Cold not write log to file!');
    end
end
function OutputDatasetLog(Dataset, varargin)

% Writes out the complete log of the Dataset
%
%   Two input options:
%       OutputLog(Log)              :: Write log to command line
%       OutputLog(Log, Filename)    :: Write log to file

%   Dataset     :: The dataset of which the log should be written
%   Filename    :: If set contains the filename in which the log is saved (string)

narginchk(1,2);

if isfield(Dataset.Log, 'Functionlog')
    N_FunctionLogs = numel(Dataset.Log.Functionlog);
else
    N_FunctionLogs = 0;
end

% Output to command lone
if nargin == 1
    OutputLog(Dataset.Log.General);
    
    disp('------------------');
    
    if N_FunctionLogs
        for i_ndex = 1:N_FunctionLogs
            disp(['Functionlog ' num2str(i_ndex) '/' num2str(N_FunctionLogs)]);
            OutputLog(Dataset.Log.Functionlog(i_ndex).Log);
            disp('------------------');
        end
    end
    
end

% Output to file
if nargin == 2
    
    if ischar(varargin{1})
        FileName = varargin{1};
    else
        error('IAF:OutputDatasetLog','Filename is not a string! Check you input');
    end
    
    try
        fileHandle = fopen(FileName, 'w');
        OutputLog(Dataset.Log.General, false, fileHandle);
        fprintf(fileHandle, '------------------');
        
        if N_FunctionLogs
            for i_ndex = 1:N_FunctionLogs
                fprintf(fileHandle, ['Functionlog ' num2str(i_ndex) '/' num2str(N_FunctionLogs)]);
                OutputLog(Dataset.Log.Functionlog(i_ndex).Log, false, fileHandle);
                fprintf(fileHandle, '------------------');
            end
        end
        fclose(fileHandle);
    catch
        error('IAF:OutputDatasetLog','Could not write file');
    end
    
    
end



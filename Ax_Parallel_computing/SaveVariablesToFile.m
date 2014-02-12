function SaveVariablesToFile(File, varargin)
% This function is functially a copy of the matlab save function. It is
% usefull if you want to save any variables from inside a parfor loop to
% negate the transparency issue you get trying to save directly from a 
% parallel loop.

% Input: 
%   File :: Filename to save to (relative or absolute path)
%   Varargin :: List of variable names (string) and values to save. 

% Example:
%   SaveTheseVariables(['Data.mat'], 'Density', Density, 'Name', 'Experiment 12-5', 'Number', 10);
%       Will save the Density a string and the number 10 to file.



% Check variable input
N_VariablesToSafe = (nargin - 1) / 2;
% Is there something to safe?
if N_VariablesToSafe == 0
    error('No variables to safe');
end
% Filename check
if ~ischar(File)
    error('Filename is not properly assigned');
end
% Check for even number of varargin
if mod(nargin, 2) ~= 1
    error('Unbalanced number of input parameters');
end
%Check that input is paired in string-value pairs
for i_ndex = 1:N_VariablesToSafe
    if ~ischar(varargin{i_ndex*2-1})
        error('Input should contain pairs of the variable name (string) and variable value.');
    end
end

% Initiate variable list
VariableList = '';

% Place the variables in the workspace under the correct name
try
    for i_ndex = 1:N_VariablesToSafe
        eval([varargin{i_ndex*2-1} ' = varargin{i_ndex*2};']);
        VariableList = [VariableList ', ''' varargin{i_ndex*2-1} ''''];
    end
catch
    error('Something went wrong - sorry ''bout that. Is the input correct?');
end

% Save them

try
    eval(['save(''' File '''' VariableList ');']);
catch
    error(['Did not manage to save to file ' File]);
end

end
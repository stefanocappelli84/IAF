function Log = WriteToLog(Log, Line, varargin)
% Simple command to add a line to the log
%
% Input
%  Log - Logfile (cell array - started by function StartLog)
%  Line - Text to add
%  varargin - true if a timestamp should be included
% 
% Output
%  Log - The log file

if nargin == 3 & varargin{1} == true
    Log{end+1} = [datestr(now) ' :: ' Line];
else
    Log{end+1} = [Line];
end

end
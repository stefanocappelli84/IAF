%% function ExtractDataFromStruct
%
% Extract data from the specified data structure (a Matlab struct)
%
% --Input: 
% StructuredData :: Struct containing data
% varargin :: Fieldname to be extracted (multiple in cell array)

% The function can extract several fields simultaneous of numerical data
% types. For not numerical data types the data is extracted as a cell array

% Examples:
%   YieldMatrix(pets, 'WeightInKg'); Result: numerical column vector of the 
%       weights
%   YieldMatrix(pets, 'Color', 'Species', 'WeightInKg'); Result: cell
%       array with the requested fields in the columns
%   YieldMatrix(pets, 'Picture'); 
%       With Picture a 2D numerical matrix
%       Result: 3D numerical matrix with Result(1,:,:) containing the first
%       picture
%   YieldMatrix(pets, 'Density'); 
%       With Picture a 3D numerical matrix
%       Result: 4D numerical matrix with Result(1,:,:,:) containing the first
%       density matrix
%

function [YieldedMatrix] = ExtractDataFromStruct(StructuredData, varargin)

N = numel(StructuredData);

if nargin < 2
    error('Not enough parameters in function YieldMatrix');
end

if nargin == 2
    % Single variable field to extract    
    FieldName = varargin{1};
    
    VariableType = class(StructuredData(1).(FieldName));
    VariableSize = size(StructuredData(1).(FieldName));
    
    N_elements = prod(VariableSize);
    
    isNumeric = isnumeric(StructuredData(1).(FieldName));
    
    if isNumeric
        YieldedMatrix = zeros([VariableSize, N], VariableType);
    else
        YieldedMatrix = cell([1, N]);
    end
    
    if isNumeric
        for i_ndex = 1:N
            IndexStart = 1 + N_elements .* (i_ndex - 1);
            IndexEnd = IndexStart + N_elements - 1;
            YieldedMatrix(IndexStart:IndexEnd) = StructuredData(i_ndex).(FieldName);
        end
    else
        for i_ndex = 1:N
            YieldedMatrix{i_ndex} = StructuredData(i_ndex).(FieldName);
        end
    end
        
    N_dimensions = numel(size(YieldedMatrix));
    
    if N_dimensions > 1
        YieldedMatrix = permute(YieldedMatrix, [N_dimensions 1:(N_dimensions-1)]);
    end    
    
    YieldedMatrix = squeeze(YieldedMatrix);
    
end

if nargin > 2
    % Extract several fields
    N_Fields = numel(varargin);    
    
    % Count datatypes
    N_NotNumeric = 0;
    N_Integer = 0;
    N_Float = 0;
    for i_ndex = 1:N_Fields
        FieldName = varargin{i_ndex};
        N_NotNumeric = N_NotNumeric + ~isnumeric(StructuredData(1).(FieldName));
        N_Integer = N_Integer + isinteger(StructuredData(1).(FieldName));
        N_Float = N_Float + isfloat(StructuredData(1).(FieldName));
    end
    N_Numeric = N_Integer + N_Float;
    
    % Should be all either numeric else use cell - array
    if ~(N_NotNumeric == N_Fields || N_Numeric == N_Fields)
        warning('Mixture of datatypes will be extracted in the form of a cell array');
    end
    
    
    if N_Numeric == N_Fields; % For numeric data
        % Prepare matrix
        if N_Float > 0
            YieldedMatrix = zeros([N N_Fields], 'double');
        else            
            YieldedMatrix = zeros([N N_Fields], 'int64');
        end
        
        % Fetch data
        for j_ndex = 1:N_Fields
            FieldName = varargin{j_ndex};            
            for i_ndex = 1:N
                YieldedMatrix(i_ndex,j_ndex) = StructuredData(i_ndex).(FieldName);
            end
        end
    
    else % For other data types - use cell array
        % Prepare matrix
        YieldedMatrix = cell([N N_Fields]);
        % Fetch data
        for j_ndex = 1:N_Fields
            FieldName = varargin{j_ndex};
            for i_ndex = 1:N
                YieldedMatrix{i_ndex,j_ndex} = StructuredData(i_ndex).(FieldName);
            end
        end
    end
end

end
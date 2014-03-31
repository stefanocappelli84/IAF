function ImageFrame = PreProcessingModuleV4(ImageFrame,FilterList,varargin)
% ImageFrame = PreProcessingModuleV2(ImageFrame,FilterList,varargin) 
% performs image filtering on ImageFrame according to sequence of parameters 
% defined in FilterList.
% 
% FilterList is a cell array defined as:
%   FilterList = {...
%                  {'FilterName1',FilterParameters1};...
%                  {'FilterName2',FilterParameters2};...
%                 ...
%                };
%                 
% This function can be easily extended by adding the desired 'case' in the switch main
% function.
% 
% ************************ EXAMPLE ************************
% 
% FilterList = {...
%                {'invert'};...
%                {'imadjust',[0; 1],[0; 1]};...
%                {'gaussian', [3 3], 1};...
%                {'wiener2',[5 5]};...
%                {'unsharp',0.3};...
%               };
% ImageFrame = PreProcessingModuleV4(ImageFrame,FilterList);
% 
% ************************************************************** %
% Author: Stefano Cappelli
% Date: 18/03/2014
% Version: 4.0
% 
% MODIFICATION HISTORY:
% 
% Changes from version 3.0.
%     - There is no need anymore of the function SetPreProcessingModuleV2.
%       The list of parameters is passed to this function. The tunction SetPP will still
%       be used, but just for saving the list of parameters used in the pre-processing
%       step. The aim of this upgrade is to make the code more immidiate and readable.
%     
% 
% ---------------------------------------------------------------------- %
% 
% ************************* TO BE IMPLEMENTED ************************* %
% - It gives an error when no parameters are specified.
% ********************************************************************* %


%% ================== Validating input arguments ================== %%
if ~ismatrix(ImageFrame) || ~isnumeric(ImageFrame),
    error('PreProcessingModule: ''FrameData'' has to be 2 dimensional image');
end
% 
% %% ================== Extract the parameters ================== %%

[FilterSequence, FilterParameters ] = parse_inputs(FilterList);
N_FilterSteps = length(FilterSequence);

%======================================================================

%% ================== Image Filtering ================== %%

T = ImageFrame;
for i = 1:N_FilterSteps
    
    filter_name = FilterSequence{i};
    filter_param = build_filter_param(FilterParameters{i,:});          
          
    
    switch filter_name
    % --------- 'fspecial' --------- %
        case {'average','disk','gaussian','laplacian','log','motion',...
              'prewitt','sobel','unsharp'}         
          filter = fspecial(filter_name,filter_param{:});
          ImageFrame = imfilter(ImageFrame,filter);
    % --------- 'imadjust' --------- % 
        case {'imadjust'}
          ImageFrame = imadjust(ImageFrame,filter_param{:});
    % --------- 'Background correction' --------- %      
        case {'BKGSub'}
          BFS = strel('square',Dataset.BeadTemplate.Radius*2+4);
          BCK = imopen(ImageFrame,BFS);
          ImageFrame = ImageFrame - BCK;
          ImageFrame = uint8(ImageFrame);
    % --------- 'Noise reduction: wiener' --------- %      
        case {'wiener2'}
            ImageFrame = wiener2(ImageFrame,filter_param{:});
    % --------- 'Gradient' --------- %      
        case {'gradient'}
            ImageFrame = imgradient(ImageFrame,filter_param{:});
            ImageFrame = ImageFrame./max(ImageFrame(:)).*255;
            ImageFrame = uint8(ImageFrame);
    % --------- 'Invert' --------- %
        case {'invert'}
            ImageFrame = imcomplement(ImageFrame);
    % --------- 'Threshold' --------- %
        case {'threshold'}
            ImageFrame = im2bw(ImageFrame,filter_param{:});
    % --------- WRONG SELECTION --------- %      
        otherwise
          disp('WARNING in PreProcessingModule: Filter type not recognized!!!')
    end
 
    if ~isempty(varargin) && varargin{1} ~= false
        showimg(ImageFrame);
        title(strcat('Image filtered with method: ',filter_name));
        pause;
    end
end

% --- Show the original and processed image
if ~isempty(varargin)
    figure;
    subplot 121; imagesc(T);colormap('gray'); axis image;
    title('Original image');
    subplot 122; imagesc(ImageFrame);colormap('gray'); axis image;
    title('Processed image');
end


%======================================================================

%----------- Supporting Functions ------------ %
function [FilterName, FilterParameters ] = parse_inputs(FilterList)
    for k=1:size(FilterList,1)
        filt_temp = FilterList{k};
        J = size(filt_temp,2);
        FilterName{k} = filt_temp{1};        
        for jj = 2:J
            FilterParameters{k,jj-1} = filt_temp{jj};
        end
    end
end
%----------- Supporting Functions ------------ %
function filter = build_filter_param(varargin)
    % Concatenate non-empty cell arrays
    k = 1;
        for j=1:length(varargin)
            if ~isempty(varargin{j})
                filter{k} = varargin{j};                    
                k=k+1;
            else
                continue;
            end
        end
        if k==1
            filter = {};
        end
end


end

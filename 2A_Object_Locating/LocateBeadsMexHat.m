%% Locate beads in a still image frame
%
% The coordinate system used is a MATLAB matrix coordinate system with %X=Y=0%
% in the top left corner of the image! (Row, Column)


function [Population] = LocateBeadsMexHat(ImageFrame, Parameters, PlotStuff)

%% General settings
% Width of the pointspread function (pixels)
PSF_width_centerpeak = Parameters(1);
PSF_ampl_centerpeak = Parameters(2);
PSF_width_darkring = Parameters(3);
PSF_ampl_darkring = Parameters(4);
% Size of the PSF and the ROI size around the bead (pixels x pixels)
% Must be equal and uneven values
ROI_Size = [31 31];



%% Coarse location of beads
% Construct an image of a point source of light with no pixel offset
BeadImage = PSF_ampl_centerpeak .* PointSpreadFunction([0, 0], PSF_width_centerpeak, ROI_Size) - ...
    PSF_ampl_darkring .* PointSpreadFunction([0, 0], PSF_width_darkring, ROI_Size);
% BeadImage = BeadImage - sum(sum(BeadImage)) / (ROI_Size(1) * ROI_Size(2));


% Convolute with image
ImageFrameConvolution = conv2(double(ImageFrame), double(BeadImage), 'same');
% Find local maxima
LocalPeaks = imregionalmax(ImageFrameConvolution, 8);

% Determine the strongest correlation between the constructed bead image
% and the observed frame image. The correlation between the
% constructed bead image and the image has to be EdgeDetectionLimit *
% MaxConvolution to be regarded as a bead
MaxConvolution = max(max(ImageFrameConvolution));
MinimumCorrelationFraction = 0.25;
% A similar check is done locally:
MinimumLocalCorrelationFraction = 0.7;
% Find beads and count the number of found ones
Beads = (ImageFrameConvolution .* LocalPeaks) > MinimumCorrelationFraction * MaxConvolution;
% Roughly count the number of beads in the frame
N_Beads = sum(sum(Beads));
% Store bead locations in matrix
Coordinates = zeros(N_Beads, 2);


% ROI radius
ROI_R = floor((ROI_Size - 1) / 2);

% Prepare the mask for the local maximum test 
[X, Y] = meshgrid(1:ROI_Size(1), 1:ROI_Size(2));
X = X - ROI_R(1) - 1;
Y = Y - ROI_R(2) - 1;
LocalMaximumMask = sqrt(X.^2 + Y.^2) < ROI_R(1);

% The running index for the beads
i_FoundBead = 1;

% Loop over the whole image and store the bead locations
for my = 6:(size(ImageFrameConvolution, 1)-5)
    for nx = 6:(size(ImageFrameConvolution, 2)-5)
        if Beads(my,nx)
            
            % Determine the ROI boundaries
            ROI_X_Min = round(nx - ROI_R(1));
            ROI_X_Max = round(nx + ROI_R(1));
            ROI_Y_Min = round(my - ROI_R(2));
            ROI_Y_Max = round(my + ROI_R(2));
            
            % Flag to indicate edge objects (ROI intersects edge)
            Edge = false;
            % Raise flag if object is at the edge
            
            if ROI_X_Min < 1
                ROI_X_Min = 1;
                Edge = true;
            end
            if ROI_X_Max > size(ImageFrame, 2)
                ROI_X_Max = size(ImageFrame, 2);
                Edge = true;
            end
            if ROI_Y_Min < 1
                ROI_Y_Min = 1;
                Edge = true;
            end
            if ROI_Y_Max > size(ImageFrame, 1)
                ROI_Y_Max = size(ImageFrame, 1);
                Edge = true;
            end
            
            % If a bead is close to the edge, ignore it
            if ~Edge
                LocalMaximum = max(max(LocalMaximumMask.*ImageFrameConvolution(ROI_Y_Min:ROI_Y_Max, ROI_X_Min:ROI_X_Max)));
                
                % Check if the local maximum is >
                % MinimumLocalCorrelationFraction * LocalMaximum;
                if ImageFrameConvolution(my,nx) > MinimumLocalCorrelationFraction * LocalMaximum;
                    Coordinates(i_FoundBead, :) = [nx, my];
                    % FoundBeads{Col}.Center = [nx, my];
                    i_FoundBead = i_FoundBead + 1;
                end
                
                if PlotStuff
                    ROI_Bead = double(ImageFrame(ROI_Y_Min:ROI_Y_Max, ROI_X_Min:ROI_X_Max));
                end
            end
            
        end
    end
end


% Save the number of found objects
Population.N_Object = i_FoundBead - 1;
Population.Location = Coordinates(1:Population.N_Object, :);

% Plot the final result if requested

if PlotStuff
    figure;
    % Plot convolution
    subplot(1,2,1);
    imagesc(ImageFrame);
    title('Image', 'FontSize', 16);
    axis image;
    subplot(1,2,2);
    imagesc(ImageFrameConvolution);
    hold on;
    axis image;
    xlabel('X coordinate', 'FontSize', 16);
    ylabel('Y coordinate', 'FontSize', 16);
    title('Convolution', 'FontSize', 16);
    % Annote found beads
%     for my = 1:size(ImageFrameConvolution, 1)
%         for nx = 1:size(ImageFrameConvolution, 2)
%             if Beads(my,nx)
%                 scatter(nx, my, 300, 'or');
%             end
%         end
%     end
    for i = 1:Population.N_Object
        
        scatter(Population.Location(i, 1), Population.Location(i, 2), 300, 'or')
        
    end
    % Also plot the constructed bead image
    h = axes('Position', [.1 .75 .2 .2], 'Layer', 'Top');
    imagesc(BeadImage);
    axis(h, 'off', 'image');
    title(h, 'BeadImage', 'FontSize', 10);
    
    h = axes('Position', [.4 .75 .2 .2], 'Layer', 'Top');
    imagesc(ROI_Bead);
    axis(h, 'off', 'image');
    title(h, 'ROI cutout', 'FontSize', 10);
end

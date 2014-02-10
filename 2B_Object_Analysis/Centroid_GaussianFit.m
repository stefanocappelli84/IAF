function [Population] = Centroid_GaussianFit(Population, FrameData, ROI_Size, PSF_width, PlotStuff)

N_Objects = size(Population.Location, 1);

if not(mod(ROI_Size(1), 2) == 1) || not(mod(ROI_Size(2), 2) == 1)
    disp('Warning: ROI with even dimensions. ROI will be rounded to nearest integer pixel value!');
end

for i_Object = 1:N_Objects;
    % Determine the coordinates of the region of interest around the Object    
    ROI_R = (ROI_Size - 1) / 2;
    Offset = 0;
    ROI_X_Min = round(Population.Location(i_Object, 1) - ROI_R(1)) + Offset;
    ROI_X_Max = round(Population.Location(i_Object, 1) + ROI_R(1)) + Offset;
    ROI_Y_Min = round(Population.Location(i_Object, 2) - ROI_R(2)) + Offset;
    ROI_Y_Max = round(Population.Location(i_Object, 2) + ROI_R(2)) + Offset;
    
    if ROI_X_Min < 1 
        ROI_X_Min = 1;
    end
    if ROI_X_Max > size(FrameData, 2) 
        ROI_X_Max = size(FrameData, 2);
    end
    if ROI_Y_Min < 1 
        ROI_Y_Min = 1;
    end
    if ROI_Y_Max > size(FrameData, 1) 
        ROI_Y_Max = size(FrameData, 1);
    end
    
    ROI = FrameData(ROI_Y_Min:ROI_Y_Max, ROI_X_Min:ROI_X_Max);
    %ROI = abs(ROI);
%     ROI_Cutoff = 0.05*max(max(ROI));
%     ROI_Mask = ROI > ROI_Cutoff;
%     ROI = ROI_Mask .* (ROI - ROI_Cutoff);
    
    %imagesc(ROI); colorbar;
          
    
    % Initialize variables
    Offset = [0 0];    
    
    % Initialize convolution matrix
    Convolution = zeros(11, 11);
    Convolution_Width = zeros(1,11);
    
    % Iterate
    % Iterations are performed in a square grid around the then best
    % estimate of the bead location. Every iteration zooms in a factor 10
    % as described by the StepSize in the first for loop
    % The best estimate of the bead location is taken to be the one where
    % the correlation is at its maximum.
    for StepSize = [1 .1 .01 .001]
        % Cart. coordinate LUT
        X = (-1:0.2:1) .* StepSize;
        Y = (1:-.2:-1) .* StepSize;
        % Calculate the 2D convolution matrix
        for Col = 1:11
            for Row = 1:11
                % Offset within the convolution
                Convolution_Offset = Offset + [X(Col), Y(Row)];
                % Construct the (simulated) bead image
                GaussShapeImage = PointSpreadFunction(Convolution_Offset, PSF_width, ROI_Size);
                % Calculate the convolution value for this offset
                Convolution(Row, Col) = sum(sum(GaussShapeImage .* ROI));
            end
        end
        % Determine the (Row,Column) coordinate of the highest convolution
        % value
        [MaxOfColumn, I_Row] = max(Convolution);
        [~, I_Column] = max(MaxOfColumn);
        I_Row = I_Row(I_Column);
        % Determine the now best estimate of the bead location
        Offset = Offset + [X(I_Column), Y(I_Row)];
        
%         % Determine the right width of the PSF
%         S = (-1:0.2:1) .* StepSize .* 10;
%         for Sigma = 1:11
%             PSF_width_offset = PSF_width + S(Sigma);
%             if PSF_width_offset >= 2
%                 % Construct the (simulated) bead image
%                 BeadImage = PointSpreadFunction(Offset, PSF_width_offset, ROI_Size);
%                 
%                 % Calculate the convolution value for this offset
%                 Convolution_Width(Sigma) = sum(sum(BeadImage .* BeadData));    
%                 
%                 % Determine difference between 
%                 Factor = Convolution_Width(Sigma) ./ sum(sum(BeadImage.*BeadImage));
%                 LeftOvers = BeadData - Factor .* BeadImage;
%                 ChiSq(Sigma) = sum(sum((LeftOvers).^2));
%             else 
%                 ChiSq(Sigma) = inf;
%             end
%         end
%         % Determine the width of the PSF with the most overlap with the
%         % bead
%         % [~, I_Sigma] = max(Convolution_Width);
%         [~, I_Sigma] = min(ChiSq);
%         PSF_width = PSF_width + S(I_Sigma);
        
    end
    % Store the best location estimation
    Coordinates(1) = Population.Location(i_Object, 1) + Offset(1);
    Coordinates(2) = Population.Location(i_Object, 2) - Offset(2);
    
    
    Population.Object(i_Object).Centroid = [Coordinates(1), Coordinates(2)];

end

Population.N_Objects = N_Objects;

%plot the last convolution stuff if asked for

    
    if PlotStuff
        figure;
        subplot(1,2,1);
        imagesc(ROI); axis square; hold on; title('ROI of object');
        subplot(1,2,2);        
        imagesc(GaussShapeImage); axis square; title('Gaussian shape');
    end

end

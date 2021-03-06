function [Population] = Centroid_MexHatFit(Population, FrameData, ROI_Size, Radii, PlotStuff)

DirectionalFitting = true;
FullConvolution = false;


% Width of the pointspread function (pixels)
PSF_width_centerpeak = Radii(1);
PSF_width_darkring = Radii(2);

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
    
    % Flag to indicate edge objects (ROI intersects edge)
    Edge = false;
    % Raise flag if object is at the edge
    
    if ROI_X_Min < 1
        ROI_X_Min = 1;
        Edge = true;
    end
    if ROI_X_Max > size(FrameData, 2)
        ROI_X_Max = size(FrameData, 2);
        Edge = true;
    end
    if ROI_Y_Min < 1
        ROI_Y_Min = 1;
        Edge = true;
    end
    if ROI_Y_Max > size(FrameData, 1)
        ROI_Y_Max = size(FrameData, 1);
        Edge = true;
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
    Convolution_Width = zeros(1,11);
    
    % Iterate
    % Iterations are performed in a square grid around the then best
    % estimate of the bead location. Every iteration zooms in a factor 10
    % as described by the StepSize in the first for loop
    % The best estimate of the bead location is taken to be the one where
    % the correlation is at its maximum.
    % Don't analyze edge objects
    if ~Edge
        
        for StepSize = [1 .1 .01 .001]
            
            % Cart. coordinate LUT
            X = (-1:0.2:1) .* StepSize;
            Y = (1:-.2:-1) .* StepSize;
            
            if DirectionalFitting
                % Stop indicator
                stop = false;
                BestCorrelation = 0;
                Convolution = zeros(11, 11);
                
                % 'Smart' random walk method
                % [Col, Row] is the current best correlation
                % [TryCol, TryRow] is the next trial location
                Col = 6; Row = 6;
                TryCol = 6; TryRow = 6;
                BestCol = 6; BestRow = 6;
                
                % Direction
                % Try first in the horizontal direction (j)
                DirectionJ = 1;
                DirectionI = 0;
                
                
                
                while ~stop
                    
                    % Find the direction to try the fits
                    for NextBetPosition = -1:1:1
                        
                        if DirectionJ ~= 0
                            % Horizontal trials
                            TryCol = Col + NextBetPosition;
                            TryRow = Row;
                        else
                            % Vertical trials
                            TryCol = Col;
                            TryRow = Row + NextBetPosition;
                        end
                        
                        EdgeTry = TryCol == 12 || TryRow == 12 || TryCol == 0 || TryRow == 0;
                        
                        if ~EdgeTry
                            Convolution_Offset = Offset + [X(TryCol), Y(TryRow)];
                            Convolution(TryRow, TryCol) = CorrelationValue(ROI, Convolution_Offset, ROI_Size);
                            % Pick the direction with the highest correlation
                            if (Convolution(TryRow, TryCol) > BestCorrelation)
                                BestCorrelation = max(max(Convolution));
                            end
                            % Pick out the best correlation
                            if (BestCorrelation == Convolution(TryRow, TryCol))
                                NextDirectionJ = TryCol - Col;
                                NextDirectionI = TryRow - Row;
                                BestCol = TryCol;
                                BestRow = TryRow;
                            end
                        end
                    end
                    
                    DirectionI = NextDirectionI;
                    DirectionJ = NextDirectionJ;
                    
                    % Stop check!
                    % If none of the 4 neighbors is better, assume the best fitting
                    % location is found and continue
                    
                    if DirectionI == 0 && DirectionJ == 0
                        % Stopping?
                        stop = true;
                        if ~OutsideOfMatrix(Convolution, Row, Col - 1)
                            if Convolution(Row, Col - 1) == 0
                                stop = false;
                            end
                        end
                        if ~OutsideOfMatrix(Convolution, Row, Col + 1)
                            if Convolution(Row, Col + 1) == 0
                                stop = false;
                            end
                        end
                        if ~OutsideOfMatrix(Convolution, Row - 1, Col)
                            if Convolution(Row - 1, Col) == 0
                                stop = false;
                            end
                        end
                        if ~OutsideOfMatrix(Convolution, Row + 1, Col)
                            if Convolution(Row + 1, Col) == 0
                                stop = false;
                            end
                        end
                        % Best fitting location found!
                        if stop
                            Offset = Offset + [X(BestCol), Y(BestRow)];
                            break;
                        end
                    else
                        % Start from current best
                        Col = BestCol;
                        Row = BestRow;
                        
                        % else iterate in the direction of increasing correlation
                        while true % Break out of the while loop if maximum is found
                            
                            % Check if the edge is reached edge
                            TryRow = Row + DirectionI;
                            TryCol = Col + DirectionJ;
                            EdgeTry = TryCol == 12 || TryRow == 12 || TryCol == 0 || TryRow == 0;
                            
                            if ~EdgeTry
                                % Offset of the correlation image
                                Convolution_Offset = Offset + [X(Col + DirectionJ), Y(Row + DirectionI)];
                                % Determine correlation
                                Convolution(Row + DirectionI, Col + DirectionJ) = CorrelationValue(ROI, Convolution_Offset, ROI_Size);
                                % Trial position has worse correlation then last
                                % figured location?
                            else
                                % Stop in this direction
                                if DirectionJ ~= 0
                                    % Horizontal trials
                                    DirectionJ = 0;
                                    DirectionI = 1;
                                else
                                    % Vertical trials
                                    DirectionJ = 1;
                                    DirectionI = 0;
                                end
                                break;
                            end
                            
                            
                            if Convolution(Row + DirectionI, Col + DirectionJ) < BestCorrelation
                                % Line (local) maximum found
                                
                                % Next direction to look for
                                
                                
                                if DirectionJ ~= 0
                                    % Horizontal trials
                                    DirectionJ = 0;
                                    DirectionI = 1;
                                else
                                    % Vertical trials
                                    DirectionJ = 1;
                                    DirectionI = 0;
                                end
                                
                                break;
                                
                            else
                                % Still on a correlation winning streak? Keep
                                % bettin'
                                Col = Col + DirectionJ;
                                Row = Row + DirectionI;
                                BestCorrelation = Convolution(Row, Col);
                            end
                            
                        end
                    end
                end
            end
            
            if FullConvolution
                % Calculate the 2D convolution matrix
                for Col = 1:11
                    for Row = 1:11
                        % Offset within the convolution
                        Convolution_Offset = Offset + [X(Col), Y(Row)];
                        % Construct the (simulated) bead image
                        BeadImage = PointSpreadFunction(Convolution_Offset, PSF_width_centerpeak, ROI_Size) - ...
                            PointSpreadFunction(Convolution_Offset, PSF_width_darkring, ROI_Size);
                        % Calculate the convolution value for this offset
                        Convolution(Row, Col) = sum(sum(BeadImage .* ROI));
                    end
                end
                % Determine the (Row,Column) coordinate of the highest convolution
                % value
                [MaxOfColumn, I_Row] = max(Convolution);
                [~, I_Column] = max(MaxOfColumn);
                I_Row = I_Row(I_Column);
                % Determine the now best estimate of the bead location
                Offset = Offset + [X(I_Column), Y(I_Row)];
            end
            
            
            
            %                     % Determine the right width of the PSF
            %                     S = (-1:0.2:1) .* StepSize .* 10;
            %                     for Sigma = 1:11
            %                         PSF_width_offset = PSF_width + S(Sigma);
            %                         if PSF_width_offset >= 2
            %                             % Construct the (simulated) bead image
            %                             BeadImage = PointSpreadFunction(Offset, PSF_width_offset, ROI_Size);
            %
            %                             % Calculate the convolution value for this offset
            %                             Convolution_Width(Sigma) = sum(sum(BeadImage .* BeadData));
            %
            %                             % Determine difference between
            %                             Factor = Convolution_Width(Sigma) ./ sum(sum(BeadImage.*BeadImage));
            %                             LeftOvers = BeadData - Factor .* BeadImage;
            %                             ChiSq(Sigma) = sum(sum((LeftOvers).^2));
            %                         else
            %                             ChiSq(Sigma) = inf;
            %                         end
            %                     end
            %                     % Determine the width of the PSF with the most overlap with the
            %                     % bead
            %                     % [~, I_Sigma] = max(Convolution_Width);
            %                     [~, I_Sigma] = min(ChiSq);
            %                     PSF_width = PSF_width + S(I_Sigma);
            
        end
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
    imagesc(BeadImage); axis square; title('Gaussian shape');
end

end

% function [Correlation] = CorrelationValue(BeadData, Offset)
% % Calculate the simulated bead image and correlate
% BeadImage = PointSpreadFunction(Offset, PSF_width_centerpeak, ROI_Size) - ...
%     PointSpreadFunction(Offset, PSF_width_darkring, ROI_Size);
%
% Correlation = sum(sum(BeadImage .* BeadData));
%
% end

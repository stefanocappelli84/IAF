function [Population] = Centroid_CenterOfMass(Population, FrameData, ROI_Size)
% Determine the centroid wit the center of mass method

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
    
    % Extract ROI
    ROI = FrameData(ROI_Y_Min:ROI_Y_Max, ROI_X_Min:ROI_X_Max);
    ROI = abs(ROI);
    % Remove low intensity pixels
    ROI_Cutoff = 0.05*max(max(ROI));
    ROI_Mask = ROI > ROI_Cutoff;
    ROI = ROI_Mask .* (ROI - ROI_Cutoff);
    
    % Determine the center of mass
    [X, Y] = CenterOfMass(ROI);
    % Calculate the position of the centroid from the CoM
    Population.Object(i_Object).Centroid = [ROI_X_Min + X - 1, ROI_Y_Min + Y - 1];


end

% Store number of objects in the struct
Population.N_Objects = N_Objects;

% % Now write the location back into the struct
% Population.LocationList = NewLocationList;


end

function [CoM_X, CoM_Y] = CenterOfMass(Image)
% Calculate the center of mass of the Image matrix
% Use the absolute image
Image = abs(Image);

% Meshgrid (Coordinate LUT)
[X,Y] = meshgrid(1:size(Image,2), 1:size(Image,1));
% Determine CoM
TotalIntensity = sum(sum(Image));
CoM_X = sum(sum(X .* double(Image))) / TotalIntensity;
CoM_Y = sum(sum(Y .* double(Image))) / TotalIntensity;
end
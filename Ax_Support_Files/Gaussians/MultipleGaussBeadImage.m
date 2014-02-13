function [BeadImage] = MultipleGaussBeadImage(ROI_Size, Offset, Ampl, Centr, Sigma)

BeadImage = zeros(ROI_Size);
% Initialize 
SizeX = ROI_Size(1);
SizeY = ROI_Size(2);
% rb = (min([SizeX, SizeY]) + 1) / 2;

% Determine offset
xc = (SizeX + 1) / 2 + Offset(1);
yc = (SizeY + 1) / 2 - Offset(2);


for ix = 1:SizeX,
    for iy = 1:SizeY,
        radial = sqrt( (ix-xc)^2 + (iy-yc)^2 );
        
%         if radial > rb,
%             BeadImage(iy, ix) = NaN;
%         else
            BeadImage(iy, ix) = GaussProfileR(radial, Ampl, Centr, Sigma);
%         end
    end
end

% Rescale to have a filter with zero mean
meanFilter = mean(mean(BeadImage(~isnan(BeadImage))));
BeadImage = BeadImage-meanFilter;

% BeadImage(isnan(BeadImage)) = 0;

end
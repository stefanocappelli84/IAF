function Dataset = CreateBeadTemplate(Dataset, SampleImage, varargin)
% Extract the bead template

% SampleImage = IAF_LoadFrame(Dataset, i_Frame);

% Set true for Hough transform
HT = false;
filter = false;

close all
set(0, 'Units', 'pixels') 
% figure('Position', get(0, 'ScreenSize')); %
figure;
colormap(gray);
imagesc(SampleImage);
axis image;

title({'Selecting ', 'Use mouse click to zoom in/out and then press enter'})
zoom on
waitfor(gcf, 'CurrentCharacter', 13) % wait for enter
title('Click first on the CENTER of the bead,then on the EDGE of the bead');
zoom off

[x, y] = ginput(2);
close;

x0=x(1);
y0=y(1);

if nargin == 2
    radius = round(sqrt( (x(2)-x(1))^2 + (y(2)-y(1))^2 ))+1;
else
    radius = varargin{1};
end


% if (radius+0.1*radius)*2<40 && HT
%     tmp_size = 30; % Required from CircularHough_Grd.m - it is required 
% else
    tmp_size = round(radius+0*radius);
%     m = mod(tmp_size,2);
%     tmp_size = tmp_size + (m);
% end

% define region of the bead
xmin = round(x0 - tmp_size);
xmax = round(x0 + tmp_size);
ymin = round(y0 - tmp_size);
ymax = round(y0 + tmp_size);

BeadROI = SampleImage( ymin:ymax, xmin:xmax );
if filter,
    fltr_type = fspecial('gaussian', [3 3]);
    % Image filtering
    BeadROI = imfilter(BeadROI,fltr_type,'replicate','same');
end

% Construct the bead model    
%     BeadROI = imcomplement(BeadROI); % Invert the image
    center_rot = (size(BeadROI,1)+1)/2;
    angle_step = 1;
    R = zeros(360/angle_step,center_rot);
    for i_angle=1:angle_step:360,
        im_temp = imrotate(BeadROI,i_angle,'crop');
        R(i_angle,:) = im_temp(center_rot,center_rot:end);

    end

    BeadProfile = mean(R);
%     figure;
%     plot(BeadProfile,'.');


% Dataset.BeadTemplate.BeadFilter = BeadFilter;
Dataset.BeadTemplate.BeadProfile = BeadProfile;
Dataset.BeadTemplate.Radius = radius;
Dataset.BeadTemplate.Center = [ x0, y0 ];
Dataset.BeadTemplate.ROI = [xmin, ymin; xmax, ymax]; % It store the ROI in a 2x2 matrix; each row correspond to the point (x,y)
Dataset.BeadTemplate.sizeROI = [xmax-xmin+1, xmax-xmin+1];
Dataset.BeadTemplate.CenterValue = SampleImage(round(y(1)),round(x(1)));
Dataset.BeadTemplate.EdgeValue = SampleImage(round(y(2)),round(x(2)));
Dataset.BeadTemplate.BeadROI = BeadROI;
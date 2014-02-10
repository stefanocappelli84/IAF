function Image = IAF_LoadFrame(Dataset,i_Frame)
% The function IAF_LoadFrame returns the output 'Image' as an an NxM
% matrix of double.
% The filepath is specified in Dataset, thet is the structure defined in
% NewDatasetStruct.m
%
% Image is assumed to be a grayscale image

Image = imread(strcat(Dataset.Path,'/',Dataset.Frame(i_Frame).Filename ));
% Image = rgb2gray(Image(:,:,1:3));


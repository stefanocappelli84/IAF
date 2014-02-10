%% BackgroundCorrection_HistogramMaximum
%
% Effect: Makes a histogram of the pixel datapoints. It then finds the most
% observed datavalue and subtracts that value from every pixel in the
% frame. Will position the background close to zero if the bulk of the
% frame is the background.
%

function [FrameData] = BackgroundCorrection_HistogramMaximum(FrameData)



[counts, bins] = hist(double(reshape(FrameData, 1, numel(FrameData))), 500);
[~, max_index] = max(counts);

% % Pixel intensity histogram plot
% if PlotStuff
%     bar(bins, counts);
%     xlabel('Pixel intensity', 'FontSize', 16);
%     ylabel('Counts', 'FontSize', 16);
%     text(bins(max_index), counts_max, '* Background level', 'FontSize', 20);
% end

FrameData = double(FrameData) - bins(max_index);

end
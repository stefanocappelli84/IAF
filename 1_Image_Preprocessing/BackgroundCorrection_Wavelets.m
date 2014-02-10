function [FrameData] = BackgroundCorrection_Wavelets(FrameData, Level)

[C,S] = wavedec2(FrameData, Level, 'bior3.5');
Bg = wrcoef2('a',C,S,'bior3.5', Level);

FrameData = double(FrameData) - Bg;


end
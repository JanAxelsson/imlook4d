function TACT= percentileTACT( ROIs, M, p)
%
% This function gives a time-activity curve using the mean of  the highest
% pixels (as defined by fraction parameter)
%
% INPUT:
%   ROIs        3D matrix with ROI indeces
%   M           3D or 4D matrix
%   p           Percentile to use for mean calculations. 90 is the highest 10 % of pixel values
%
% OUTPUT:
%   TACT        Time activity matrix [frame, ROI]
%
% Example:
%   % First, Export from imlook4d.
%   TACT = percentileTACT( imlook4d_ROI, imlook4d_Cdata, 90)

    numberOfFrames = size(M,4); % Number of frames
    roiNumbers = unique(ROIs);  % List of available ROIs (starting with ROI 0, which is empty)
    roiNumbers = roiNumbers( roiNumbers>0)'; % Remove 0, and make it a row vector (for loop below)
    numberOfROIs = length(roiNumbers);
    
    TACT = zeros( numberOfFrames, numberOfROIs);
%
% Get mean for highest pixels for each ROI
%
for n=1:numberOfFrames
    for i = roiNumbers
        MM = M(:,:,:,n); % 3D
        pixels = MM( ROIs == i);
        TACT(n,i) = prctile(pixels,p);
    end
end


    

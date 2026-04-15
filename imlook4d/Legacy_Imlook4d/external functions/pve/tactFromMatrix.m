function measTACT = tactFromMatrix(M,ROIs);  
% INPUTS
% - M    3D or 4D matrix 
% - ROIs 3D matrix with ROI indeces
%
% OUTPUTS
% - TACT   Time-activity curve extracted by method MTC or MGM-percentil

    numberOfFrames = size(M,4); % Number of frames
    roiNumbers = unique(ROIs);  % List of available ROIs (starting with ROI 0, which is empty)
    roiNumbers = roiNumbers( roiNumbers>0)'; % Remove 0, and make it a row vector (for loop below)

    for n=1:numberOfFrames
            R = ROIs(n,:);  % ROI values R(k) (within frame n)
            MM = M(:,:,:,n); % Work on measured volume MM (at frame n)

            % Loop ROIs
            for j=roiNumbers  
                indeces = find(ROIs==j);  % Pixel indeces to this ROI
                measTACT(n,j) = mean( MM(indeces) );   % Cross talk (from ROI j to ROI i)
            end
        end
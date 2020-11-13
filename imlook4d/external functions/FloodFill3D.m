function [B] = FloodFill3D(cIM, initPos, threshVal,BELOW_THRESHOLD, imlook4d_current_handles);
% [B] = FloodFill3D(A, slice);
% This program flood fills a 6-connected 3D region. The input matrix MUST
% be a binary image. The user will select a seed (point) in the matrix to
% initiate the flood fill. You must specify the matrix slice in which you
% wish to place the seed.
% 
% Inputs:
%            cIM: 2D/3D grayscale matrix                     
%      initPos: Coordinates for initial seed position     
%     thresVal: Absolute threshold level to be included   
%   BELOW_THRESHOLD : true if flood fill in opposite direction (up to threshold, instead of down to threshold)
%   imlook4d_current_handles : Honors locked imlook4d ROIs
%
% Built on FloodFill3D from F. Dinath

A = single( cIM >= threshVal );      % Make

if BELOW_THRESHOLD
    A = 1 - A;  % Reverse
end

A(1,:,:) = NaN;     % Pad the border of the matrix
A(end,:,:) = NaN;   % so the program doesn't attempt 
A(:,1,:) = NaN;     % to seek voxels outside the matrix
A(:,end,:) = NaN;   % boundry during the for loop below.
A(:,:,1) = NaN;     %
A(:,:,end) = NaN;   %

% Make matrix of locked pixels
ROI = imlook4d_current_handles.image.ROI; % Should be same size as cIM
lockedMatrix = zeros( size(ROI) ,'logical'); % Assume all locked
numberOfROIs = length( imlook4d_current_handles.image.LockedROIs );
for i=1:numberOfROIs
    if ( imlook4d_current_handles.image.LockedROIs(i) == 1)
        A(ROI == i ) = NaN;
    end
end


% imagesc(A(:,:,slice));
% title('select seed on figure');
% 
% k = waitforbuttonpress;
% point = get(gca,'CurrentPoint'); % button down detected
% point = [fliplr(round(point(2,1:2))) slice];

point = initPos;

%
% Flood Fill
%

if A(point(1), point(2), point(3));
    A(point(1), point(2), point(3)) = NaN;
    a{1} = sub2ind(size(A), point(1), point(2), point(3));

    i = 1;

    while 1

        i = i+1;
        a{i} = [];

        [x, y, z] = ind2sub(size(A), a{i-1});

        ob = nonzeros((A(sub2ind(size(A), x, y, z-1)) == 1).*sub2ind(size(A), x, y, z-1));
        A(ob) = NaN;
        a{i} = [a{i} ob'];

        ob = nonzeros((A(sub2ind(size(A), x, y, z+1)) == 1).*sub2ind(size(A), x, y, z+1));
        A(ob) = NaN;
        a{i} = [a{i} ob'];

        ob = nonzeros((A(sub2ind(size(A), x-1, y, z)) == 1).*sub2ind(size(A), x-1, y, z));
        A(ob) = NaN;
        a{i} = [a{i} ob'];

        ob = nonzeros((A(sub2ind(size(A), x+1, y, z)) == 1).*sub2ind(size(A), x+1, y, z));
        A(ob) = NaN;
        a{i} = [a{i} ob'];

        ob = nonzeros((A(sub2ind(size(A), x, y-1, z)) == 1).*sub2ind(size(A), x, y-1, z));
        A(ob) = NaN;
        a{i} = [a{i} ob'];

        ob = nonzeros((A(sub2ind(size(A), x, y+1, z)) == 1).*sub2ind(size(A), x, y+1, z));
        A(ob) = NaN;
        a{i} = [a{i} ob'];

        if isempty(a{i});
            break;
        end
%         imagesc(A(:,:,slice));
%         drawnow;
    end
end

b = cell2mat(a);
b = sort(b,2);

B = logical(zeros(size(A)));
B(b) = 1;


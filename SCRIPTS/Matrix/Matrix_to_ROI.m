% Matrix_to_ROI.m

% This script converts an image with integer values to a number of ROIs.
% A typical use case is in neurological research, when segmentation (ROIs) in normal space are represented 
% as integer values in a Nifti file. The point is then to create an imlook4d ROI file with the relevant ROIs.
%
% Jan Axelsson 2015-03-02


Export

pixelValues = unique(imlook4d_Cdata);

for i=1:length(pixelValues)
   if ( pixelValues(i) ~= 0)
       value = pixelValues(i);
       roiNumber = MakeROI( num2str(value) );

       imlook4d_ROI = imlook4d_ROI + uint8( roiNumber * ( imlook4d_Cdata(:,:,:,1)  == value ) ); % ROIs not defined in frames
       disp([ 'Roi:' num2str(roiNumber) 'Name:' num2str(value)  ' pixels=' num2str( sum( ( imlook4d_Cdata(:) == value ) )) ]);
   end
end

Import

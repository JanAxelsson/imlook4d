function frame_data= SHR_readfile(  filename ,  pixelx,  pixely);
% SHR_readfile
%
% Routine for reading Hamamatsu SHR PET-data files
%
% frame_data= SHR_readfile(  filename ,  pixelx,  pixely);
%
% Inputs:
%   pixelx -   number of pixels in first dimension
%   pixely -   number of pixels in second dimension
%
% Output:
%  'exprm1_data' -  3-dimensional matrix [X x Y x M] with image 
%				    size X x Y with M slices.
%
% Uses:
%   none
%
% Author:   
%   Jan Axelsson, Uppsala Imanet, 040206

% Fixed number of slices on SHR
SLICES=31;
% Open file for reading
fid=fopen(filename,'r','b');



% Initialize
frame_data=zeros(pixelx,pixely,31);    % Create empty matrix

% Read all slices
for i=1:SLICES  
   frame_data(:,:,i)=fread(fid,[pixelx pixely],'int16')';
end;

fclose(fid);

%
% DONE --------------------
%

%
% HERE FOLLOWS DIAGNOSTIC OUTPUT PLOTS
%

%
% Display montage of all slices 
%

%     % Graph-positioning parameters
% 	NCols=6;
% 	NRows=6;
% 	GI=1;	% Graph index, initial value
%             
% for i=1:SLICES  
%         subplot(NRows,NCols,GI), imagesc(frame_data(:,:,i));GI=GI+1; 
%         set(gca,'XTick', []);set(gca,'YTick', [])
%         set(colorbar('vert'),'fontsize',6);  
% end;

% 
% Display stack of all slices
% 
%imlook3d(frame_data);

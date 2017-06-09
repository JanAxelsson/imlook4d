function ROI_matrix=circleROI(ROI_matrix, ROI_number, Xc, Yc, r)
% Creates a circular ROI
%
% ROI_matrix    2D matrix
% ROI_Number    integer, 1, 2, ...
% Xc    circle center position in pixels
% Yc    circle center position in pixels
% r  	circle radius in pixels (could be fractions of pixels)
% Xr    relative position of Xabs, 0<=Xr<=1
xSize=size(ROI_matrix,1);
ySize=size(ROI_matrix,2);
r2=r*r;
                
for ix=(Xc-round(r)):(Xc+round(r))
    for iy=(Yc-round(r)):(Yc+round(r))
        % Draw ROI (if inside image)
        if (ix>0)&&(ix<=xSize)&&(iy>0)&&(iy<=ySize)
            if (ix-Xc)^2+(iy-Yc)^2<r2
                ROI_matrix(ix,iy)=ROI_number;
            end
        
        end                                
    end
end

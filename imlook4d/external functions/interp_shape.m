function out = interp_shape(top,bottom,num)

% From StackOverFlow
% https://stackoverflow.com/questions/18084698/interpolating-between-two-planes-in-3d-space
% "I figured this out today, after reading: "E?cient Semiautomatic
% Segmentation of 3D Objects in Medical Images" by Schenk, et. al."


if nargin<2;
    error('not enough args');
end
if nargin<3;
    num = 1;
end
if ~num>0 && round(num)== num; 
    error('number of slices to be interpolated must be integer >0');
end

top = signed_bwdist(top); % see local function below
bottom = signed_bwdist(bottom);

r = size(top,1);
c = size(top,2);
t = num+2;

[x y z] = ndgrid(1:r,1:c,[1 t]); % existing data
[xi yi zi] = ndgrid(1:r,1:c,1:t); % including new slice

out = interpn(x,y,z,cat(3,bottom,top),xi,yi,zi);
out = out(:,:,2:end-1)>=0;

function im = signed_bwdist(im)
im = -bwdist(bwperim(im)).*~im + bwdist(bwperim(im)).*im;
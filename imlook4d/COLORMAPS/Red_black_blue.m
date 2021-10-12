function tab=Red_black_blue(n)
% http://www.ncl.ucar.edu/Document/Graphics/color_table_gallery.shtml
% From http://www.ncl.ucar.edu/Document/Graphics/ColorTables/GMT_split.shtml

% Default N:=255;
if nargin == 0
    n=255;
end

% Pixelv�rdena till RGB tabellen. Ett index per rad.
pix=[0 1 4 24 28 36 48 64 68 76 96 104 132 148 152 180 212 220 228 252 255];
pix = round( (0:39)*255/39 );
% RGB f�rgtabellen. En rad per pixel i PIX.
farg=[...
0.476863 0.476863 0.975098
0.426667 0.426667 0.925294
0.376471 0.376471 0.875490
0.326275 0.326275 0.825686
0.276078 0.276078 0.775882
0.225882 0.225882 0.726078
0.175686 0.175686 0.676275
0.125490 0.125490 0.626471
0.075294 0.075294 0.576667
0.025098 0.025098 0.526863
0.000000 0.000000 0.476863
0.000000 0.000000 0.426667
0.000000 0.000000 0.376471
0.000000 0.000000 0.326275
0.000000 0.000000 0.276078
0.000000 0.000000 0.225882
0.000000 0.000000 0.175686
0.000000 0.000000 0.125490
0.000000 0.000000 0.075294
0.000000 0.000000 0.025098
0.025098 0.000000 0.000000
0.075294 0.000000 0.000000
0.125490 0.000000 0.000000
0.175686 0.000000 0.000000
0.225882 0.000000 0.000000
0.276078 0.000000 0.000000
0.326275 0.000000 0.000000
0.376471 0.000000 0.000000
0.426667 0.000000 0.000000
0.476863 0.000000 0.000000
0.526863 0.025098 0.025098
0.576667 0.075294 0.075294
0.626471 0.125490 0.125490
0.676275 0.175686 0.175686
0.726078 0.225882 0.225882
0.775882 0.276078 0.276078
0.825686 0.326275 0.326275
0.875490 0.376471 0.376471
0.925294 0.426667 0.426667
0.975098 0.476863 0.476863 ...
    ];

% Interpolera N pixelv�rden i f�rgtabellen. Skala om tabellen fr�n 0..255
% till 0..1.
%tab=interp1(pix, farg, linspace(0, 255, n)) / 255;
tab = farg;
% keyboard
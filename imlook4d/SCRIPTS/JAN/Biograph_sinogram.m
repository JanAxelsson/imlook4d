% Start experimenting with sinograms from Siemens


% -------- Siemens Biograph ----------------
%fid=fopen('C:\Users\Jan\Dropbox\PET-data\Rådata\Fysiker_punktkilde.PT.PET_PET_WB_(Adult).601.SINO.20120730.102049.968000.2012.08.03.08.28.42.031000.24648989.ptd');
[file,path] = uigetfile();
fid=fopen([path filesep file]);
nx=400;ny=168;nz=109;                       % From embeded interfile header: bins, projections, sinograms
nx=336;ny=336;nz=81;                       % From embeded interfile header: bins, projections, sinograms
matrix=fread(fid,nx*ny*nz,'int16',0, 'l');  % From embeded interfile header: Signed integer, Little Endian, 
fclose(fid);
matrix2=reshape(matrix,[nx ny nz]);
imlook4d(matrix2);


function [vol, M, mr_parms] = dz_ReadMGHfile(filename)
% This is basically a copy of "load_mgh.m" in FreeSurfer-matlab-library
% But it can also read a mgz-file, without first decompressing it to disk.

% Parse the requested output filename (full path name)
[ph,fn,ext] = fileparts(filename);
if strcmpi(ext, '.mgz')

	%% took this from undocumentedmatlab.com
	
	% Get the serialized data
	streamCopier = com.mathworks.mlwidgets.io.InterruptibleStreamCopier.getInterruptibleStreamCopier;
	baos = java.io.ByteArrayOutputStream;
	fis  = java.io.FileInputStream(filename);
	zis  = java.util.zip.GZIPInputStream(fis);

	streamCopier.copyStream(zis,baos);
	fis.close;
	data = baos.toByteArray;  % array of Matlab int8

	
% 	% Deserialize the data back into the original Matlab data format
% 	% Note: the zipped data is int8 => need to convert into uint8:
% 	% Note2: see discussion with Martin in the comments section below
% 	if numel(data) < 1e5
		data = uint8(mod(int16(data),256))';
% 	else
% 		data = typecast(data, 'uint8');
% 	end
% 	data = getArrayFromByteStream(data);
else
	fid = fopen(filename, 'rb', 'b');
	data = fread(fid);
	fclose(fid);
end


% [vol, M, mr_parms, volsz] = load_mgh(fname,<slices>,<frames>,<headeronly>)
vol = [];
M = [];
mr_parms = [];

fp = 0;

v = typecast(data(fp+(4:-1:1)), 'int32');fp=fp+4;
ndim1 = typecast(data(fp+(4:-1:1)), 'int32');fp=fp+4;
ndim2 = typecast(data(fp+(4:-1:1)), 'int32');fp=fp+4;
ndim3 = typecast(data(fp+(4:-1:1)), 'int32');fp=fp+4;
nframes = typecast(data(fp+(4:-1:1)), 'int32');fp=fp+4;
type = typecast(data(fp+(4:-1:1)), 'int32');fp=fp+4;
dof = typecast(data(fp+(4:-1:1)), 'int32');fp=fp+4;

UNUSED_SPACE_SIZE= 256;
USED_SPACE_SIZE = (3*4+4*3*4);  % space for ras transform

unused_space_size = UNUSED_SPACE_SIZE-2 ;
ras_good_flag = typecast(data(fp+(4:-1:1)), 'int16');fp=fp+2;
if (ras_good_flag)
	for i=1:3
		%data(fp+[4 3 2 1])
		delta(i) = typecast(data(fp+[4 3 2 1]), 'single');fp=fp+4;
	end
	for i=1:9
		Mdc(i) = typecast(data(fp+[4 3 2 1]), 'single');fp=fp+4;
	end
	Mdc    = reshape(Mdc,[3 3]);
	for i=1:3
		Pxyz_c(i) = typecast(data(fp+[4 3 2 1]), 'single');fp=fp+4;
	end
	Pxyz_c = Pxyz_c';
	D = diag(delta);
	Pcrs_c = double([ndim1/2 ndim2/2 ndim3/2]'); % Should this be kept?
	Pxyz_0 = Pxyz_c - Mdc*D*Pcrs_c;
	M = [Mdc*D Pxyz_0; 0 0 0 1];
	ras_xform = [Mdc Pxyz_c; 0 0 0 1];
	unused_space_size = unused_space_size - USED_SPACE_SIZE ;
	Q = zeros(4);
	Q(1:3,4) = ones(3,1);
	M = inv(inv(M)+Q);
end
%fseek(fid, unused_space_size, 'cof') ;
fp = fp+unused_space_size;
nv = double(ndim1 * ndim2 * ndim3 * nframes);
% whos nv = ndim1  ndim2  ndim3  nframes
volsz = [ndim1 ndim2 ndim3 nframes];

MRI_UCHAR =  0 ;
MRI_INT =    1 ;
MRI_LONG =   2 ;
MRI_FLOAT =  3 ;
MRI_SHORT =  4 ;
MRI_BITMAP = 5 ;

%------------------ Read in the entire volume ----------------%
switch type
	case MRI_FLOAT,
		%vol = fread(fid, nv, 'float32') ;
		%vol = typecast(data(fp+(nv*4:-1:1)), 'single'); fp=fp+nv*4;
		disp('"single"-precision files cannot be read by this program');
		vol = [];
	case MRI_UCHAR,
		vol = typecast(data(fp+(nv*1:-1:1)), 'uint8'); fp=fp+nv*1;
		%vol = fread(fid, nv, 'uchar') ;
	case MRI_SHORT,
		vol = typecast(data(fp+(nv*2:-1:1)), 'int16'); fp=fp+nv*2;
		%vol = fread(fid, nv, 'short') ;
	case MRI_INT,
		vol = typecast(data(fp+(nv*4:-1:1)), 'int32'); fp=fp+nv*4;
		%vol = fread(fid, nv, 'int') ;
end
vol = vol(end:-1:1);
for i=1:4
	if (fp+4)<=numel(data)
		mr_parms(i) = typecast(data(fp+[4 3 2 1]), 'single');fp=fp+4;
	else
		mr_parms(i) = NaN;
	end
end

vol = double(reshape(vol, double([ndim1 ndim2 ndim3 nframes])));




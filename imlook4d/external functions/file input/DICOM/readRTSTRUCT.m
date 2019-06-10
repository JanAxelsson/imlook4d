function ROI = readRTSTRUCT( rtssfile, imagedir)

    %rtssfile = '/Volumes/Seagate Expansion Drive/QUARANTINED/FLT/XXXX (2017-MAY-12) - 267331/[RTSTRUCT] Nucletron Oncentra Anatomy Modeling Structure Set - serie1/450Q'
    %imagedir = '/Volumes/Seagate Expansion Drive/QUARANTINED/FLT/XXXX (2017-MAY-12) - 267331/[MR] Gd-Ax FSPGR 3D - serie14'
    [segdir,name,ext] = fileparts(rtssfile); % Put result in same dir as rtssfile

    % Important parts from dicomrt2matlab

        % Load DICOM headers
        fprintf('Reading image headers...\n');
        rtssheader = dicominfo(rtssfile);
        imageheaders = loadDicomImageInfo(imagedir, rtssheader.StudyInstanceUID);


        % Read contour sequences
        fprintf('Converting RT structures...\n');
        contours = readRTstructures(rtssheader, imageheaders); %#ok<NASGU>
        %contours = convexPoints2bin(contours, imageheaders); %#ok<NASGU>

    ROI = uint8( contours.Segmentation );


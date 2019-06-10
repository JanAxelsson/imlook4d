function ROI = readRTSTRUCT( rtssfile, imagedir)

    % Files from https://github.com/ulrikls/dicomrt2matlab

    %rtssfile = '/Users/jan/Desktop/IMAGES/XXXX (2017-MAY-12) - 267331/[RTSTRUCT] Nucletron Oncentra Anatomy Modeling Structure Set - serie1/450Q'
    %imagedir = '/Users/jan/Desktop/IMAGES/XXXX (2017-MAY-12) - 267331/[MR] Gd-Ax FSPGR 3D - serie14'
    

    % Important parts from dicomrt2matlab

        % Load DICOM headers
        fprintf('Reading image headers...\n');
        rtssheader = dicominfo(rtssfile);
        imageheaders = loadDicomImageInfo(imagedir, rtssheader.StudyInstanceUID);  % Needed for coordinate transforms
        % TODO : get file list from handles.image, and copy from loadDicomImageInfo.m


        % Read contour sequences
        fprintf('Converting RT structures...\n');
        contours = readRTstructures(rtssheader, imageheaders); % #ok<NASGU>
        %contours = convexPoints2bin(contours, imageheaders); %#ok<NASGU>
        
        % TODO: Loop through contours to get all ROIs
        %       ROI name is within contours

    ROI = uint8( contours.Segmentation );


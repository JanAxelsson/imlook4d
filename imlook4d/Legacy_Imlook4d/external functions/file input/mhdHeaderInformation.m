function [defaultanswer fullPath]=mhdHeaderInformation( filePath)
try

    % Image file path
        try
            [pathstr, name, ext] = fileparts(filePath);

            temp=mhdHeader( filePath, 'ElementDataFile');  % Get data file path from header
            fullPath=[pathstr filesep temp];

            disp(['Name of data file=' temp]);
        catch
            disp('WARNING:  mhdHeader.m  : Could not find "name of data file"'); 
        end

    % Number of pixels
        defaultanswer{1}='?'; % Signal that number of pixels were not found
        defaultanswer{2}='?';
        try
            pixelString=mhdHeader( filePath, 'DimSize');    % Pixels in x y z
            [xPixels, remain] = strtok(pixelString,' ');    % xPixels
            [yPixels, zPixels] = strtok(remain,' ');        % yPixels, zPixels

            defaultanswer{1}=xPixels; % xPixels
            defaultanswer{2}=yPixels; % yPixels
            defaultanswer{3}=zPixels; % Number of slices
        catch
            disp('ERROR:  mhdHeader.m  : Could not find matrix size'); 
        end  

    % Number of frames 
        defaultanswer{4}='1'; % Default number of frames, if not found in header
        try
            disp('WARNING:  mhdHeader.m  : Could not find number of frames'); 
        end   

        numberOfFrames=str2num(defaultanswer{4});

    % Byte order
        try
            temp=mhdHeader( filePath, 'BinaryDataByteOrderMSB'); 
            switch temp
                case 'False'
                    defaultanswer{5}='l';
                case 'True'
                    defaultanswer{5}='b';
            end

        catch
            disp('ERROR:  mhdHeader.m  : Could not find imagedata byte order'); 
        end   

    % Format
        defaultanswer{6}='int16';  % Guess int16, if not found in header
        try
            temp=mhdHeader( filePath, 'ElementType'); 
            switch temp
                case 'MET_SHORT'
                    defaultanswer{6}='short';
            end

        catch
            disp('WARNING:  mhdHeader.m  : Could not find number format'); 
        end    
catch
    disp('ERROR:  mhdHeader.m failed');
end

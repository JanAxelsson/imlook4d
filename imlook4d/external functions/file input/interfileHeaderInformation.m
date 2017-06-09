function [defaultanswer fullPath]=interfileHeaderInformation( filePath)
try
    % Image file path
        try
            [pathstr, name, ext, versn] = fileparts(filePath);

            temp=interfileHeader( filePath, 'name of data file');  % Get data file path from header
            fullPath=[pathstr filesep temp];

            disp(['Name of data file=' temp]);
        catch
            disp('WARNING:  interfileHeaderInformation.m  : Could not find "name of data file"'); 
        end

    % Number of pixels
        defaultanswer{1}='?'; % Signal that number of pixels were not found
        defaultanswer{2}='?';
        try
            defaultanswer{1}=interfileHeader( filePath, 'matrix size [1]'); % xPixels
            defaultanswer{2}=interfileHeader( filePath, 'matrix size [2]'); % yPixels
        catch
            disp('ERROR:  interfileHeaderInformation.m  : Could not find matrix size'); 
        end  

    % Number of frames 
        defaultanswer{4}='1'; % Default number of frames, if not found in header
        try
            try
                % Dynamic SPECT
                defaultanswer{4}=interfileHeader( filePath, 'number of images this frame group');     % Frames
            catch
            end
            try
                % Dynamic PET (Triumph animal scanner)
                defaultanswer{4}=interfileHeader( filePath, 'tomo number of frames');     % Frames
            catch
            end   
            try
                % Dynamic PET (from STIR)
                defaultanswer{4}=interfileHeader( filePath, 'number of time frames');     % Frames
            catch
            end   
        catch
            disp('WARNING:  interfileHeaderInformation.m  : Could not find number of frames'); 
        end   

        numberOfFrames=str2num(defaultanswer{4});

    % Number of slices  
        defaultanswer{3}='?';   % Signal that number of slices were not found
        try
            numberOfImages=str2num( interfileHeader( filePath, 'total number of images') );  % Total number of images
            defaultanswer{3}=num2str( numberOfImages/numberOfFrames) ;                      % Slices    

        catch
            disp('WARNING:  interfileHeaderInformation.m  : Could not find total number of images'); 
        end   


    % Byte order
        try
            temp=interfileHeader( filePath, 'imagedata byte order'); 
            switch temp
                case 'LITTLEENDIAN'
                    defaultanswer{5}='l';
                case 'BIGENDIAN'
                    defaultanswer{5}='b';
                case 'bigendian'
                    defaultanswer{5}='b';
            end

        catch
            disp('ERROR:  interfileHeaderInformation.m  : Could not find imagedata byte order'); 
        end   

    % Format
        defaultanswer{6}='int16';  % Guess int16, if not found in header
        try
            temp=interfileHeader( filePath, 'number format'); 
            switch temp
                case 'short float'
                    defaultanswer{6}='float32';
                case 'unsigned integer'
                    defaultanswer{6}='int16';
            end

        catch
            disp('WARNING:  interfileHeaderInformation.m  : Could not find number format'); 
        end    
catch
    disp('ERROR:  interfileHeaderInformation.m failed');
end

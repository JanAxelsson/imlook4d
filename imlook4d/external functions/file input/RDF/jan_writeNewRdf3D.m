function jan_writeNewRdf3D( SINO3D, template_filePath, filepath_out)
    % Writes a decompressed HDF-type SINOGRAM for modern GE PET systems.
    % Tested on data from PET/MR Signa
    %
    % Inputs:
    %   SINO3D --  SINOGRAM (3D) as read from "jan_readNewRdf".
    %   template_filePath -- a 3D HDF file which is used as template for headers
    %   filepath_out -- file path to saved file
    %
    % Klara Leffler 2019-APR-15
    % (klara.leffler@umu.se)
    % Jan Axelsson 2019-APR-30
    % (axelsson.jan$gmail.com)
    
    % 
    % Input data
    %
    
        % Copy to filepath_out
            [status,msg] = copyfile(template_filePath ,filepath_out); 
            
        % Template file information TOF/non-TOF
             info_sino = h5info( template_filePath,'/SegmentData/Segment2'); 
             SINO_FORMAT = info_sino.Groups.Name; % 3D_TOF_Sinogram or 3D_Sinogram
             TOF_FILE = strcmp('/SegmentData/Segment2/3D_TOF_Sinogram', SINO_FORMAT); % True if Template file is 4D sinogram
             
             % Verify that template file is 3D (not TOF
             if TOF_FILE
                dispRed('You are using original file as template for header structure');
                dispRed('Your data is 3D (non-TOF). Template file is TOF RAW data');
                dispRed('You can only save in same format as template file');
                return 
             end
        
 
    % 
    % Output
    %
    
        % Create file according to filepath_out and save new data version
            s = size(SINO3D);
            N_Rs = s(1);   % radial bins 357 (Example values for GE SIGNA PETMR)
            N_Omega = s(2);% sinograms 1981
            N_Phis = s(3);
            
            for i = 1:N_Phis
                views{i} = ['view' num2str(i)]; % Dataset names
                disp( ['Writing  ' views{i} '  (' num2str(i) ' of ' num2str(N_Phis)  ')'] );
                if length(s) == 3
                    Matrix3D = SINO3D(:,:,i); 
                    h5write(filepath_out,[SINO_FORMAT '/' views{i}], Matrix3D ) % Write new file
                else
                    warning(['Not a 3D sinogram.  Number of dimensions = ' num2str( length(s) )]);
                end
            end
            
            % Write total prompts
            totalPrompts = sum( SINO3D(:));
            h5write(filepath_out,'/HeaderData/AcqStats/totalPrompts', uint32(totalPrompts) ) % Write new file
            
  
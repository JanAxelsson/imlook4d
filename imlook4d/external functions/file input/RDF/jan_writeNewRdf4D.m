function jan_writeNewRdf4D( SINO4D, template_filePath, filepath_out)
    % Writes a decompressed HDF-type SINOGRAM for modern GE PET systems.
    % Tested on data from PET/MR Signa
    %
    % Inputs:
    %   SINO4D --  SINOGRAM (4D) as read from "jan_readNewRdf".
    %   template_filePath -- a 4D HDF file which is used as template for headers
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
            
        % Filepath information TOF/non-TOF
            info_sino = h5info( template_filePath,'/SegmentData/Segment2'); 
            SINO_FORMAT = info_sino.Groups.Name; % 3D_TOF_Sinogram or 3D_Sinogram
            
        % Information about number of views
            info = h5info( template_filePath,SINO_FORMAT);
            listOfDatasets = info.Datasets;
    
 
    % 
    % Output
    %
    
        % Create file according to filepath_out and save new data version
            s = size(SINO4D);
            N_Rs = s(1);   % radial bins 357 (Example values for GE SIGNA PETMR)
            N_Tofs = s(4); % tof bins  27
            N_Omega = s(2);% sinograms 1981
            N_Phis = s(3);
            
            for i = 1:N_Phis
                views{i} = ['view' num2str(i)]; % Dataset names
                disp( ['Writing  ' views{i} '  (' num2str(i) ' of ' num2str(N_Phis)  ')'] );
                if length(s) == 4
                    
                    
                    % WHEN READ (jan_readNewRdf.m) :
                    % Matrix3D = h5read(filepath,[SINO_FORMAT '/' views{i} ]); % Matlab reads in wrong order to matrix 357 x 27 x 1981 per view (224 views)
                    % newMatrix3D = reshape( Matrix3D, [N_Omega, N_Tofs, N_Rs]); % Data is stored as chunked HDF5:  1981 x 27,  357 times -- reshape to that size. [V T U]
                    % temp = permute(newMatrix3D, [3, 2, 1]); % 357 x 27 x 1981 x 224.  [U T V Phi]
                    % SINO4D(:,:,i,:) = permute(temp, [1, 3, 4, 2]); % 357 x 1981 x 224 x 27.  [U V Phi T]

                    % 
                    % Undo having TOF in 4:th dimension
                    % SINO4D % 357 x 1981 x 1 x 27
                    temp = permute( SINO4D(:,:,i,:), [1, 4, 2, 3] ); % 357 x 27 x 1981 x 224.  [U T V Phi]
                    newMatrix3D =  permute( squeeze(temp), [3, 2, 1] ); % 357 x 27 x 1981  
                    
                    % Undo chunked hdf
                    %newMatrix3D = reshape( Matrix3D, [N_Rs, N_Tofs, N_Omega]);
                    Matrix3D = reshape( newMatrix3D, [N_Rs, N_Tofs, N_Omega]); % Matlab hdf correct order of dimensions:  matrix 357 x 27 x 1981
                    
                    % Write
                    h5write(filepath_out,[SINO_FORMAT '/' views{i}], Matrix3D ) % Write new file
                else
                    warning(['Not a 4D sinogram.  Number of dimensions = ' num2str( length(s) )]);
                end
            end
            
            % Write total prompts
            totalPrompts = sum( SINO4D(:));
            h5write(filepath_out,'/HeaderData/AcqStats/totalPrompts', uint32(totalPrompts) ) % Write new file
            
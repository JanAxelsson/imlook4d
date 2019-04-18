function klara_writeNewRdf4D( SINO4D,filepath_in,filepath_out)
    % Creates copy of decompressed SINOGRAM from modern GE PET systems.
    % Tested on data from PET/MR Signa
    %
    % Input SINOGRAM (4D) from "jan_readNewRdf".
    % 
    % Filepaths:
    %   filepath_in = '/Volumes/LEFFLER 1/PSF
    %   PETMR/Rådata/SINO0000_decomp'; % Template file, which should have all headers 
    %   filepath_out = '/Volumes/LEFFLER 1/PSF PETMR/Rådata copies/SINO0000_decomp_test';
    %
    % Klara Leffler 2019-APR-15
    % (klara.leffler@umu.se)
    
    % 
    % Input data
    %
    
        % Copy to filepath_out
            [status,msg] = copyfile(filepath_in ,filepath_out); 
            
        % Filepath information TOF/non-TOF
            info_sino = h5info( filepath_in,'/SegmentData/Segment2'); 
            SINO_FORMAT = info_sino.Groups.Name; % 3D_TOF_Sinogram or 3D_Sinogram
            
        % Information about number of views
            info = h5info( filepath_in,SINO_FORMAT);
            listOfDatasets = info.Datasets;
    
 
    % 
    % Output
    %
    
        % Create file according to filepath_out and save new data version
            s = size(SINO4D);
            N_Rs = s(1);   % radial bins 357 (Example values for GE SIGNA PETMR)
            N_Tofs = s(2); % tof bins  27
            N_Omega = s(3);% sinograms 1981
            
            N_Phis = length(listOfDatasets);
            for i = 1:N_Phis
                views{i} = ['view' num2str(i)]; % Dataset names
                disp( ['Writing  ' views{i} '  (' num2str(i) ' of ' num2str(N_Phis)  ')'] );
                if length(s) == 4
                    Matrix3D = permute( SINO4D(:,:,:,i), [3, 2, 1]); % 357 x 27 x 1981 x 224
                    %newMatrix3D = reshape( Matrix3D, [N_Omega, N_Tofs, N_Rs]);
                    newMatrix3D = reshape( Matrix3D, [N_Rs, N_Tofs, N_Omega]);
   
                    h5write(filepath_out,[SINO_FORMAT '/' views{i}], newMatrix3D ) % Write new file
                else
                    warning(['Not a 4D sinogram.  Number of dimensions = ' num2str( length(s) )]);
                end
            end
            
            % Write total prompts
            totalPrompts = sum( SINO4D(:));
            h5write(filepath_out,'/HeaderData/AcqStats/totalPrompts', totalPrompts ) % Write new file
            
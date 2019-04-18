function [SINO3D, SINO4D] = jan_readNewRdf( filepath)
    % Reads decompressed SINOGRAMS from modern GE PET systems.
    % Tested on data from PET/MR Signa
    %
    % Use "rdfDecomp filename" on scanner first, where 
    % filepath is found by "diagAnalysis" tool on scaner
    %
    % Outputs matrices have dimensions 
    %  non-tof: [ radial bin, projections, projection angles phi ]
    %  tof:     [ radial bin, tof bin, projections, projection angles phi ]
    %
    % For GE SIGNA PETMR this would give :
    %   SINO3D : 357 x 1981 x 224  ( Same format as segment2.dat exported  from rdfTell -s )
    %   SINO4D  : 357 x 27 x 1981 x 224
    %
    % Number of output arguments determines output format.
    %   SINO3D = jan_readNewRdf( filepath)
    %   [SINO3D, SINO4D] = jan_readNewRdf( filepath)
    % If the data is not TOF-data, SINO4D will be empty matrix.
    % 
    % Examples:
    %   filepath = '/Volumes/JAN/PSF PETMR/Rådata/SINO0000_decomp';
    %   SINO3D = jan_readNewRdf( filepath); % Returns only SINO3D summed over TOF
    %   [SINO3D, SINO4D] = jan_readNewRdf( filepath); % Returns SINO3D summed over TOF, and SINO4D with TOF included
    %
    % Jan Axelsson 2019-APR-04
    % (axelsson.jan@gmail.com)
    
 

    % 
    % Determine constants
    %

        TOF_DIM = 2; 
            
        % Determine if function should output also TOF dimension (SINO4D)
            OUTPUT_TOF = true;

            if nargout == 1
                OUTPUT_TOF = false;
            end

        % TOF included in Sinogram ?
            info_sino = h5info( filepath,'/SegmentData/Segment2'); 
            SINO_FORMAT = info_sino.Groups.Name; % 3D_TOF_Sinogram or 3D_Sinogram
            TOF_IN_MATRIX = strcmp('/SegmentData/Segment2/3D_TOF_Sinogram', SINO_FORMAT); % True if 4D sinogram

            % Information about number of views
            info = h5info( filepath,SINO_FORMAT);
            listOfDatasets = info.Datasets;
            
            % Verify that uncompressed
            name = listOfDatasets(1).Name;
            if not( strcmp( name(1:4), 'view' ) )
                error('Not uncompressed data. Try to run "rdfDecomp" on scanner');
                return
            end


        % Read dimensions from data: 
            Matrix3D = h5read(filepath,[SINO_FORMAT '/view1' ]);
            s = size(Matrix3D);

            N_Rs = s(1);   % radial bins 357 (Example values for GE SIGNA PETMR).  GE calls this U
            N_Tofs = s(2); % tof bins  27.  GE calls this T
            N_Omega = s(3);% sinograms 1981.  GE calls this V
            N_Phis = length(listOfDatasets); % Number of projection angles 224. GE cals this Phi

            % Correct if non-TOF
            if not(TOF_IN_MATRIX )
                N_Omega = s(2); % 
                OUTPUT_TOF = false; % Cannot write to SINO4 if there is no TOF
                SINO4D = []; % Make empty SINO4D, in case function called with two output arguments
            end

    %
    % Input data
    %

        % Read and sort
        for i = 1: N_Phis
            % Read one view ( = one projection angle phi) 
            views{i} = [ 'view' num2str(i) ]; % Name of dataset
            disp( ['Reading  ' views{i} '  (' num2str(i) ' of ' num2str(N_Phis)  ')'] );
            
            Matrix3D = h5read(filepath,[SINO_FORMAT '/' views{i} ]);  % Matlab reads in wrong order to matrix 357 x 27 x 1981 per view (224 views)
            newMatrix3D = reshape( Matrix3D, [N_Omega, N_Tofs, N_Rs]); % Data stored as chunked HDF5:  1981 x 27,  357 times -- reshape to that size. [V T U]

            % Sum TOF sinograms
            if TOF_IN_MATRIX
                MatrixNoTof =  permute( squeeze( sum(newMatrix3D, TOF_DIM)  ), [ 2 1] ); % Sum TOF, and transpose because of Matlab. [U V]
            else
                % TODO: This I have not tested yet.
                MatrixNoTof = newMatrix3D';
            end

            SINO3D(:,:,i) = MatrixNoTof; % [U V Phi]

            % Output non-summed TOF Sinogram (if two output arguments when calling function)
            if OUTPUT_TOF
                SINO4D(:,:,:,i) = permute(newMatrix3D, [3, 2, 1]); % 357 x 27 x 1981 x 224.  [U T V Phi]
            end
        end

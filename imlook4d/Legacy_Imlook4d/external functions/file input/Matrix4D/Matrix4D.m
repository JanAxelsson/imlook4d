classdef (Sealed) Matrix4D
% Represents a spatiotemporal object (array) in 3 + 1 Dimensions.
%
% DO NOT EDIT THIS CLASS! Contact me (anders.garpebring@radfys.umu.se) if there 
% are errors.
%
% Author: Anders Garpebring (2010).
    
    % Direct properties which one can set and get.
    properties (SetAccess = public, GetAccess = public)
        % The data matrix (4D) - xyzt. 
        % Can be real and complex and have any numeric data type unless complex
        % for wich only single and double precision is allowed. 
        %
        % Very important: The matrix property is NOT protected from
        % errornous assignment such as changing its size. However, changing
        % the size of the matrix after creation renders the object invalid
        % and will cause all checked operations to through on error.
        matrix;
        % The timestamp for the slices in the data matrix (nz x nt). [s]  
        % Must be double precision.
        timeStamp;
        % The physical position of the imaged volume (as represented in this object). [mm]
        % A 3 x 1 vector (xyz) with double elements.
        position;
        % The orientation of the imaged volume.
        % Represented by a Rotation object.
        orientation;
        % The orientation of the patient in the imaging device.
        % Represented by a Rotation object.
        patientOrientation,
        % The physical size of a voxel in the data matrix. [mm]
        % A 3 x 1 vector (xyz).
        voxelSize;
        % The unit of the data matrix.
        imageUnit;
        % Information about the creation of the image.
        imagingInfo;
        % A name on this object.
        name;     
        % The position of the isocenter (in patient coordinate system) [mm]. 
        % The position is relative the reference position. (3 x 1)
        isoCenter;
        % A flag telling if data in some dimensions are represented as 
        % the Fourier transform of the image.
        fourierDimensions;
    end
    
    % Properties that correspond to the data acquisition. Since that cannot
    % change these properties have SetAccess = private.
    properties (SetAccess = private, GetAccess = public)
        % The timestamp for the slices in the sampled data matrix (nz x nt). [s]  
        % Must be double precision. 
        sampledTimeStamp;
        % Sampled voxelsize. [mm]
        % A 3 x 1 vector (xyz).
        sampledVoxelSize;
        % Distance between voxels in the sampled data.
        % A 3 x 1 vector (xyz). Normally the same as sampledVoxelSize but
        % can differ if there is a spacing between slices.
        sampledVoxelDistance;
        % The size of the sampled data matrix (4D) - xyzt.
        sampledMatrixSize;
        % The physical position of the imaged volume (as it was sampled). [mm]
        sampledPosition; 
        % The orientation of the sampled image volume.
        % Represented by a Rotation object.
        sampledOrientation;   
        % The default viewer. 
        defaultViewer;
    end
    
    % Indirect properties
    properties (Dependent = true, SetAccess = private, GetAccess = public)
        % The position of the slices. (Upper, left corner.) 
        % A 3 x nz collection of positions. [mm]
        slicePosition;
    end
    
    properties (Dependent = true, SetAccess = public, GetAccess = public)
        % The format of the data in the data matrix.
        format;
    end
    
    properties (Constant = true, GetAccess = public)
        % The order of the spatial and temporal dimesions in the data matrix.
        dimOrder = 'xyzt';
        % The units of the spatial and temporal dimensions.
        dimUnits = {'mm','mm','mm','s'};
        % The version of this object.
        version = '1.0';
        % Supported viewers
        supportedViewers = {'ROIViewer4D'};
    end
    
    properties (GetAccess = private, SetAccess = private)
        % The size of the data matrix. (As it was created.)
        createdSize;
    end
    
    
    % Set and get methods
    methods 
        
       function f = get.format(m4)
           f = class(m4.matrix); 
        end
        
       function m4 = set.format(m4,f)
            m4 = m4.setFormat(f);
        end
        
       function slicePos = get.slicePosition(m4)
           nz = m4.matrixSize('z');
           selection = [ones(1,nz);ones(1,nz);1:nz];
           slicePos = getVoxelPosition(m4,selection,'Patient'); 
        end
       
       function m4 = set.timeStamp(m4,ts)
            % Check that input is numeric
            if (~isreal(ts) || ~isa(ts,'double'))
               error('Matrix4D:timeStamp','The class of the time stamp matrix must be double and the data must be real.') 
            end
            
            if (isequal(size(ts),size(m4.timeStamp)) || isempty(m4.timeStamp))
                m4.timeStamp = ts;
            else
                error('Matrix4D:timeStamp','The size of the time stamp matrix cannot change after the object has been created.');
            end
       end  
       
       function m4 = set.isoCenter(m4,iso)
            % Check that input is numeric
            if (~isreal(iso) || ~isa(iso,'double'))
               error('Matrix4D:isoCenter','The class of the isoCenter must be double and the data must be real.') 
            end
            
            if (~isequal(size(iso),[3,1]))
                error('Matrix4D:isoCenter','The size of isoCenter must be 3 x 1.')   
            end
            m4.isoCenter = iso;
       end
       
       function m4 = set.orientation(m4,o)
            % Check that input is a Rotation
            if (~isa(o,'Rotation'))
               error('Matrix4D:orientation','The class of the rotation must be a Rotation.') 
            end
            
            if (numel(o) == 1)
                m4.orientation = o;
            else
                error('Matrix4D:orientation','Only one orientation can be used to discribe the data orientation.');
            end
       end

       function m4 = set.patientOrientation(m4,o)
            % Check that input is a Rotation
            if (~isa(o,'Rotation'))
               error('Matrix4D:patientOrientation','The class of the rotation must be a Rotation.') 
            end
            
            if (numel(o) == 1)
                m4.patientOrientation = o;
            else
                error('Matrix4D:patientOrientation','Only one orientation can be used to discribe the patient orientation.');
            end
       end
       
       function m4 = set.voxelSize(m4,vSize)
            % Check that input is of correct size and type.
            if (~((numel(vSize)==3) && isa(vSize,'double') && isreal(vSize)) )
               error('Matrix4D:voxelSize','The voxelSize must be a three element double vector with real elements.') 
            end
            
            if (sum(vSize>0)~=3)
               error('Matrix4D:voxelSize','The voxelSize must only contain positive values.') 
            end
            
            m4.voxelSize = vSize(:);
       end
       
       function m4 = set.position(m4,pos)
            % Check that input is of correct size and type.
            if (~((numel(pos)==3) && isa(pos,'double') && isreal(pos)) )
               error('Matrix4D:position','The position must be a three element double vector with real elements.') 
            end
            
            m4.position = pos(:);
       end
       
       function fourierDim = get.fourierDimensions(m4)
          % Tell which dimensions of the data that are represeted in Fourier space.
          %
          fourierDim = m4.dimOrder(m4.fourierDimensions);
       end
       
       function m4 = set.fourierDimensions(m4,dims)
          % Set which dimensions of the data to be represeted in Fourier space.
          %
          if (ischar(dims))
            % Check that dims only contains xyz or t
            if (sum(ismember(dims,m4.dimOrder)) ~= numel(dims))
               error('Matrix4D:fourierDimensions','fourierDimensions must be set using a string containing only ''xyzt'' or a 1 x 4 logical vactor.'); 
            end
            % Reset values
            tmp = false(1,4);
            
            for ii = 1:numel(dims)
               % Find the position of the dimension. E.g. x -> 1
               index = find(dims(ii) == m4.dimOrder,1);
               tmp(index) = true;
            end
            m4.fourierDimensions = tmp;
          elseif (islogical(dims) && numel(dims) == 4)
              m4.fourierDimensions = dims(:)';
          else
             error('Matrix4D:fourierDimensions','fourierDimensions must be set using a string containing ''xyzt'' or a 1 x 4 logical vactor.');  
          end
       end
 end
    
    % Construction
    methods
        function m4 = Matrix4D(varargin)
            % Construct a Matrix4D object.
            % The object can be constructed in five different ways:
            %
            % 1. Empty constructor. Creates a rather useless m4-object with
            %    a 1 x 1 x 1 x 1 data matrix. This objects use is as a placeholder in an array.
            %
            % 2. A copy of another m4 object. Useful mainly of syntactical
            %    reasons. It is possible to assign using m41 = m41(m42);
            %
            % 3. A matrix as input. Max 4 dims and any numeric datatype and 
            %    logical. All other proporties are filled in automatically.
            %
            % 4. Full initialization
            %    Each paroperty is set directly. This is convenient to
            %    ensure that all properties are properly set.
            %
            %    Inpar:
            %    matrix                 - The data matrix. Max 4 dims and any
            %                           numeric datatype and logical.
            %    timeStamp              - The timestamp for the slices in the data matrix (nz x nt). [s]  
            %                           Must be double precision.
            %    sampledTimeStamp       - The timestamp for the slices in the sampled data matrix (nz x nt). [s]  
            %                           Must be double precision.
            %    position               - The position of the first slice's upper
            %                           left corner. (3 x 1) or (1 x 3), [mm].
            %    orientation            - The orientation of the imaged volume.
            %                           Represented by a Rotation object.
            %    patientOrientation     - The orientation of the patient in the imaging device.
            %                           Represented by a Rotation object.
            %    voxelSize              - The physical size of a voxel in the data matrix. [mm]
            %                           A 3 x 1 vector (xyz).
            %    sampledVoxelSize       - Sampled voxelsize. [mm]
            %                           A 3 x 1 vector (xyz).
            %    sampledVoxelDistance   - Distance between voxels in the sampled data.
            %                           A 3 x 1 vector (xyz). Normally the same as sampledVoxelSize but
            %                           can differ if there is a spacing between slices.
            %    sampledMatrixSize      - The size of the sampled data
            %                           matrix (4D) - xyzt.
            %    sampledPosition        - The physical position of the
            %                           imaged volume (as it was sampled). [mm]
            %    sampledOrientation     - The orientation of the sampled image volume.
            %                           Represented by a Rotation object.
            %    imageUnit              - The unit of the data of the matrix.
            %    imagingInfo            - Information about the creation of the image.
            %    name                   - A name on this object.
            %    isoCenter              - The position of the isocenter (in patient coordinate system) [mm]. 
            %                           The position is relative the reference position and for
            %                           each slice in the datamatrix. (3 x
            %                           1).
            %
            % 5. Selected initialization. Choose what properties to set.
            %    The rest is set to default or from values of other properties
            %
            %    Inpar:
            %    matrix                 - The data matrix. Max 4 dims and any
            %                           numeric datatype and logical. (Required)
            %    prop, val, ...         - Poperty value pairs. E.g. ... ,'voxelSize',[1 2 2]', ...
            %                           Any number of pairs can be used.
            %
            % EXAMPLES:
            %   placeHolder = Matrix4D();
            %   randObj     = Matrix4D(randn(20,20,10,2));
            %   myObj       = Matrix4D(myData,'voxelSize',[2 2 2]','timeStamp',myTimeStampMatrix);
            %
            %
            % OBSERVE: Once an object is created. Certain properties cannot
            % be changed and some properties can only be changed in a
            % controlled way.
            
            
            
            % Default values
            m4.matrix = 0;
            m4.position = [0 0 0]';
            m4.orientation = Rotation();
            m4.patientOrientation = Rotation();
            m4.voxelSize = [1 1 1]';
            m4.sampledVoxelSize = [1 1 1]';
            m4.sampledVoxelDistance = [1 1 1]';
            m4.sampledMatrixSize = [1 1 1 1];
            m4.sampledPosition = [0 0 0]'; 
            m4.sampledOrientation = Rotation();
            m4.imageUnit = '';
            m4.imagingInfo = [];
            m4.name = '';
            m4.fourierDimensions = false(1,4);
            
            % Get configuration values
            [m4.defaultViewer] = Matrix4D.getConfigurationSettings();
            
            % Check that the matrix is no more than 4D
            if (nargin>0)
                if (numel(size(varargin{1})) > 4)
                    error('Matrix4D:Matrix4D','The input matrix can be no more than 4D.');
                end
            end
            
            switch(nargin)
                case 0 % Create a empty matrix. Used as placeholder.
                    m4.matrix = 0;
                    m4.timeStamp = 0;
                    m4.sampledTimeStamp = 0;
                    m4.isoCenter = [0 0 0]';
                case 1 % Create a m4 object based on a matrix information alone. All other data set to default
                    if (isa(varargin{1},'Matrix4D'))
                        m4 = varargin{1};
                    elseif (islogical(varargin{1}) || isnumeric(varargin{1}))
                        m4.matrix = varargin{1};
                        m4.timeStamp = zeros(size(m4.matrix,3),size(m4.matrix,4));
                        m4.sampledTimeStamp = zeros(size(m4.matrix,3),size(m4.matrix,4));
                        m4.isoCenter = zeros(3,1); 
                        [m4.sampledMatrixSize(1),m4.sampledMatrixSize(2),m4.sampledMatrixSize(3),m4.sampledMatrixSize(4)] = size(m4.matrix);
                        m4.imagingInfo.Modality = 'mat -> m4';
                    end
                otherwise
                    % Two cases: Specified input or selected input  
                    if (ischar(varargin{2})) % Selected input
                       parsedInput = cell(1,15); 
                       [parsedInput{:}] = Matrix4D.parseInput(varargin{2:end});
                       default2Missing = cell(1,16);
                       [default2Missing{:}] = Matrix4D.fillinMissing2Default(varargin{1},parsedInput{:});
                       m4struct = Matrix4D.init(default2Missing{:}); 
                    else % Specified input
                       m4struct = Matrix4D.init(varargin{:}); 
                    end
                    
                    fields = fieldnames(m4struct);
                    for field = fields(:)'
                       m4.(field{1}) = m4struct.(field{1}); 
                    end
            end
            m4.createdSize = size(m4.matrix);
        end
    end
    
    % Static methods
    methods (Static = true,Access = public)
        function m4 = loadobj(a)
            % Called during loading of the object. Unsure that previous
            % versions of the object can be loaded.
            if (isstruct(a))
                
            try
                disp('Creating a Matrix4D (v1.0) from old Matrix4D data.');
                disp('Some field may not be accurate.')
                m4 = Matrix4D.array(size(a));
                for ii = 1:numel(a)
                    % Check for uniform object
                    if (~(a(ii).uniformVoxelSize && a(ii).uniformSliceOrientation))
                       error('Matrix4D:loadobj','Varying voxel size or orientation between slices is not supported by Matrix4D v1.0.'); 
                    end

                    m4(ii) = Matrix4D(a(ii).mat,'timeStamp',a(ii).timeStamp','position',a(ii).slicePosition(:,1),...
                                    'orientation',Rotation(a(ii).sliceOrientation{1}),'patientOrientation',Rotation(a(ii).patientInMachineOrientation), ...
                                    'voxelSize',a(ii).voxelSize(:,1),'imageUnit',a(ii).imageUnit,'imagingInfo',a(ii).imagingInfo,...
                                    'name',a(ii).name);
                end
                
            catch err
                error('Matrix4D:loadobj','Connot load old object type. Missing fields.')
            end
                
                
                
            elseif (isa(a,'Matrix4D'))
                switch (a.version)
                    case '1.0'
                        m4 = a;
                    otherwise
                        error('Matrix4D:loadobj',['Unknown object version = ',a.version]); 
                end
            else
               error('Matrix4D:loadobj',['Trying to load class = ',class(a), ' as a Matrix4D.']); 
            end
        end
        
        function [m4Array,importInfo] = import(filePath,importFileFormat,settings)
            % Import data from file. The import can range from very simple
            % to highly complex with many different kinds of inputs and outputs. 
            % Depending on what format the import is based on the
            % settings structure is very different. Thus, each import
            % format is described separately. 
            %
            % Inpar:
            % filePath              - The path to the file(s) or specific
            %                       files including the full path. Or a
            %                       specific file.  
            % importFileFormat      - The file format from which the import is performed.
            %                       (optional). Default set in the
            %                       configM4.txt file.
            % settings              - Settings for the import. (Optional)
            %                       If not specified a default is used.
            % 
            % Output:
            % m4Array               - A N-D array of Matrix4D objects. Or a
            %                       N-D cell array of Matrix4D arrays. 
            % importInfo            - A structure giving additional
            %                       information about the import. 
            %   
            % The importInfo structure
            %   .dimNames           - Name on each dimension.
            %   .dimSize            - Size of each dimesion.
            %   .dimValues          - 1 x numel(dimName) cell array of
            %                       values along each dimension. The values
            %                       are represented by 1 x m(dim) cell arrays. 
            %
            %
            %
            % DICOM 
            % filePath can be a directory in which to search for files, or
            % a file. If a file is used, the series which the file belong
            % to is loaded. 
            %
            % The settings structure
            %   .recursive          - true/false. If subfolders should be
            %                       searched for files. (Default = false)
            %   .naming             - A list of the attributes that should
            %                       be used to name the object. Default = {'SeriesInstanceUID'}.
            %                       Must have string value.
            %   .outputType         - cellArray or m4Array (default). If 
            %                       cellArray cells in the N-D output matrixes 
            %                       can be empty and contain non-singleton m4 arrays.
            %                       If m4Array each each element in the
            %                       array is pupulated with a single m4.
            %   .selectionString    - A string used for selection of files
            %                       that should be used. If empty ('') all files are
            %                       selected. This is the default. 
            %
            %                       Example of selection string:
            %                       '$EchoTime>2 & $SeriesDescription == ''MinSeq'' | $InversionTime >  $RepetitionTime'
            %
            %   .splitTags          Cell array of tags used to split the
            %                       set of files into subsets where each subset
            %                       constute data for a single Matrix4D object.
            %                       OBS: If complex data is created. Real
            %                       and imaginary parts should first be split and 
            %                       then joined together (see below). 
            %                       Default = {'SeriesInstanceUID'}.
            %
            %   .orderTags          Tags used to order the images into a
            %                       N-D output matrix (N = number of tags).
            %                       Is a cell array of tags. Default =
            %                       {'SeriesInstanceUID'}. 
            %
            % DICOM3D
            % Import 3D DICOMS using MAtlab builtin methods.
            %
            % The settings structure
            %   .recursive          - true/false. If subfolders should be
            %                       searched for files. (Default = false)
            %
            % NIFTI
            % Imports NIFTI files. filePath can be a directoy with *.nii
            % files. (Should be extended in the future.)
            %
            % The settings structure
            %   .recursive      - true/false If subfolders should be
            %                   searched for files. (Default = false)

            if (nargin < 2)
                [~,importFileFormat] = Matrix4D.getConfigurationSettings();
            end
            if (nargin < 3)
                settings = Matrix4D.getDefaultImportSettings(importFileFormat);
            end
           
            switch (lower(importFileFormat))
                 % DICOM
                case 'dicom'
                    [m4Array,importInfo] = Matrix4D.importDICOM(filePath,settings);
                case 'nifti'
                    [m4Array,importInfo] = Matrix4D.importNIFTI(filePath,settings);
                case 'dicom3d'
                    [m4Array,importInfo] = Matrix4D.importDICOM3D(filePath,settings);
                case 'mhd'
                    [m4Array,importInfo] = Matrix4D.importMHD(filePath,settings);
                otherwise
                    error(['File format: ',importFileFormat,' not supported.']);
            end
            
        end
           
        function settings = getDefaultImportSettings(importFileFormat) %#ok<STOUT>
           % Returns the default import settings for a give file format.
           % To be implemented!
           switch (lower(importFileFormat))
               case 'dicom' 
                   fid = fopen('dicomimportconfig.txt','r');
                   str = fread(fid,Inf,'uint8=>char')';
                   fclose(fid);
                   eval(str);
               case 'dicom3d'
                   fid = fopen('dicomimportconfig.txt','r');
                   str = fread(fid,Inf,'uint8=>char')';
                   fclose(fid);
                   eval(str);
               case 'nifti'
                   settings.recursive = false;
               case 'mhd'
                   settings.recursive = false;
               otherwise
                   error(['Unknown file format: ',importFileFormat]);
           end
        end
        
        function m4 = array(varargin)
            % Create an array of default m4-objects
            % Input:
            % siz       - A vector 1 x n with dimension sizes
            %           or n1,n2,...nk - Dimension sizes
            % m4Init    - Optional initializer (single m4)
            % 
            % Example:
            %   Matrix4D.array(3,3,3);
            %   Matrix4D.array([3,3,3]);
            %   Matrix4D.array(3,3,3,Matrix4D('matrix',randn(10,10,10),'timestamp',1,'voxelsize',[2 2 2]'))
            
            if (nargin == 0)
                error('Matrix4D:array','At least one input argument specifying size is required');
            end
            
            % Find initialization data
            if (isa(varargin{end},'Matrix4D'))
               if (nargin == 1)
                   error('Matrix4D:array','At least one input argument specifying size is required');
               end
               m4Init = varargin{end};
               dimSize = varargin(1:(end-1));
            else
               m4Init = Matrix4D(); 
               dimSize = varargin(:);
            end
            
            
            switch (numel(dimSize))
                case 1    
                    if (isscalar(dimSize{1}))
                       % Scalar input is interpreted as N x N
                       m4 = Matrix4D.empty(dimSize{1},0);
                       m4(dimSize{1},dimSize{1}) = m4Init(1);
                    else
                       m4 = Matrix4D.empty([dimSize{1}(1:(end-1)),0]);      
                       index = num2cell(dimSize{1});
                       m4(index{:}) = Matrix4D();  
                    end
                otherwise
                       m4 = Matrix4D.empty([[dimSize{1:(end-1)}],0]);
                       m4(dimSize{:}) =  Matrix4D(); 
            end
            
            % If init to other then default contructor
            if (isa(varargin{end},'Matrix4D'))
                for ii = 1:numel(m4)
                   m4(ii) = m4Init; 
                end
            end

        end        
                
        function updateProgressbarScanFiles(x)
           % For internal use only.
           progressbar2(0.3*x,x,[]); 
        end
    end
    
    % Ordinary methods
    methods (Access = public)
        function s = size(m4,varargin)
           % Return the size of an m4 array.  
           s = builtin('size',m4,varargin{:}); 
        end
        
        function n = numel(m4,varargin)
           % Return the number of elements in an m4 array.  
           n = builtin('numel',m4,varargin{:}); 
        end
        
        function tf = isvalid(m4)
           % Check each element in a m4-array if they are valid.
  
           tf = false(size(m4));
           
           for ii = 1:numel(m4)
              tf(ii) = isequal(size(m4(ii).matrix),m4(ii).createdSize); 
           end
        end
        
        
        function m4Sub = subMatrix(m4,varargin) 
            % Create an array of sub-matrixes from m4 based on a selection of pixels.
            %
            % Inpar:
            % m4                            - An array of Matrix4D objects.
            % dim1, siz1, dim2, siz2 ...    - Pairs of dimension and size.
            %                               The dimension is specified as
            %                               'x','y','z' and 't'. The size
            %                               is a 1 x 2 vector of positive
            %                               integers not bigger than the 
            %                               dimension size. The size
            %                               parameters can also be cell
            %                               arrays of the same size as the
            %                               m4 array. Then the sizes are applied 
            %                               elementwise to the m4 array. Use Inf for
            %                               the last element.
            %
            % 
            %
            
            errorOnInvalid(m4);
            m4Sub = Matrix4D.array(size(m4));
            
            xRange = {[1,Inf]};
            yRange = {[1,Inf]};
            zRange = {[1,Inf]};
            tRange = {[1,Inf]};
            
            % Parse input
            for ii = 1:2:(nargin-1)
                switch(lower(varargin{ii}))
                    case 'x'
                        xRange = varargin{ii+1};
                        if (~isa(xRange,'cell'))
                           xRange = {xRange}; 
                        end
                    case 'y'
                        yRange = varargin{ii+1};
                        if (~isa(yRange,'cell'))
                           yRange = {yRange}; 
                        end
                    case 'z'
                        zRange = varargin{ii+1};
                        if (~isa(zRange,'cell'))
                           zRange = {zRange}; 
                        end
                    case 't'
                        tRange = varargin{ii+1}; 
                        if (~isa(tRange,'cell'))
                           tRange = {tRange}; 
                        end
                    otherwise
                        error('Matrix4D:subMatrix',['Bad coordinate specification: ',varargin{ii},' must be ''x'', ''y'', ''z'', or ''t''.'])
                end
            end
            
            % Make sure that if numel(iRange) == 1, then iRange of size(m4)
            % is created and content is copyed to all elements.
            
            if (numel(xRange)== 1)
               tmp = xRange{1};
               xRange = cell(size(m4));
               for ii = 1:numel(xRange)
                  xRange{ii} = tmp; 
               end
            end
            if (numel(yRange)== 1)
               tmp = yRange{1};
               yRange = cell(size(m4));
               for ii = 1:numel(yRange)
                  yRange{ii} = tmp; 
               end
            end
            if (numel(zRange)== 1)
               tmp = zRange{1};
               zRange = cell(size(m4));
               for ii = 1:numel(zRange)
                  zRange{ii} = tmp; 
               end
            end
            if (numel(tRange)== 1)
               tmp = tRange{1};
               tRange = cell(size(m4));
               for ii = 1:numel(tRange)
                  tRange{ii} = tmp; 
               end
            end
            

            
            for ii = 1:numel(m4)
                try
                    xrange = xRange{ii};
                    yrange = yRange{ii};
                    zrange = zRange{ii};
                    trange = tRange{ii};
                    
                    % Convert Inf to matrixSize
                    xrange(isinf(xrange)) = m4(ii).matrixSize('x');
                    yrange(isinf(yrange)) = m4(ii).matrixSize('y');
                    zrange(isinf(zrange)) = m4(ii).matrixSize('z');
                    trange(isinf(trange)) = m4(ii).matrixSize('t');
                    
                   % Check the input
                   validateattributes(yrange, {'numeric'},{'size',[1 2]});
                   validateattributes(xrange, {'numeric'},{'size',[1 2]});
                   validateattributes(zrange, {'numeric'},{'size',[1 2]});
                   validateattributes(trange, {'numeric'},{'size',[1 2]});
                   validateattributes(yrange(1), {'numeric'}, {'integer', 'positive','<=',m4(ii).matrixSize('y'),'<=',yrange(2)});
                   validateattributes(yrange(2), {'numeric'}, {'integer', 'positive','<=',m4(ii).matrixSize('y')}); 
                   validateattributes(xrange(1), {'numeric'}, {'integer', 'positive','<=',m4(ii).matrixSize('x'),'<=',xrange(2)});
                   validateattributes(xrange(2), {'numeric'}, {'integer', 'positive','<=',m4(ii).matrixSize('x')}); 
                   validateattributes(zrange(1), {'numeric'}, {'integer', 'positive','<=',m4(ii).matrixSize('z'),'<=',zrange(2)});
                   validateattributes(zrange(2), {'numeric'}, {'integer', 'positive','<=',m4(ii).matrixSize('z')});
                   validateattributes(trange(1), {'numeric'}, {'integer', 'positive','<=',m4(ii).matrixSize('t'),'<=',trange(2)});
                   validateattributes(trange(2), {'numeric'}, {'integer', 'positive','<=',m4(ii).matrixSize('t')});
                catch err
                    error('Matrix4D:subMatrix',['Invalid input: ',err.message]);
                end
                % Create the sub-matrix
                newPosition = m4(ii).getVoxelPosition([xrange(1),yrange(1),zrange(1)]','patient');
                m4Sub(ii) = Matrix4D(m4(ii).matrix(xrange(1):xrange(2),yrange(1):yrange(2),zrange(1):zrange(2),trange(1):trange(2)),...
                                     m4(ii).timeStamp(zrange(1):zrange(2),trange(1):trange(2)), m4(ii).sampledTimeStamp, ...
                                     newPosition,m4(ii).orientation, m4(ii).patientOrientation, m4(ii).voxelSize,...
                                     m4(ii).sampledVoxelSize,m4(ii).sampledVoxelDistance,m4(ii).sampledMatrixSize,m4(ii).sampledPosition,...
                                     m4(ii).sampledOrientation,m4(ii).imageUnit,m4(ii).imagingInfo,[m4(ii).name,': Submatrix'],...
                                     m4(ii).isoCenter);
            end
        end
        
        
        function varargout = getPositionGrid(m4,coordsys)
           % Returns the position of each pixel on a grid and selected coordinate
           % system.
           %
           % Input:
           % m4         - An array of Matrix4D objects
           % coordsys   - The coordinate system in which the results
           %            are presented. Can be 'image','patient' and 'machine'.
           %            (Optional, default = 'patient'.)
           errorOnInvalid(m4);
           if (nargin<2)
               coordsys = 'patient';
           end
           
           varargout = cell(1,numel(m4));
           
           for ii = 1:numel(m4)
               index = [1:m4(ii).matrixSize('x');ones(1,m4(ii).matrixSize('x'));ones(1,m4(ii).matrixSize('x'))];
               x = m4(ii).getVoxelPosition(index,coordsys);
               x = x(1,:);
               index = [ones(1,m4(ii).matrixSize('y'));1:m4(ii).matrixSize('y');ones(1,m4(ii).matrixSize('y'))];
               y = m4(ii).getVoxelPosition(index,coordsys);
               y = y(2,:);
               index = [ones(1,m4(ii).matrixSize('z'));ones(1,m4(ii).matrixSize('z'));1:m4(ii).matrixSize('z')];
               z = m4(ii).getVoxelPosition(index,coordsys);
               z = z(3,:);
               
               [grid.xx,grid.yy,grid.zz] = ndgrid(x,y,z);
               varargout{ii} = grid;
           end
           
           
        end
        
        function varargout = getVolumeTime(m4,mode,t)
            % Get the mean, min or max time in a volume. The time is
            % relative to the first acquired time in the volume.
            %
            % Inpar:
            % m4    - An array of m4 objects
            % mode  - The mode of the timestamp. Can be 'mean',
            %         'min' or 'max'. Optional 'mean' is selected per
            %         default.
            % t     - A list of time indexes. Or all cell array where each
            %       cell contains a list. The array should have the same size as
            %       m4, or size = 1. 
            %       (Optional, default = 1:end)
            %
            %
            % Outpar:
            % tVal - A list of times. Or for an array a collection of
            % lists.
            %
            % Example:
            % % A single object
            % tVal = getVolumeTime(m4,'min',1:10);
            %
            % % An array of objects
            % tsVal = cell(size(m4));
            % [tVal{:}] = getVolumeValTime(m4,'max',1:10);
            
            varargout = cell(size(m4));
            switch (nargin)
                case 1
                    [varargout{:}] = getVolumeTimeStamp(m4);
                case 2
                    [varargout{:}] = getVolumeTimeStamp(m4,mode);
                case 3
                    [varargout{:}] = getVolumeTimeStamp(m4,mode,t);
            end
            
            for ii = 1:numel(m4)
               varargout{ii} = varargout{ii}-varargout{ii}(1); 
            end
        end
        
        function varargout = getVolumeTimeStamp(m4,mode,t)
            % Get the mean, min or max timestamp in a volume.
            %
            % Inpar:
            % m4    - An array of m4 objects
            % mode  - The mode of the timestamp. Can be 'mean',
            %         'min' or 'max'. Optional 'mean' is selected per
            %         default.
            % t     - A list of time indexes. Or all cell array where each
            %       cell contains a list. The array should have the same size as
            %       m4, or size = 1. 
            %       (Optional, default = 1:end)
            %
            %
            % Outpar:
            % tsVal - A list of times. Or for an array a collection of
            % lists.
            %
            % Example:
            % % A single object
            % tsVal = getVolumeTimeStamp(m4,'min',1:10);
            %
            % % An array of objects
            % tsVal = cell(size(m4));
            % [tsVal{:}] = getVolumeValTimeStamp(m4,'max',1:10);
            
            errorOnInvalid(m4);
            if (nargin<2)
               mode = 'mean'; 
            end
            
            if (nargin<3)
               t = cell(size(m4));
               for ii = 1:numel(t)
                  t{ii} = 1:m4(ii).matrixSize('t'); 
               end
            else
                if (isa(t,'cell'))
                    if (isequal(size(t),size(m4)))
                        % Everything is ok
                    else
                        if (numel(t) == 1)
                           ttmp = t{1};
                           t = cell(size(m4));
                           for ii = 1:numel(m4)
                              t{ii} = ttmp; 
                           end
                        else
                           error('Matrix4D:getVolumeTimeStamp','The size of the cell array specifying time indexes is not compatible with the size of the m4-array.'); 
                        end
                    end
                else
                   ttmp = t;
                   t = cell(size(m4));
                   for ii = 1:numel(m4)
                      t{ii} = ttmp; 
                   end
                end
                
            end
            
            

            varargout = cell(1,numel(m4));
            
            for ii = 1:numel(m4)
                switch (lower(mode))
                    case 'mean'
                            varargout{ii} = mean(m4(ii).timeStamp(:,t{ii}),1);
                    case 'min'
                            varargout{ii} = min(m4(ii).timeStamp(:,t{ii}),[],1);
                    case 'max'
                            varargout{ii} = max(m4(ii).timeStamp(:,t{ii}),[],1);
                    otherwise
                        error('Matrix4D:getVolumeTimeStamp',['Unknown mode: ', mode]);
                end
            end
        end
        
        function m4 = timeAverage(m4,timeStampMode,t)
            % Calculate the timeaverage of m4 objects.
            %
            % Inpar:
            % m4    - An array of m4 objects
            % mode  - The timeStampMode used for calculating the new timestamp. Can be 'mean',
            %         'min' or 'max'. Optional 'mean' is selected per
            %         default.
            % t     - A list of time indexes over which the average should be performed. Or all cell array where each
            %       cell contains a list. The array should have the same size as
            %       m4, or size = 1. 
            %       (Optional, default = 1:end)
            %
            %
            % Outpar:
            % m4Out - The new time averaged m4 objects. 
            %
            % Examples:
            % m4_timeAveraged = m4.timeAverage();
            % % Time average over the 10 first times in each element in m4.
            % m4_timeAveraged = m4.timeAverage('min',1:10);
            % % Different time averages for different dynamics
            % m4_timeAveraged = m4.timeAverage('min',{1:10,2:20});
            
            % Check that matrix is Ok
            errorOnInvalid(m4);
            
            
            % Default times
            if (nargin < 3)
               t = ':'; 
            end
            
            if (nargin < 2)
                timeStampMode = 'mean';
            end
            
            % Calculate the time average
            for ii = 1:numel(m4)
                if (iscell(t))
                    ts = m4(ii).timeStamp(:,t{ii});
                    tt = t{ii};
                else
                    ts = m4(ii).timeStamp(:,t);
                    tt = t;
                end
                
                mat = mean(m4(ii).matrix(:,:,:,tt),4);
                
                switch (lower(timeStampMode))
                    case 'mean' 
                        ts = mean(ts,2);
                    case 'min'
                        ts = min(ts,[],2);
                    case 'max'
                        ts = max(ts,[],2);
                    otherwise
                        error('Matrix4D:timeAverage',['Unknown mode: ', timeStampMode]);
                end
                
                
                m4(ii) = Matrix4D(mat,ts, m4(ii).sampledTimeStamp, m4(ii).position, m4(ii).orientation,m4(ii).patientOrientation, m4(ii).voxelSize,...
                    m4(ii).sampledVoxelSize,m4(ii).sampledVoxelDistance,m4(ii).sampledMatrixSize,m4(ii).sampledPosition,...
                    m4(ii).sampledOrientation,m4(ii).imageUnit,m4(ii).imagingInfo,[m4(ii).name,': Time Averaged'],...
                    m4(ii).isoCenter);
            end
        end
        
        function output = view(m4,mode)    
            % Call the m4 viwer in desired mode.
            % Inpar:
            % m4 - Matrix 4D object array
            % mode - The mode in which to open the m4Viewer. (optional)
            %
            % Outpar:
            % output - The output of the viewer.
            errorOnInvalid(m4);
            output = [];
            if (nargin == 1)
                output = m4.view('ROIViewer4D');
            else
                switch(lower(mode))
                    case 'roiviewer4d'
                       if (isunix)
                         if (~exist('ROIViewer4D_linux.m','file'))
                             [p,f,e] = fileparts(which('ROIViewer4D.m'));
                             fc = 'ROIViewer4D_linux';
                             % Copy file to new name
                             copyfile(fullfile(p,[f,e]),fullfile(p,[fc,e]));  
                         end
                         output = ROIViewer4D_linux(m4);
                       else
                        output = ROIViewer4D(m4);
                       end
                    case 'view3dct'
                        for i = 1:numel(m4)
                            if (m4.matrixSize('t') ~= 1)
                                warndlg('The viewer "view3dct" only supports 3D data.');
                            end
                            
                            view3dct(setFormat(m4(i),'single'));
                        end
                    otherwise
                        error('Matrix4D:view',['Unsupported viewer: ',mode]);
                end
            end
        end
        
        function varargout = matrixSize(m4,dim)
            % Get the size of a Matrix4D object
            %
            % Inpar: 
            %   <m4>  A Matrix4D object.
            %   <dim>    A specific dimenension. Can be an index (1-4) or
            %   ('x','y','z','t'). Or an 1 x n vector of 1 - 4 or eg. 'xyt'
            %
            % Outpar:     
            %   <s>	A vector containing the size of the matrix
            %
            %
            % Error handling:
            %    Use try and catch
            %
            % Example
            % m4.matrixSize()
            % m4.matrixSize('y');
            % m4.matrixSize(1:3);
            % m4.matrixSize('yx');
            
            errorOnInvalid(m4);
            varargout = cell(1,numel(m4));
            
            for ii = 1:numel(m4)
                if (nargin == 1)
                    [s1,s2,s3,s4] = size(m4(ii).matrix);
                    siz = [s1,s2,s3,s4];
                else
                    if (size(dim,1)~=1)
                       error('The dimension parameter dim must be scalar a 1 x n vector of type char or contain the numbers 1-4.'); 
                    end
                    siz = zeros(size(dim));
                    for idim = 1:numel(dim)
                        if (ischar(dim))
                            switch (lower(dim(idim)))
                                case 'x'
                                    siz(idim) = size(m4(ii).matrix,1);
                                case 'y'
                                    siz(idim) = size(m4(ii).matrix,2);
                                case 'z'
                                    siz(idim) = size(m4(ii).matrix,3);
                                case 't'
                                    siz(idim) = size(m4(ii).matrix,4);
                                otherwise
                                    error('The dimensions must be 1-4 or a character x,y,z,t.'); 
                            end
                        else
                            if (dim(idim) > 4 || dim(idim)<1 || dim(idim) ~= round(dim(idim)))
                               error('The dimensions must be 1-4 or a character x,y,z,t.'); 
                            end
                            siz(idim) = size(m4(ii).matrix,dim(idim));
                        end
                    end
                end
                
                varargout{ii} = siz;
            end
        
        end
        
        function tf = isReal(m4)
            % Check if the data matrix is real.
            
            errorOnInvalid(m4);
            tf = false(size(m4));
            for ii = 1:numel(m4)
                tf(ii) = isreal(m4(ii).matrix);
            end
        end
        
        function m4 = FT(m4,dim)
           % Calculate the Fourier transform of the m4 object (array)
           %
           % Inpar:
           % m4     - An array of m4 objects
           % dim    - The dimensions to fourier transform specified as
           %        'xyzt' or any subset of these. (Optional, default xyz)
           %
           % Outpar:
           % m4     - The fourier transform of the input
           if (nargin == 1)
                dim = 'xyz';
           end 
           m4 = m4.internalFT('FT',dim);
        end
        
        function m4 = iFT(m4,dim)
           % Calculate the inverse Fourier transform of the m4 object (array)
           %
           % Inpar:
           % m4     - An array of m4 objects
           % dim    - The dimensions to fourier transform specified as
           %        'xyzt' or any subset of these. (Optional, default xyz)
           %
           % Outpar:
           % m4     - The fourier transform of the input
            if (nargin == 1)
                dim = 'xyz';
            end
            m4 = m4.internalFT('iFT',dim);
        end
        
        function m4 = resize(m4,newSize)
           % Resize the matrix to newSize. Clip if newSize is smaller than
           % matrixSize and zeropad if newSize is larger. OBS: Resize is
           % ONLY applied to the spatial dimensions. After resize the
           % position of the matrix may change if the resized data
           % dimensions are represented in x-space. If the data is
           % represeted in k-space the voxel size changes.
           %
           % Inpar:
           % m4         - An array of m4 objects
           % newSize    - 1 x 3 vector of the new size. Or if m4 is an
           %            array it is possible to use individual sizes. Then
           %            newSize is a cell array (same size as m4) of 1 x 3
           %            vectors.
           %
           % Outpar:
           % m4         - Resized m4
           %
           % Example:
           %    newObj = m4.resize([256,256,32]);
           
            % Check validity
            errorOnInvalid(m4);
           
           % Check that newSize is OK
           if (iscell(newSize))
              if (~isequal(size(newSize),size(m4)))
                   error('Matrix4D:resize','newSize represetend as a cell array must be the same size as m4');
              end 
               
              for ii = 1:numel(m4)
               if (~isequal(size(newSize{ii}),[1 3]))
                   error('Matrix4D:resize','The new size must be 1 x 3');
               end
               if (isnumeric(newSize{ii}))
                   error('Matrix4D:resize','The new size must be numeric');
               end
               if (~isequal(round(newSize{ii}),newSize{ii}))
                   error('Matrix4D:resize','The new size must be integers');
               end
               if (any(newSize{ii}<1))
                   error('Matrix4D:resize','The new size must be positive');
               end  
                  
              end
           else
               if (~isequal(size(newSize),[1 3]))
                   error('Matrix4D:resize','newSize must be 1 x 3');
               end
               if (~isnumeric(newSize))
                   error('Matrix4D:resize','newSize must be numeric');
               end
               if (~isequal(round(newSize),newSize))
                   error('Matrix4D:resize','newSize must be integers');
               end
               if (any(newSize<1))
                   error('Matrix4D:resize','newSize must be positive');
               end      
           end
           
           
           if (isnumeric(newSize))
              newSize = {newSize}; 
           end
           
           for ii = 1:numel(m4)
            % Check if resize is needed
            if (~isequal(m4(ii).matrixSize('xyz'),newSize{ii}))
                % New matrix
                oldSize = m4(ii).matrixSize('xyz');
                m4(ii).matrix = localCenteredResize(m4(ii).matrix,[newSize{ii},m4(ii).matrixSize('t')]);
                m4(ii).createdSize = size(m4(ii).matrix);
                
                % Change position and/or voxelsize
                
                % Voxel size change
                fdims = m4(ii).isFourierDimension('xyz');
                if (any(fdims))
                    m4(ii).voxelSize(fdims) = m4(ii).voxelSize(fdims)'.*oldSize(fdims)./newSize{ii}(fdims);
                end
                
                % Change the position of the matrix
                
                % For Fourier transformed dimensions the change is a
                % fraction of a pixel. For non-transformed dimensions it can 
                % be several pixels.
                tmpPosF = m4(ii).getVoxelPosition([1 1 1]'/2 + oldSize(:)./newSize{ii}(:)/2);  
                deltaCenter = floor(oldSize(:)/2)-floor(newSize{ii}(:)/2);
                tmpPosX =  m4(ii).getVoxelPosition([1 1 1]'+deltaCenter);
                tmpPos = zeros(3,1);
                tmpPos(fdims) = tmpPosF(fdims);
                tmpPos(~fdims) = tmpPosX(~fdims);
                m4(ii).position = tmpPos;  
            end
           end
           
            function newArray = localCenteredResize(oldArray,newArraySize)
                
                oldArraySize = [size(oldArray,1),size(oldArray,2),size(oldArray,3),size(oldArray,4)];
                
                subArraySize = min(oldArraySize, newArraySize);
                
                oldArrayCenter = floor(oldArraySize/2) + 1;
                newArrayCenter = floor(newArraySize/2) + 1;
                subArrayCenter = floor(subArraySize/2) + 1;
                
                newArray = zeros(newArraySize,class(oldArray));
                
                oldStartIndices = 1 + (oldArrayCenter - 1) - (subArrayCenter - 1);
                oldEndIndices = oldStartIndices + (subArraySize - 1);
                
                newStartIndices = 1 + (newArrayCenter - 1) - (subArrayCenter - 1);
                newEndIndices = newStartIndices + (subArraySize - 1);
                
                oldIndices = arrayfun(@(x,y)x:y,oldStartIndices,oldEndIndices,'UniformOutput',false);
                newIndices = arrayfun(@(x,y)x:y,newStartIndices,newEndIndices,'UniformOutput',false);
                
                newArray(newIndices{:}) = oldArray(oldIndices{:});
           end
            
        end
        
        
        function tf = isSpatialCompatible(m41,m42)
            % Check if two arrays of Matrix 4D objects are sapatially compatible. 
            % I.e. that the information refers to the same physical
            % locations in the PATIENT. The size of the arrays m41 and m42
            % must be equal or one must have a single element.
            %
            % Inpar: 
            % Two arrays of m4
            %
            % Outpar:
            % A matrix of logical values.
            %
            
            % Check validity
            errorOnInvalid(m41);
            errorOnInvalid(m42);
            
            % Check that the array sizes are appropriate and then that the
            % elements in the arrays are compatible.
            if ((numel(m41) ~= 1) && (numel(m42) ~= 1))
               tf = zeros(size(m41)) == 1;
               if (isequal(size(m41),size(m42)))
                   for ii = 1:numel(m41)
                       tf(ii) = internalIsSpatialCompatible(m41(ii),m42(ii));
                   end
               else
                  error('Matrix4D:spatialCompatible','The matrix arrays have different sizes and cannot be compared.'); 
               end
            elseif(numel(m41) == 1)
               tf = zeros(size(m42)) == 1;
               for ii = 1:numel(m42)
                   tf(ii) = internalIsSpatialCompatible(m41,m42(ii));
               end
            else 
               tf = zeros(size(m41)) == 1;
               for ii = 1:numel(m41)
                   tf(ii) = internalIsSpatialCompatible(m41(ii),m42);
               end 
            end
            
            
            
        end
        
        function FOV = getFOV(m4)
           % Return a structure array that defines the FOV for the m4 object.
           %
           % Inpar:
           % m4         - An array of m4 objects
           %
           % Outpar
           % Field of View structures as an array with the same size as m4:
           %    .size           (1 x 3) vector [no unit]
           %    .orientation    Rotation object
           %    .position       (3 x 1) vector [mm] / Patient coordsys
           %    .voxelSize      (3 x 1) vector [mm]
           
            % Check validity
            errorOnInvalid(m4);
            FOV = struct('size',[],'orientation',[],'position',[],'voxelSize',[]);
            sizm4 = num2cell(size(m4));
            FOV(sizm4{:}) = FOV;
            for ii = 1:numel(m4)
               siz =  m4(ii).matrixSize();
               FOV(ii).size = siz(1:3);
               FOV(ii).orientation = m4(ii).orientation;
               FOV(ii).position = m4(ii).position;
               FOV(ii).voxelSize = m4(ii).voxelSize;
            end    
        end
        
        function m4 = resample(m4,siz,method,extrapv)
            % Resample the spatial matrix to a new size. OBS currently only
            % functional for spatial 3D data. Cannot be used on 1D or 2D data.
            %
            % Inpar:
            % m4            - An array of m4 object to be resampled.
            % siz           - New size of the matrix after resampling. Must
            %               be a 1 x 3 vector.
            % method        - Resampling method. Can be 'spline 0-5' or
            %               'fourier'. Synonyms for spline 0-3 are: 'nearest'
            %               'linear','quadratic' and 'cubic', respectively.
            %               (Optional, default = 'linear')
            % extrapv       - Extrapolation value. (optional, default = 0)
            %
            %
            % Output:       - Resampled m4 object array. 
            
            % Check validity
            errorOnInvalid(m4);
            
            % Fill in defaults
            switch (nargin)
                case 2
                    method = 'linear';
                    extrapv = 0;
                case 3
                    extrapv = 0;
            end
            
            % Check the new size
            validateattributes(siz, {'numeric'},{'size',[1 3],'integer','positive'});
            
            % Helper functions
            FT = @(X,dim,sizf)(fft(iffshift(X),[],dim,sizf));
            iFT = @(X,dim)(fftshift(ifft(X,[],dim)));
            

            for ii = 1:numel(m4)
                % Create the new FOV
                newFOV = m4(ii).getFOV();
                newFOV.voxelSize = newFOV.voxelSize.*newFOV.size(:)./siz(:);
                newFOV.size = siz(:)';
                newFOV.position = newFOV.position - (m4(ii).voxelSize(:) - newFOV.voxelSize(:))/2;  
                
                switch (lower(method))
                    case {'nearest','spline 0'}
                        mat = m4(ii).itkResampleWrapper(newFOV,zeros(6,1),zeros(3,1),0,extrapv);
                    case {'linear','spline 1'}
                        mat = m4(ii).itkResampleWrapper(newFOV,zeros(6,1),zeros(3,1),1,extrapv);
                    case {'quadratic','spline 2'}
                        mat = m4(ii).itkResampleWrapper(newFOV,zeros(6,1),zeros(3,1),2,extrapv);
                    case {'cubic','spline 3'}
                        mat = m4(ii).itkResampleWrapper(newFOV,zeros(6,1),zeros(3,1),3,extrapv);
                    case 'spline 4'
                        mat = m4(ii).itkResampleWrapper(newFOV,zeros(6,1),zeros(3,1),4,extrapv);
                    case 'spline 5'
                        mat = m4(ii).itkResampleWrapper(newFOV,zeros(6,1),zeros(3,1),5,extrapv);
                    case 'fourier'
                        % M�STE FIXAS
                        mat = zeros([siz(:)',size(m4(ii),'t')]);
                        for idim = 1:numel(siz)
                           if (siz(idim) ~= m4(ii).matrixSize(idim))
                              mat = FT(mat(xrange,yrange,zrange,trange),idim,siz(idim));  
                           end
                        end

                        for idim = 1:numel(siz)
                           if (siz(idim) ~= m4(ii).matrixSize(idim))
                              mat = iFT(mat,idim);  
                           end
                        end

                        if (isReal(m4(ii)))
                            % Remove round-off errors resulting in non-zero
                            % imaginary part.
                            mat = real(mat);
                        end
                        
                        % FOV is identical but not the origo for the FFT
                        % method.
                        pos = getVoxelPosition(m4(ii),[1/2*(1+sizOld(1)/siz(1)) 1/2*(1+sizOld(2)/siz(2)) 1/2*(1+sizOld(3)/siz(3))]','Patient');
                    otherwise
                       error('Matrix4D:resample',['Unknown method: ',method]) 
                end
                
                % Create the new m4 object
                nz = m4(ii).matrixSize('z');
                nt = m4(ii).matrixSize('t');
                if (nt > 1 && nz > 1)
                    time = interp2((1:nz)/nz,1:nt,m4(ii).timeStamp',(1:siz(3))/siz(3),(1:nt)','linear')';
                elseif (nt == 1)
                    time = interp1((1:nz)/nz,m4(ii).timeStamp',(1:siz(3))/siz(3),'linear')';
                else % nz = 1
                    time = mean(m4(ii).timeStamp,1); 
                end
                            
                m4(ii) = Matrix4D(mat,time, m4(ii).sampledTimeStamp, newFOV.position, m4(ii).orientation,m4(ii).patientOrientation, newFOV.voxelSize,...
                                     m4(ii).sampledVoxelSize,m4(ii).sampledVoxelDistance,m4(ii).sampledMatrixSize,m4(ii).sampledPosition,...
                                     m4(ii).sampledOrientation,m4(ii).imageUnit,m4(ii).imagingInfo,[m4(ii).name,': Resampled'],...
                                     m4(ii).isoCenter);
            end
        end
        
        function m4 = resampleFOV(m4, FOV, varargin)
            % Resample the spatial matrix to a new FOV.
            %
            % Inpar:
            % m4                        - An array of m4 object to be resampled.
            % FOV                       - The new FOV. Either a FOV structure or a
            %                           m4. Or an array of FOV structures or m4s.
            % method                    - Resampling method. Can be 'spline 0-5' or
            %                           'fourier'. Synonyms for spline 0-3 are: 'nearest'
            %                           'linear','quadratic' and 'cubic', respectively.
            %                           (Optional, default = 'linear')
            % extrapv                   - Extrapolation value. (optional, default = 0)
            % errorOnNonFixIsoCenter    - Through an error if the isocenter is
            %                           not the same for all slices. (Optional, default
            %                           = true)
            %
            % Output:       - Resampled m4 object array. 
            
            % Call a special case of a more general transform.
            m4 = rigid3DTransform(m4,zeros(3,1),zeros(6,1),FOV,varargin{:});
        end
        
        function m4 = resampleTimeSeries(m4,newTimeStamp, method, extrapv)
            % Resample the timedimension of an array of m4. The timestamps 
            % (not the new ones) for the m4 must be distinct for all slices.   
            %
            % Inpar: 
            % m4                - An array of m4
            % newTimeStamp      - A nz x nt matrix of new timestamps. Can
            %                   also be a cell array of size 1 or the same size as the
            %                   m4-array. If only one newTimeStamp is
            %                   provided, it is applied to all m4. If the
            %                   timestamp is a 1 x nt vector it is applied
            %                   to all slices.
            % method            - Resampling method. Can be all methods that interp1 accepts.
            %                   (Optional, default = 'linear')
            % extrapv            - Extrapolation value. (optional, default = 0)
            
            % Check validity
            errorOnInvalid(m4);
            
            % Make sure that there is one timestamp per m4
            if (~isa(newTimeStamp,'cell'))
               newTimeStamp = {newTimeStamp}; 
            end
            
            if ((numel(newTimeStamp) == 1) && (numel(m4) > 1))
                tmp = newTimeStamp{1};
                newTimeStamp = cell(size(m4));
                for ii = 1:numel(m4)
                   newTimeStamp{ii} = tmp; 
                end
            end
            
            % Check that size if ok
            if (~isequal(size(m4),size(newTimeStamp)))
               error('Matrix4D:resampleTimeSeries','The array on new time stamps have the wrong size (not equal to size(m4).'); 
            end
            
            % Fill in defaults
            if (nargin == 2)
               method = 'linear';
               extrapv = 0;
            elseif (nargin == 3)
               extrapv = 0;
            end
            
            % Loop over all m4
            for ii = 1:numel(m4)
               % Get the new time stamp 
               ts = newTimeStamp{ii};
               % Make sure that there is one timestamps for each slice
               if (size(ts,1) == 1 && m4(ii).matrixSize(3) > 1)
                  ts = ones(m4(ii).matrixSize(3),1)*ts; 
               end
               if (size(ts,1) ~= m4(ii).matrixSize(3))
                  error('Matrix4D:resampleTimeSeries','The size of the timestamp must be 1 x n or nz x n, where nz is the number of slices in the matrix in the m4.'); 
               end
               
                            
               FOV = m4(ii).getFOV();
               mat = zeros([FOV.size,size(ts,2)],getFormat(m4(ii)));
               for iz = 1:m4(ii).matrixSize(3)
                   % Make sure that the timestamps for the m4 are unique  
                   if (numel(unique(m4(ii).timeStamp(iz,:))) ~= numel(m4(ii).timeStamp(iz,:)))
                      error('Matrix4D:resampleTimeSeries','The m4.timeStamp must be unique.');
                   end 
                   mat(:,:,iz,:) = permute(interp1(m4(ii).timeStamp(iz,:),permute(m4(ii).matrix(:,:,iz,:),[4,2,3,1]),ts(iz,:),method,extrapv),[4,2,3,1]);  
               end
               
                % Create output            
                m4(ii) = Matrix4D(mat,ts, m4(ii).sampledTimeStamp, m4(ii).position, m4(ii).orientation, m4(ii).patientOrientation, m4(ii).voxelSize,...
                                     m4(ii).sampledVoxelSize,m4(ii).sampledVoxelDistance,m4(ii).sampledMatrixSize,m4(ii).sampledPosition,...
                                     m4(ii).sampledOrientation,m4(ii).imageUnit,m4(ii).imagingInfo,[m4(ii).name,': Resampled timestamp'],...
                                     m4(ii).isoCenter);   
            end     
        end
        
        function m4 = rigid3DTransform(m4,centerOfRotation,varargin)
            % Perform a rigid 3D transformation on the spatial part of the
            % matrix. OBS: This function will make the timestamp uniform
            % for all slices.
            %
            % Input - Possibility 1
            % m4                        - Array of m4 objects 
            % centerOfRotation          - A 3 x 1 vector or a 3 x nt vector (one
            %                           vector per timepoint in the m4. This is
            %                           applied to all m4 in the array. Or a cell
            %                           array of (3 x 1) or (3 x nt) with the same
            %                           size as the m4 array. (One cell per m4
            %                           object.)
            % rotation                  - A Rotation object or an array of nt Rotation 
            %                           objects. Or in the same way as for centerOfRotation 
            %                           a cell array of Rotation objects (arrays).
            % translation               - A 3 x 1 vector or a 3 x nt vector (one
            %                           vector per timepoint in the m4. This is
            %                           applied to all m4 in the array. Or in the same way as for centerOfRotation 
            %                           cell array.
            % FOV                       - The new FOV. Either a FOV structure or a
            %                           m4. Or an array of FOV structures or m4s.
            %                           (Normal not cell array.) (optional,
            %                           default = the same as the m4)
            % method                    - Resampling method. Can be 'spline 0-5'. 
            %                           Synonyms for spline 0-3 are: 'nearest'
            %                           'linear','quadratic' and 'cubic', respectively.
            %                           (Optional, default = 'linear')
            % extrapv                   - Extrapolation value. (optional, default = 0)
            %                   
            %
            % Input - Possibility 2
            % The rotation and translation are replaced with a versor 
            % (6 x 1). Or 6 x nt or cell array with one versor per m4.
            %
            %
            % Output:
            % Array of transformed m4s.
            
            % Check validity
            errorOnInvalid(m4);
            
            % Check which input method that is used and (possibly) convert Rotations to versors. 
            if (isa(varargin{1},'Rotation'))
                inputMethod = 1; 
                % Number of arguments must be > 3
                if (nargin < 4)
                  error('Matrix4D:rigid3DTransform','No translation specified');  
                end
                
                % Put the translation of uniform representation
                if (isa(varargin{2},'cell'))
                    translation = varargin{2};
                elseif (isa(varargin{2},'double'))
                    translation = varargin(2);
                else
                   error('Matrix4D:rigid3DTransform','The translation must be a cell array or double matrix.') 
                end
                % Check that only one translation is specified for all m4s
                if (numel(translation)~=1)
                   error('Matrix4D:rigid3DTransform','The number of translations must equal the number of rotations specified.') 
                end
                
                % Check that the translation is ok
                if (numel(varargin{1}) ~= size(translation{1},2))
                   error('Matrix4D:rigid3DTransform','The number of translations must equal the number of rotations specified.') 
                end
                
                if (3 ~= size(translation{1},1))
                   error('Matrix4D:rigid3DTransform','The translations must be 3 x n vectors'); 
                end
                
                % Redy to build the versor
                q = [varargin{1}.quaternion];
                versor = {[q(2:4,:);translation{1}]};
                
            elseif (isa(varargin{1},'cell'))
                % Versors
                if (isAllVersor(varargin{1}))
                  inputMethod = 2;
                  versor = varargin{1};
                % Rotations    
                elseif (isAllRotations(varargin{1}))
                    inputMethod = 1;
                    % Get the translations
                    % Number of arguments must be > 3
                    if (nargin < 4)
                      error('Matrix4D:rigid3DTransform','No translation specified');  
                    end
                    
                    % The translation argument must be a cell array unless
                    % numel(varargin{1}) == 1 
                    if (numel(varargin{1}) == 1)
                        if (isa(varargin{1},'double'))
                           translation =  varargin(1);
                        elseif (isa(varargin{1},'cell'))
                           translation = varargin{1};
                        else
                            error('Matrix4D:rigid3DTransform','Wrong datatype for the translation.');
                        end
                    else
                        if (isa(varargin{1},'cell'))
                           translation = varargin{1}; 
                        else
                           error('Matrix4D:rigid3DTransform','Wrong datatype for the translation.'); 
                        end
                    end
                    
                    % The translation and rotation must have equal size
                    if (~isequal(size(translation),size(varargin{1})))
                       error('Matrix4D:rigid3DTransform','The translation and rotation must have equal size.'); 
                    end
                    

                    versor = cell(size(varargin{1}));
                    for ii = 1:numel(translation) 
                        % The size of the translation (for each rotation) must
                        % be ok. 
                        if (~isequal(size(translation{ii},2),numel(varargin{1})))
                         error('Matrix4D:rigid3DTransform','Each translation must have the same number of time-points as the rotations.') 
                        end

                        if (~isequal(size(translation{ii},1),3))
                         error('Matrix4D:rigid3DTransform','Each translation must be 3 x n.') 
                        end
                      
                        % Create the versor  
                        q = [varargin{1}{ii}.quaternion];
                        versor{ii} = [q(2:4,:);translation{1}];    
                    end
                    
                else
                    error('Matrix4D:rigid3DTransform','Argument three when a cell array: All elements must either be versors or Rotations.');
                end
                
            elseif (isa(varargin{1},'double'))
                versor = varargin(1);
                inputMethod = 2; 
            else
                error('Matrix4D:rigid3DTransform','Third argumnet should be a Rotation or versor.');
            end
            
            % If only one versor is specified. Create one for each m4
            if ((numel(versor)==1) && numel(m4) > 1)
               tmpVersor = versor;
               versor = cell(size(m4));
               for ii = 1:numel(m4)
                   versor{ii} = tmpVersor{1}; 
               end
            end
            
            % Check and make uniform: centerOfRotation
            if (isa(centerOfRotation,'double'))
                centerOfRotation = {centerOfRotation};
            elseif isa(centerOfRotation,'cell')
                % Nothing to do
            else
                error('Matrix4D:rigid3DTransform','The centerOfRotation must be a cell array or a double matrix.');
            end
            
            if (~isequal(size(centerOfRotation),size(m4)))
               if (numel(centerOfRotation) == 1)
                   tmp = centerOfRotation{1};
                   centerOfRotation = cell(size(m4));
                   for ii = 1:numel(m4)
                       centerOfRotation{ii} = tmp;
                   end
               else
                  error('Matrix4D:rigid3DTransform','The size of the centerOfRotation cell array wrong.'); 
               end
            end
            
            
            % Check that the number of versors specified is ok
            if (~isequal(size(m4),size(versor)))
               error('Matrix4D:rigid3DTransform','The number of transforms specified must be compatible with the size of the m4 array.');
            end
            
            % Fill in defaults
            if (inputMethod == 1)
                switch (nargin)
                    case 4
                        FOV = m4.getFOV();
                        method = 'linear';
                        extrapv = 0;
                    case 5
                        FOV = varargin{3};
                        method = 'linear';
                        extrapv = 0;
                    case 6
                        FOV = varargin{3};
                        method =varargin{4};
                        extrapv = 0;
                    case 7
                        FOV = varargin{3};
                        method = varargin{4};
                        extrapv = varargin{5};   
                    otherwise
                        error('Matrix4D:rigid3DTransform','Wrong number of input arguments.');
                end
            else % method 2
                switch (nargin)
                    case 3
                        FOV = m4.getFOV();
                        method = 'linear';
                        extrapv = 0;
                    case 4
                        FOV = varargin{2};
                        method = 'linear';
                        extrapv = 0;
                    case 5
                        FOV = varargin{2};
                        method =varargin{3};
                        extrapv = 0;
                    case 6
                        FOV = varargin{2};
                        method = varargin{3};
                        extrapv = varargin{4}; 
                    otherwise
                        error('Matrix4D:rigid3DTransform','Wrong number of input arguments.');
                end   
            end
            
            
            
            
            % Make sure that the size of FOV is ok and that the FOVs are
            % FOV structures.
            
            if (isa(FOV,'Matrix4D'))
               template(numel(FOV)) = struct('size',[],'orientation',[],'position',[],'voxelSize',[]);
               template = reshape(template,size(FOV));
               for ii = 1:numel(FOV)
                  template(ii) = FOV.getFOV(); 
               end
               FOV = template;
            end
            
            if (~isequal(size(FOV),size(m4)))
               if (numel(FOV) == 1)
                   FOV(size(m4)) = FOV;
                   for ii = 1:numel(m4)
                      FOV(ii) = FOV(1); 
                   end
               else
                   error('Matrix4D:rigid3DTransform','Wrong number of input arguments.');
               end
            end
            
            
            % Now all data is of the same size and: centerOfRotation,
            % versor, FOV and m4 all have the same size. And all input
            % arguments are defined.
            for ii = 1:numel(m4)    
                % Check if versors, centers of rot and FOV are ok and make
                % sure that one versor and centerofrot is supplied for each timepoint.
                try
                    [c,v] = m4.getUniformResampleParamsAndCheck(centerOfRotation{ii},versor{ii},FOV(ii));
                catch err
                   error('Matrix4D:rigid3DTransform',err.message); 
                end
                switch (lower(method))
                    case {'nearest','spline 0'}
                        mat = m4(ii).itkResampleWrapper(FOV(ii),v,c,0,extrapv);
                    case {'linear','spline 1'}
                        mat = m4(ii).itkResampleWrapper(FOV(ii),v,c,1,extrapv);
                    case {'quadratic','spline 2'}
                        mat = m4(ii).itkResampleWrapper(FOV(ii),v,c,2,extrapv);
                    case {'cubic','spline 3'}
                        mat = m4(ii).itkResampleWrapper(FOV(ii),v,c,3,extrapv);
                    case 'spline 4'
                        mat = m4(ii).itkResampleWrapper(FOV(ii),v,c,4,extrapv);
                    case 'spline 5'
                        mat = m4(ii).itkResampleWrapper(FOV(ii),v,c,5,extrapv);
                    otherwise
                       error('Matrix4D:rigid3DRegistration',['Unknown method: ',method]) 
                end
                
                % Create the new m4 object 
                time = ones(FOV(ii).size(3),1)*m4(ii).getVolumeTimeStamp('mean',1:m4(ii).matrixSize('t'));
                            
                m4(ii) = Matrix4D(mat,time, m4(ii).sampledTimeStamp, FOV(ii).position, FOV(ii).orientation, m4(ii).patientOrientation, FOV(ii).voxelSize,...
                                     m4(ii).sampledVoxelSize,m4(ii).sampledVoxelDistance,m4(ii).sampledMatrixSize,m4(ii).sampledPosition,...
                                     m4(ii).sampledOrientation,m4(ii).imageUnit,m4(ii).imagingInfo,[m4(ii).name,': Resampled'],...
                                     m4(ii).isoCenter);
            end              
        end
           
        function varargout = getCoordinateRepresentation(m4,inputCoordsys,outputCoordsys,positions)
            % Transforms the representation of positions between coordinate systems.
            %
            % Inpar:
            % m4                - An array of m4 objects defining the coordinate
            %                     transforms.
            % inputCoordsys     - The coordinate system in which the
            %                     input positions are presented.
            % outputCoordsys    - The coordinate system in which the
            %                     output positions are presented.
            % positions         - The input coordinate positions 3 x n.
            
            % Check
            errorOnInvalid(m4);
            if (size(positions,1) ~= 3 || numel(size(positions)) ~=2)
               error('Matrix4D:getCoordinateRepresentation','The positions must be a 3 x n matrix.') 
            end
            
            if (~isa(positions,'double') || ~isreal(positions))
                error('Matrix4D:getCoordinateRepresentation','The positions must be real double.') 
            end
            
            
            varargout = cell(1,numel(m4));
            
            
            for ii = 1:numel(m4)
               X = positions; 
               if (isequal(inputCoordsys,outputCoordsys)) 
                   % Nothing to do!
                   varargout{ii} = X;
               else
                p = m4(ii).position*ones(1,size(X,2));
                m = m4(ii).isoCenter;
                % Convert from the input coordsys   
                switch (lower(inputCoordsys)) 
                    case 'image'
                        % Nothing to do.
                    case 'patient'
                        X = m4(ii).orientation.inv()*(X - p);
                    case 'machine'  
                        X = m4(ii).orientation.inv()*( m4(ii).patientOrientation*X - p + m );
                end
                
                % Convert to the output coordsys
                switch (lower(outputCoordsys))
                    case 'image'
                        % Nothing to do.
                    case 'patient'
                        X = m4(ii).orientation * X + p;
                    case 'machine'
                        X = m4(ii).patientOrientation.inv()*( m4(ii).orientation * X + p - m );
                end
                
               end 
               varargout{ii} = X;
            end
            
        end
        
        function varargout = getVoxelPosition(m4,selection,coordsys,boundingBox)
            % Get the physical position of voxels in m4 objects.
            %
            % Inpar:
            % m4            - The m4 (can be an array) for which the
            %                 physical position is sought. The m4 can also function as a roi used for pixel selection if the input
            %                 selection is empty []. See below.
            % selection     - The selection of pixels. Can be a 3 x n
            %                 vector of (x,y,z) indexes or 1 x n vector of
            %                 linear indexes. The linear index must be positive and integer 
            %                 and within the size of the matrix. No
            %                 restrictions for the 3 x n indexes are used.
            %                 The selection can also be empty []. In that case the m4 is treated as a ROI and
            %                 pixels with value (~= 0) are used for
            %                 position calculation. OBS! The ROI has to be
            %                 3D i.e. the fourth dimension must be
            %                 singelton.
            % coordsys      - The coordinate system in which the results
            %                 are presented. Can be 'image','patient' and 'machine'.
            %                 (Optional, default = 'patient'.)
            % boundingBox   - If voxels outside the image volume should be
            %                 NaN or not. (Optional, default = false.)
            %
            % Output:       - A 3 x n matrix of positions. Or N such
            %                 matrixes if the m4 is an array with N elements.
            %               
            
            % Check the input
            errorOnInvalid(m4);
            
            % Set default values
            if (nargin == 2)
               coordsys = 'patient'; 
               boundingBox = false;
            elseif(nargin == 3)
               boundingBox = false; 
            end
            
           for ii = 1:numel(m4)
            if (isempty(selection)) % use the m4

                   if (matrixSize(m4(ii),'t')>1)
                      error('Matrix4D:getVoxelPosition','When the selection is empty and the m4 (first argument) is used as a roi. Each element in m4 must be 3D.'); 
                   end
                   linearIndex = find(m4(ii).matrix(:,:,:,1) ~= 0); 
                   sel = m4(ii).get3DIndexFromLinearIndex(linearIndex); %#ok<FNDSB>
                   if (boundingBox)
                     sel = m4(ii).applyBoundingBox(sel);  
                   end

            elseif (isnumeric(selection) && size(selection,1)==3 && numel(size(selection)) == 2) % 3 x n matrix
              if (boundingBox)
                sel = m4(ii).applyBoundingBox(selection);  
              else
                sel = selection;
              end
            elseif (isnumeric(selection) && size(selection,1)==1 && numel(size(selection)) == 2) % 1 x n vector
               % The linear index must be positive and integers
               try
                validateattributes(selection, {'numeric'}, {'nonempty','integer','positive','real'});
               catch err
                   error('Matrix4D:getVoxelPosition','The specified index of size 1 x n must only contain positive real integers.');
               end
               sel = m4(ii).get3DIndexFromLinearIndex(selection); 
               if (boundingBox)
                 sel = m4(ii).applyBoundingBox(sel);  
               end
            else
               error('Matrix4D:getVoxelPosition','Bad format on the selection of voxels.') 
            end
            
            % Get coordinates in the image coordsys
            posI = [(sel(1,:)-1)*m4(ii).voxelSize(1); (sel(2,:)-1)*m4(ii).voxelSize(2); (sel(3,:)-1)*m4(ii).voxelSize(3)];
            
            % Transform it to the desired coordsys
            varargout{ii} = m4(ii).getCoordinateRepresentation('image',coordsys,posI);
            
           end     
        end
        
        function varargout = getPositionVoxel(m4,position,coordsys,boundingBox,output,integerValues)
            % Get the voxels corresponding to physical positions.
            %
            % Inpar:
            % m4            - An array of m4 objects
            % position      - Physical positions 3 x n vector, real double/single.
            % coordsys      - The coordinate system in which the positions
            %                 are represented. (Optinal, default =
            %                 'patient'.)
            % boundingBox   - If the output is 'subscript' and this value i true. Outputs outside the matrix is set to NaN
            %                 If the output is 'roi' it has no effect since
            %                 data outside the matrix is ignoored.
            %                 If it is 'index' it has no effect since data
            %                 outside the matrix always is set to NaN.
            %                 (Optional, default = false.)
            % output        - Can be 'subscript' resulting in 3 x n vector
            %                 output. Can be 'index' resulting in 1 x n
            %                 vector output. (Several outputs if m4 has
            %                 more than one element.) Can also be 'roi'
            %                 resulting in an array of m4 objects (same size as 
            %                 the input m4). The rois will only have one
            %                 time-element weather the m4 elements have it
            %                 or not. (Optional, default = 'subscript'.)
            % integerValues - Has only effect if output = 'subscript'. In
            %                 that case the subscripts are rounded to
            %                 nearest integer if this option = true.
            %         
            % Output:       - A collection (one per m4 in the m4 input) of
            %                 subscripts (if output = 'subscript') or
            %                 indexes (if output = 'index') or an array of
            %                 m4 (if output = 'roi'). The size of the
            %                 collections and the array is the same as the
            %                 size of the m4 input array (first argument).
            % 
            
            % Check the input
            errorOnInvalid(m4);
            
            try
               validateattributes(position, {'single','double'}, {'nonempty','2d'})
            catch err
               error('Matrix4D:getPositionVoxel',['Position input error: ',err.message]); 
            end
            
            if (size(position,1)~=3)
               error('Matrix4D:getPositionVoxel','Position input error: The position vector must have size 3 x n.'); 
            end
            
            % Set the default values
            switch (nargin)
                case 2
                    coordsys        = 'patient';
                    boundingBox     = false;
                    output          = 'subscript';
                    integerValues   = true;
                case 3
                    boundingBox     = false;
                    output          = 'subscript';
                    integerValues   = true;  
                case 4
                    output          = 'subscript';
                    integerValues   = true; 
                case 5
                    integerValues   = true; 
            end
            
            % Prepare the output
            switch (lower(output))
                case {'index','subscript'}
                    varargout = cell(1,numel(m4));
                case 'roi'
                    varargout = {Matrix4D.array(size(m4))};
                otherwise
                    error('Matrix4D:getPositionVoxel',['Unknown output type: ',output])
            end
            
            for ii = 1:numel(m4)
                % Calculate the coordinates in the the image coordinate system.
                pos = getCoordinateRepresentation(m4(ii),coordsys,'image',position);
            
                % Get the corresponding subscripts - OBS need to permute x
                % and y.
                pos = pos./(m4(ii).voxelSize * ones(1,size(pos,2))) + ones(size(pos));
                
                
                % Adjustments
                if (integerValues)
                   pos = round(pos); 
                end
                
                if (boundingBox)
                   pos = m4(ii).applyBoundingBox(pos); 
                end
                
                % Create the output
                switch (lower(output))
                    case 'subscript'
                        varargout{ii} = pos;
                    case 'index'
                        varargout{ii} = m4(ii).getLinearIndexFrom3DIndex(pos);
                    case 'roi'
                        % Create a template for the output ROI
                        varargout{1}(ii) = m4(ii).subMatrix('t',[1,1]);
                        varargout{1}(ii).imagingInfo.Modality = 'ROI';
                        
                        index = m4(ii).getLinearIndexFrom3DIndex(round(pos));
                        varargout{1}(ii).matrix(index(~isnan(index))) = true;
                end
            end
        end
        
        function varargout = getSliceNormal(m4,coordsys)
            % Get the normal of the images. 
            % I.e. the vector that is perpendicular to any image slice and
            % point from slice 1 to slice 2.
            % 
            % Inpar:
            % m4 - A m4 object array.
            % coordsys - The coordinate system in which the normal is
            %            given (optional). Can be 'Patient' (default), 'Machine'
            %            or 'Image'. If 'Image' [0 0 1]' is always returned.
            %
            % Outpar:
            % The slice normal or a collection of normals if m4 is an
            % array.
            
            errorOnInvalid(m4);
            if (nargin == 1)
               coordsys = 'Patient';
            end
            
            varargout = cell(1,numel(m4));
            for ii = 1:numel(m4)
                switch (lower(coordsys))
                    case 'patient'
                        varargout{ii} = m4(ii).orientation*[0 0 1]';
                    case 'machine'
                        varargout{ii} = m4(ii).patientOrientation.inv()*m4(ii).orientation*[0 0 1]';
                    case 'image'
                        varargout{ii} = [0 0 1]';
                    otherwise 
                        error('Matrix4D:getSliceNormal',['Unknown coordinate system : ',coordsys]);
                end
            end
        end
        
        function m4 = setFormat(m4,format)
            % Set the format of the data in the Matrix 4D object
            %
            % m4 = setFormat(m4, format)| returns a Matrix4D object
            % with the data type specified in format. This can be used when you want to
            % change the data type of a Matrix4D object e.g. if you want to save memory
            % or define a mask which has a logical data type. The following data types are supported:
            %   
            % - int8, uint8, int16, uint16 int32, uint32, int64, uint64
            % - double, single
            % - logical
            %
            % If the data is complex only single and double is allowed.
            %
            % INPAR
            % * m4 - the Matrix4D object you wish to set the data type of.
            % * format - a string specifying the desired format.
            %
            % OUTPAR
            % m4 - a Matrix4D object identical to the input Matrix4D except for
            % the data type
            %
            % EXAMPLE
            % Set the data type of m4Mask to single:
            %
            %   m4Mask_single = setFormat(m4Mask,'single')
            %   m4Mask_single = m4Mask.setFormat('single')
            
            for ii = 1:numel(m4)
                if (m4.isReal())
                    switch (format)
                        case 'logical'
                            m4(ii).matrix = logical(m4(ii).matrix);
                        case 'single'
                            m4(ii).matrix = single(m4(ii).matrix);
                        case 'double'
                            m4(ii).matrix = double(m4(ii).matrix);
                        case 'int8'
                            m4(ii).matrix = int8(m4(ii).matrix);
                        case 'uint8'
                            m4(ii).matrix = uint8(m4(ii).matrix);
                        case 'int16'
                            m4(ii).matrix = int16(m4(ii).matrix);
                        case 'uint16'
                            m4(ii).matrix = uint16(m4(ii).matrix);
                        case 'int32'
                            m4(ii).matrix = int32(m4(ii).matrix);
                        case 'uint32'
                            m4(ii).matrix = uint32(m4(ii).matrix);
                        case 'int64'
                            m4(ii).matrix = int64(m4(ii).matrix);
                        case 'uint64'
                            m4(ii).matrix = uint64(m4(ii).matrix);
                        otherwise
                            error('Matrix4D:setFormat',['Not allowed format: ',format])
                    end
                else
                    switch (format)
                        case 'single'
                            m4(ii).matrix = single(m4(ii).matrix);
                        case 'double'
                            m4(ii).matrix = double(m4(ii).matrix);
                        otherwise
                            error('Matrix4D:setFormat',['Not allowed format for complex data: ',format])
                    end

                end
            end
        end
        
        function varargout = getFormat(m4)
            % Return the format of the m4 data matrix.
            varargout = {m4.format};
        end
        
        function export(m4,filenames,settings)
            % Export the data to file.
            %
            % Inpar:
            % m4        - Array of m4 objects.
            % filenames - Cell array of the same size as the m4 array with
            %           file names. No fileending is needed. It is
            %           ignoored. If left empty ([]), the name of the m4 is
            %           used.
            % settings          - Settings for the export.
            %   .path           - Path where to store the data
            %   .type           - File type. Can be: 'raw', 'nifti', 'dicom', 'mhd', 
            %                   'mha','bmp','gif','jpeg','tif','png'
            %   .complexType    - If the format doesn't support complex data per definition. 
            %                   The types in the cell array complexType is
            %                   used. Allowed values are:
            %                   'magnitute', 'phase', 'real', and 'imaginary'.
            %                   E.g. {'magnitude','phase'} or {'magnitude','real','imaginary'}
            % ... more to come
        end
        
        function varargout = roiMin(m4,roi)
            % Calculates the min value in a roi.
            % 
            % Inpar:
            % m4  -     An (array) of m4 objects
            % roi -     (Optional). An (array) of m4 objects with or a matrix
            %           with values between [0,1]. If no roi is supplied
            %           the entire data volume in m4 is used. (The roi is
            %           thresholded at 1/2.)
            %
            % Outpar:         
            %           The min value in the roi for each point in time.
            %           Return one vector for each element in m4 / roi if
            %           they are arrays.
            %
            % For more info about the restrictions and possibilities for
            % the input. See roiOperation
            % 
            %   See also Matrix4D.roiOperation.
            
            
            if (~isa(m4,'Matrix4D'))
                error('Matrix4D:roiMin','First argument must be a Matrix4D.');
            end
            if (nargin == 1)
                varargout = cell(1,numel(m4));
                [varargout{:}] = roiOperation(m4,[],@min);
                for ii = 1:numel(varargout)
                    varargout{ii} = cell2mat(varargout{ii});
                end
            elseif (isnumeric(roi))
                varargout = cell(1,numel(m4));
                [varargout{:}] = roiOperation(m4,roi,@min);
                for ii = 1:numel(varargout)
                    varargout{ii} = cell2mat(varargout{ii});
                end  
            else
                varargout = cell(1,max([numel(m4),numel(roi)]));
                [varargout{:}] = roiOperation(m4,roi,@min);
                for ii = 1:numel(varargout)
                    varargout{ii} = cell2mat(varargout{ii});
                end 
            end
        end
        
        function varargout = roiMax(m4,roi)
            % Calculates the max value in a roi.
            % 
            % Inpar:
            % m4  -     An (array) of m4 objects
            % roi -     (Optional). An (array) of m4 objects with or a matrix
            %           with values between [0,1]. If no roi is supplied
            %           the entire data volume in m4 is used. (The roi is
            %           thresholded at 1/2.)
            %
            % Outpar:         
            %           The max value in the roi for each point in time.
            %           Return one vector for each element in m4 / roi if
            %           they are arrays.
            %
            % For more info about the restrictions and possibilities for
            % the input. See roiOperation
            % 
            %   See also Matrix4D.roiOperation.
            
            
            if (~isa(m4,'Matrix4D'))
                error('Matrix4D:roiMax','First argument must be a Matrix4D.');
            end
            if (nargin == 1)
                varargout = cell(1,numel(m4));
                [varargout{:}] = roiOperation(m4,[],@max);
                for ii = 1:numel(varargout)
                    varargout{ii} = cell2mat(varargout{ii});
                end
            elseif (isnumeric(roi))
                varargout = cell(1,numel(m4));
                [varargout{:}] = roiOperation(m4,roi,@max);
                for ii = 1:numel(varargout)
                    varargout{ii} = cell2mat(varargout{ii});
                end  
            else
                varargout = cell(1,max([numel(m4),numel(roi)]));
                [varargout{:}] = roiOperation(m4,roi,@max);
                for ii = 1:numel(varargout)
                    varargout{ii} = cell2mat(varargout{ii});
                end 
            end
        end
        
        function varargout = roiMean(m4,roi)
            % Calculates the mean value in a roi.
            % 
            % Inpar:
            % m4  -     An (array) of m4 objects
            % roi -     (Optional). An (array) of m4 objects with or a matrix
            %           with values between [0,1]. If no roi is supplied
            %           the entire data volume in m4 is used. (The roi functions 
            %           as a wighting function for the mean calculation.)
            %
            % Outpar:         
            %           The mean value in the roi for each point in time.
            %           Return one vector for each element in m4 / roi if
            %           they are arrays.
            %
            % For more info about the restrictions and possibilities for
            % the input. See roiOperation
            % 
            %   See also Matrix4D.roiOperation.
            
            
            if (~isa(m4,'Matrix4D'))
                error('Matrix4D:roiMean','First argument must be a Matrix4D.');
            end
            if (nargin == 1)
                varargout = cell(1,numel(m4));
                [varargout{:}] = roiOperation(m4,[],@m4.weightedMean,true);
                for ii = 1:numel(varargout)
                    varargout{ii} = cell2mat(varargout{ii});
                end
            elseif (isnumeric(roi))
                varargout = cell(1,numel(m4));
                [varargout{:}] = roiOperation(m4,roi,@m4.weightedMean,true);
                for ii = 1:numel(varargout)
                    varargout{ii} = cell2mat(varargout{ii});
                end  
            else
                varargout = cell(1,max([numel(m4),numel(roi)]));
                [varargout{:}] = roiOperation(m4,roi,@m4.weightedMean,true);
                for ii = 1:numel(varargout)
                    varargout{ii} = cell2mat(varargout{ii});
                end 
            end
        end
        
        function varargout = roiStd(m4,roi)
            % Calculates the standarddeviation in a roi.
            % 
            % Inpar:
            % m4  -     An (array) of m4 objects
            % roi -     (Optional). An (array) of m4 objects with or a matrix
            %           with values between [0,1]. If no roi is supplied
            %           the entire data volume in m4 is used. (The roi functions 
            %           as a wighting function for the mean calculation.)
            %
            % Outpar:         
            %           The standarddeviation in the roi for each point in time.
            %           Return one vector for each element in m4 / roi if
            %           they are arrays.
            %
            % For more info about the restrictions and possibilities for
            % the input. See roiOperation
            % 
            %   See also Matrix4D.roiOperation.
            
            
            if (~isa(m4,'Matrix4D'))
                error('Matrix4D:roiStd','First argument must be a Matrix4D.');
            end
            if (nargin == 1)
                varargout = cell(1,numel(m4));
                [varargout{:}] = roiOperation(m4,[],@m4.weightedStd,true);
                for ii = 1:numel(varargout)
                    varargout{ii} = cell2mat(varargout{ii});
                end
            elseif (isnumeric(roi))
                varargout = cell(1,numel(m4));
                [varargout{:}] = roiOperation(m4,roi,@m4.weightedStd,true);
                for ii = 1:numel(varargout)
                    varargout{ii} = cell2mat(varargout{ii});
                end  
            else
                varargout = cell(1,max([numel(m4),numel(roi)]));
                [varargout{:}] = roiOperation(m4,roi,@m4.weightedStd,true);
                for ii = 1:numel(varargout)
                    varargout{ii} = cell2mat(varargout{ii});
                end 
            end
        end
        
        function roiAssign(m4,roi,value)
           % Assign values to a ROI.
           %
           % Inpar:
            
        end
        
        function varargout = roiHistogram(m4,edges,roi)
            % Calculates a histogram in a roi.
            % 
            % Inpar:
            % m4  -     An (array) of m4 objects
            % roi -     (Optional). An (array) of m4 objects with or a matrix
            %           with values between [0,1]. If no roi is supplied
            %           the entire data volume in m4 is used. (The roi is
            %           thresholded at 1/2.)
            %
            % Outpar:         
            %           The histogram in the roi for each point in time (nh x nt).
            %           Return one matrix for each element in m4 / roi if
            %           they are arrays.
            %
            % For more info about the restrictions and possibilities for
            % the input. See roiOperation
            % 
            %   See also Matrix4D.roiOperation.
            
            
            if (~isa(m4,'Matrix4D'))
                error('Matrix4D:roiHistogram','First argument must be a Matrix4D.');
            end
            if (nargin == 1)
                varargout = cell(1,numel(m4));
                [varargout{:}] = roiOperation(m4,[],@Matrix4D.transposedHist,false,edges);
                for ii = 1:numel(varargout)
                    varargout{ii} = cell2mat(varargout{ii});
                end
            elseif (isnumeric(roi))
                varargout = cell(1,numel(m4));
                [varargout{:}] = roiOperation(m4,roi,@Matrix4D.transposedHist,false,edges);
                for ii = 1:numel(varargout)
                    varargout{ii} = cell2mat(varargout{ii});
                end  
            else
                varargout = cell(1,max([numel(m4),numel(roi)]));
                [varargout{:}] = roiOperation(m4,roi,@Matrix4D.transposedHist,false,edges);
                for ii = 1:numel(varargout)
                    varargout{ii} = cell2mat(varargout{ii});
                end 
            end
        end
        
        function varargout = roiPercentile(m4,prc,roi)
            % Calculates percentile value in a roi.
            % 
            % Inpar:
            % m4  -     An (array) of m4 objects
            % prc -     Array of percentiles between 0 and 100.
            % roi -     (Optional). An (array) of m4 objects with or a matrix
            %           with values between [0,1]. If no roi is supplied
            %           the entire data volume in m4 is used. (The roi is
            %           thresholded at 1/2.)
            %
            % Outpar:         
            %           The percentile values in the roi for each point in time (np x nt).
            %           Return one matrix for each element in m4 / roi if
            %           they are arrays.
            %
            % For more info about the restrictions and possibilities for
            % the input. See roiOperation
            % 
            %   See also Matrix4D.roiOperation.
            
            
            if (~isa(m4,'Matrix4D'))
                error('Matrix4D:roiPercentile','First argument must be a Matrix4D.');
            end
            if (nargin == 1)
                varargout = cell(1,numel(m4));
                [varargout{:}] = roiOperation(m4,[],@Matrix4D.percentile,false,prc);
                for ii = 1:numel(varargout)
                    varargout{ii} = cell2mat(varargout{ii});
                end
            elseif (isnumeric(roi))
                varargout = cell(1,numel(m4));
                [varargout{:}] = roiOperation(m4,roi,@Matrix4D.percentile,false,prc);
                for ii = 1:numel(varargout)
                    varargout{ii} = cell2mat(varargout{ii});
                end  
            else
                varargout = cell(1,max([numel(m4),numel(roi)]));
                [varargout{:}] = roiOperation(m4,roi,@Matrix4D.percentile,false,prc);
                for ii = 1:numel(varargout)
                    varargout{ii} = cell2mat(varargout{ii});
                end 
            end
        end
        
        function z = plus(x,y)
            % + Plus. Add m4 objects.
            %
            % Syntax:
            % z = x + y;
            % z = x.plus(y);
            % z = plus(x,y)
            %
            % Inpar:
            % x - A m4 object (array) or numerical matrix.
            % y - A m4 object (array) or numerical matrix.
            %
            % See the function binaryOperation for exact desription on how a binary operation
            % like plus handles arrays as input and addition of matrixes
            % with and without more than one time point.
            %
            %   See also Matrix4D.binaryOperation.
            z = binaryOperation(x,y,@plus);
        end
        
        function z = minus(x,y)
            % x - y, minus. Subtract m4 objects.
            %
            % Syntax:
            % z = x - y;
            % z = x.minus(y);
            % z = minus(x,y)
            %
            % Inpar:
            % x - A m4 object (array) or numerical matrix.
            % y - A m4 object (array) or numerical matrix.
            %
            % See the function binaryOperation for exact desription on how a binary operation
            % like minus handles arrays as input and addition of matrixes
            % with and without more than one time point.
            %
            %   See also Matrix4D.binaryOperation.
            z = binaryOperation(x,y,@minus);
        end
        
        function z = uminus(x)    
            % Unary minus. Negates the values in the data in x.
            % The value is calculated for each element in the data matrix of x.
            % 
            % Example:
            %   z = -x;
            errorOnInvalid(x);
            z = x;
            for ii = 1:numel(z)
                z(ii).matrix = -z(ii).matrix;
            end
        end
        
        function z = times(x,y)
            % x.*y, multiply. Multiply m4 objects.
            %
            % Syntax:
            % z = x .* y;
            % z = x.times(y);
            % z = times(x,y)
            %
            % Inpar:
            % x - A m4 object (array) or numerical matrix.
            % y - A m4 object (array) or numerical matrix.
            %
            % See the function binaryOperation for exact desription on how a binary operation
            % like times handles arrays as input and addition of matrixes
            % with and without more than one time point. 
            %
            %   See also Matrix4D.binaryOperation.
            z = binaryOperation(x,y,@times);
        end
        
        function z = rdivide(x,y)
            % x./y, divide. Divide m4 objects.
            %
            % Syntax:
            % z = x ./ y;
            % z = x.rdivide(y);
            % z = rdivide(x,y)
            %
            % Inpar:
            % x - A m4 object (array) or numerical matrix.
            % y - A m4 object (array) or numerical matrix.
            %
            % See the function binaryOperation for exact desription on how a binary operation
            % like rdivide handles arrays as input and addition of matrixes
            % with and without more than one time point. 
            %
            %   See also Matrix4D.binaryOperation.
            z = binaryOperation(x,y,@rdivide);
        end
        
        function z = power(x,y)
            % x.^y, exponentiation. Exponentiate m4 objects.
            %
            % Syntax:
            % z = x .^ y;
            % z = x.power(y);
            % z = power(x,y)
            %
            % Inpar:
            % x - A m4 object (array) or numerical matrix.
            % y - A m4 object (array) or numerical matrix.
            %
            % See the function binaryOperation for exact desription on how a binary operation
            % like power handles arrays as input and addition of matrixes
            % with and without more than one time point. 
            %
            %   See also Matrix4D.binaryOperation.
            z = binaryOperation(x,y,@power);  
        end
        
        function z = eq(x,y)
            % x == y, equality. Check for equality between m4 objects.
            %
            % Syntax:
            % z = x == y;
            % z = x.eq(y);
            % z = eq(x,y)
            %
            % Inpar:
            % x - A m4 object (array) or numerical matrix.
            % y - A m4 object (array) or numerical matrix.
            %
            % See the function binaryOperation for exact desription on how a binary operation
            % like eq handles arrays as input and addition of matrixes
            % with and without more than one time point. 
            %
            %   See also Matrix4D.binaryOperation.
            z = binaryOperation(x,y,@eq); 
        end
        
        function z = ne(x,y)
            % x ~= y, inequality. Check for inequality between m4 objects.
            %
            % Syntax:
            % z = x ~= y;
            % z = x.ne(y);
            % z = ne(x,y)
            %
            % Inpar:
            % x - A m4 object (array) or numerical matrix.
            % y - A m4 object (array) or numerical matrix.
            %
            % See the function binaryOperation for exact desription on how a binary operation
            % like ne handles arrays as input and addition of matrixes
            % with and without more than one time point. 
            %
            %   See also Matrix4D.binaryOperation.
            z = binaryOperation(x,y,@ne);  
        end
        
        function z = lt(x,y)
            % x < y, less than. Compare m4 objects.
            %
            % Syntax:
            % z = x < y;
            % z = x.lt(y);
            % z = lt(x,y)
            %
            % Inpar:
            % x - A m4 object (array) or numerical matrix.
            % y - A m4 object (array) or numerical matrix.
            %
            % See the function binaryOperation for exact desription on how a binary operation
            % like lt handles arrays as input and addition of matrixes
            % with and without more than one time point. 
            %
            %   See also Matrix4D.binaryOperation.
            z = binaryOperation(x,y,@lt); 
        end
        
        function z = gt(x,y)
            % x > y, greater than. Compare m4 objects.
            %
            % Syntax:
            % z = x > y;
            % z = x.gt(y);
            % z = gt(x,y)
            %
            % Inpar:
            % x - A m4 object (array) or numerical matrix.
            % y - A m4 object (array) or numerical matrix.
            %
            % See the function binaryOperation for exact desription on how a binary operation
            % like gt handles arrays as input and addition of matrixes
            % with and without more than one time point. 
            %
            %   See also Matrix4D.binaryOperation.
            z = binaryOperation(x,y,@gt);
        end
        
        function z = ge(x,y)
            % x >= y, greater than or equal. Compare m4 objects.
            %
            % Syntax:
            % z = x >= y;
            % z = x.ge(y);
            % z = ge(x,y)
            %
            % Inpar:
            % x - A m4 object (array) or numerical matrix.
            % y - A m4 object (array) or numerical matrix.
            %
            % See the function binaryOperation for exact desription on how a binary operation
            % like ge handles arrays as input and addition of matrixes
            % with and without more than one time point. 
            %
            %   See also Matrix4D.binaryOperation.
            z = binaryOperation(x,y,@ge);
        end
        
        function z = le(x,y)
            % x <= y, less than or equal. Compare m4 objects.
            %
            % Syntax:
            % z = x <= y;
            % z = x.le(y);
            % z = le(x,y)
            %
            % Inpar:
            % x - A m4 object (array) or numerical matrix.
            % y - A m4 object (array) or numerical matrix.
            %
            % See the function binaryOperation for exact desription on how a binary operation
            % like le handles arrays as input and addition of matrixes
            % with and without more than one time point. 
            %
            %   See also Matrix4D.binaryOperation.
            z = binaryOperation(x,y,@le);
        end
        
        function z = sin(x)
            % Sine of arguments in radians.
            % The value is calculated for each element in the data matrix of x.
            % 
            % Example:
            %   z = x.sin();
            %   z = sin(x);
            z = unaryOperation(x,@sin);
        end
            
        function z = cos(x)
            % Cosine of arguments in radians.
            % The value is calculated for each element in the data matrix of x.
            % 
            % Example:
            %   z = x.cos();
            %   z = cos(x);
            z = unaryOperation(x,@cos);
        end
        
        function z = tan(x)
            % Tangent of argument in radians.
            % The value is calculated for each element in the data matrix of x.
            % 
            % Example:
            %   z = x.tan();
            %   z = tan(x);
            z = unaryOperation(x,@tan);
        end
        
        function z = asin(x)
            % Inverse sine; result in radians.
            % The value is calculated for each element in the data matrix of x.
            % 
            % Example:
            %   z = x.asin();
            %   z = asin(x);
            z = unaryOperation(x,@asin);
        end
        
        function z = acos(x)
            % Inverse cosine; result in radians.
            % The value is calculated for each element in the data matrix of x.
            % 
            % Example:
            %   z = x.acos();
            %   z = acos(x);
            z = unaryOperation(x,@acos);
        end
        
        function z = atan(x)
            % Inverse tangent; result in radians.
            % The value is calculated for each element in the data matrix of x.
            % 
            % Example:
            %   z = x.atan();
            %   z = atan(x);
            z = unaryOperation(x,@atan);
        end
        
        function z = exp(x)
            % Exponential (with natural base).
            % The value is calculated for each element in the data matrix of x.
            % 
            % Example:
            %   z = x.exp();
            %   z = exp(x);
            z = unaryOperation(x,@exp);
        end
        
        function z = log(x)
            % Natural logarithm.
            % The value is calculated for each element in the data matrix of x.
            % 
            % Example:
            %   z = x.log();
            %   z = log(x);
            z = unaryOperation(x,@log);
        end
        
        function z = log2(x)
            % Logarithm with base 2.
            % The value is calculated for each element in the data matrix of x.
            % 
            % Example:
            %   z = x.log2();
            %   z = log2(x);
            z = unaryOperation(x,@log2);
        end
        
        function z = log10(x)
            % Logarithm with base 10.
            % The value is calculated for each element in the data matrix of x.
            % 
            % Example:
            %   z = x.log10();
            %   z = log10(x);
            z = unaryOperation(x,@log10);
        end
        
        function z = sqrt(x)
            % Square root.
            % The value is calculated for each element in the data matrix of x.
            % 
            % Example:
            %   z = x.sqrt();
            %   z = sqrt(x);
            z = unaryOperation(x,@sqrt);
        end
        
        function z = abs(x)
            % Absolute value and complex magnitude.
            % The value is calculated for each element in the data matrix of x.
            % 
            % Example:
            %   z = x.abs();
            %   z = abs(x);
            z = unaryOperation(x,@abs);
        end
        
        function z = real(x)
            % Real part of complex data.
            % The value is calculated for each element in the data matrix of x.
            % 
            % Example:
            %   z = x.real();
            %   z = real(x);
            z = unaryOperation(x,@real);     
        end
        
        function z = imag(x)
            % The imaginary part of complex data.
            % The value is calculated for each element in the data matrix of x.
            % 
            % Example:
            %   z = x.imag();
            %   z = iamg(x);
            z = unaryOperation(x,@imag);
        end
        
        function z = angle(x)
            % Phase angle of complex data.
            % The value is calculated for each element in the data matrix of x.
            % 
            % Example:
            %   z = x.angle();
            %   z = angle(x);
            z = unaryOperation(x,@angle);
        end
        
        function z = conj(x)
            % Complex conjugate of the data matrix.
            % The value is calculated for each element in the data matrix of x.
            % 
            % Example:
            %   z = x.conj();
            %   z = conj(x);
            z = unaryOperation(x,@conj);
        end
        
        function z = sign(x)
            % Signum function.
            % The value is calculated for each element in the data matrix of x.
            % 
            % Example:
            %   z = x.sign();
            %   z = sign(x);
            z = unaryOperation(x,@sign);
        end
        
        function z = mod(x,y)
            % mod(x,y), Modulus after division of two m4 objects.
            %
            % Syntax:
            % z = mod(x,y);
            % z = x.mod(y);
            %
            % Inpar:
            % x - A m4 object (array) or numerical matrix.
            % y - A m4 object (array) or numerical matrix.
            %
            % See the function binaryOperation for exact desription on how a binary operation
            % like mod handles arrays as input and addition of matrixes
            % with and without more than one time point. 
            %
            %   See also Matrix4D.binaryOperation.
            z = binaryOperation(x,y,@mod);
        end
        
        function z = round(x)
            % Round to nearest integer.
            % The value is calculated for each element in the data matrix of x.
            % 
            % Example:
            %   z = x.round();
            %   z = round(x);
            z = unaryOperation(x,@round);       
        end
        
        function z = ceil(x)
            % Round toward positive infinity.
            % The value is calculated for each element in the data matrix of x.
            % 
            % Example:
            %   z = x.ceil();
            %   z = ceil(x);
            z = unaryOperation(x,@ceil); 
        end
        
        function z = floor(x)
            % Round toward negative infinity.
            % The value is calculated for each element in the data matrix of x.
            % 
            % Example:
            %   z = x.floor();
            %   z = floor(x);
            z = unaryOperation(x,@floor);
        end
        
        function z = unaryOperation(x,func_handle,varargin)
           % Perform a unary operation on the data matrix.
           % Inpar:
           % x              - A m4 object (array).
           % func_handle    - A function handle to a unary function
           % params         - Extra params to the function
           %
           % Outpar:
           % A new m4 object.
           
            errorOnInvalid(x);
            z = x;
            for ii = 1:numel(z)
                z(ii).matrix = func_handle(z(ii).matrix,varargin{:});
            end    
        end
        
        function z = binaryOperation(x,y,func_handle,elementWise,varargin)
        % Perform a binary operation on the data matrixes.
        % Inpar:
        % x - A m4 object (array).
        % y - A m4 object (array).
        % func_handle - A function handle to a binary function
        % elementWise - (optional) If true (default) then it is allowed for
        %               both x and y to be non-singelton arrays of m4.
        % params        (optional) extra parameters sent to the func_handle
        %
        % Outpar:
        % A new m4 object.
        %
        % Syntax example:
        % z = binaryOperation(x,y,@func);
        % z = x.binaryOperation(y,@func);
        %   
        % Inpar:
        % x - A m4 object (array) or numerical matrix.
        % y - A m4 object (array) or numerical matrix.
        %
        %
        %
        % Size restriction and functionallity: (elementWise = true)
        %
        % If both x and y are m4 arrays:
        % - x and y must be arrays of the same size unless one of them
        %   have size = 1.
        % - The elements in the arrays x and y must be spatially
        %   compatible. I.e. if both have size > 1, then x(ii) and
        %   y(ii) must be compatible. If e.g. x has size 1 then y(ii) must
        %   be compatible with x for all ii.
        % - If one array contain only a single element, that array is
        %   applied to all the elements in the other array.
        % - If both x and y have equal number of time dimensions then z
        %   gets all its properties from x (timeStamp, position, ...).
        % - If x and y has different number of timedimensions an error
        %   is generated unless one of x or y has one single time dimension. 
        % - If x or y has a single time dimension that data is used for
        %   each timepoint in the other matrix. The data with more
        %   timepoints gives the properties to the output.
        % 
        % If one x or y is a numerical scalar:
        % - The scalar is combined with the data matrix in each element in
        %  the m4 array using the binary operation specified.
        %
        % If one of x or y is a numerical matrix:
        % - If the size of the numerical matrix 4:th dimesion matches
        %   that of the m4 time dimension then the numerical matrix
        %   combined with the m4 data matrix using the binary operation specified.
        % - If the size of the numerical matrix 4:th dimension is 1
        %   then the numerical matrix is combined with each timepoint in the
        %   m4 object data matrix using the binary operation specified.
        %
        %
        %
        % Size restriction and functionallity: (elementWise = false)
        % - Operations when both x and y are m4 arrays where both x and y
        %   have more than one element is not allowed. 
           
           
           
           % Check if we are working with two m4 objects or not
           if (isa(x,'Matrix4D') && isa(y,'Matrix4D'))
               % Check the input
               errorOnInvalid(x);
               errorOnInvalid(y);
               
               % x and y is m4
               % If not elementwise (do extra check)
               if (nargin < 4)
                   elementWise = true;
               end
               if (~elementWise)
                   if ((numel(x)>1) && (numel(y)>1))
                       error('Matrix4D:binaryOperation',['Both x and y cannot be m4-arrays with size > 1 for a non-elementwise operation like: ', func2str(func_handle)]);
                   end
               end
               
               if (~isequal(size(x),size(y)) && (numel(x)>1) && (numel(y) > 1))
                  error('Matrix4D:binaryOperation','When both inputs are arrays of m4, there sizes must be equal'); 
               end

               % Check spatial compability
               tf = isSpatialCompatible(x,y);
               if (any(~tf(:)))
                  error('Matrix4D:binaryOperation','The two arrays of m4 objects are not spatially compatible.'); 
               end

               % Allocate the output
               if (numel(x)>numel(y))
                z = Matrix4D.array(size(x));
                N = numel(x);
               else
                z = Matrix4D.array(size(y));
                N = numel(y);   
               end



               % Loop over the arrays
               for ii = 1:N
                  nx = min([ii,numel(x)]);
                  ny = min([ii,numel(y)]);

                  % Look at the time-dim to decide which object that
                  % dominates
                  tx = matrixSize(x(nx),'t');
                  ty = matrixSize(y(ny),'t');

                  if (tx == ty)
                      z(ii) = x(nx);
                      z(ii).matrix = func_handle(x(nx).matrix,y(ny).matrix,varargin{:});
                  elseif (tx > 1 && ty == 1)
                      z(ii) = x(nx);
                      % It can be the case that func_handle doesn't return
                      % the same type as class(z(ii).matrix). To ensure
                      % correct type. This is set explicitly here
                      type = class(func_handle(x(nx).matrix(1),y(ny).matrix(1),varargin{:}));
                      z(ii).format = type;
                      for t = 1:tx
                        z(ii).matrix(:,:,:,t) = func_handle(x(nx).matrix(:,:,:,t),y(ny).matrix,varargin{:});  
                      end
                  elseif (ty > 1 && tx == 1)
                      z(ii) = y(ny);
                      % Explicit settings of type
                      type = class(func_handle(x(nx).matrix(1),y(ny).matrix(1),varargin{:}));
                      z(ii).format = type;
                      for t = 1:ty
                        z(ii).matrix(:,:,:,t) = func_handle(x(nx).matrix,y(ny).matrix(:,:,:,t),varargin{:});  
                      end
                  else
                      error('Matrix4D:binaryOperation',['Time dimension missmatch. nt_x = ',num2str(tx),' nt_y = ',num2str(ty)]);
                  end

               end
           elseif (isa(x,'Matrix4D'))

                   z = x;
                   errorOnInvalid(z);
                   
                   % Check the size of the primitive data
                   if (numel(y)==1)
                        % y is a scalar
                        for ii = 1:numel(x)
                           z(ii).matrix = func_handle(x(ii).matrix, y,varargin{:}); 
                        end     
                   else
                        [nx,ny,nz,nt] = size(y);
                        for ii = 1:numel(x)
                            if (nt~=1)
                                if (~isequal([nx,ny,nz,nt],size(x(ii).matrix)))
                                   error('Matrix4D:binaryOperation','The size of the m4 data matrix does not mach the size of the numerical input.'); 
                                end
                                z(ii).matrix = func_handle(x(ii).matrix, y,varargin{:});
                            else
                                % Explicit settings of type
                               type = class(func_handle(x(ii).matrix(1),y(1),varargin{:}));
                               z(ii).format = type;
                                for t = 1:x(ii).matrixSize('t')
                                    z(ii).matrix(:,:,:,t) = func_handle(x(ii).matrix(:,:,:,t), y,varargin{:});
                                end
                            end

                        end
                   end
           elseif (isa(y,'Matrix4D'))
               
               z = y;
               errorOnInvalid(z);
               
               % Check the size of the primitive data
               if (numel(x)==1)
                   % x is a scalar
                   for ii = 1:numel(y)
                       z(ii).matrix = func_handle(x, y(ii).matrix,varargin{:});
                   end
               else
                   [nx,ny,nz,nt] = size(x);
                   for ii = 1:numel(y)
                       if (nt~=1)
                           if (~isequal([nx,ny,nz,nt],size(y(ii).matrix)))
                               error('Matrix4D:binaryOperation','The size of the m4 data matrix does not mach the size of the numerical input.');
                           end
                           z(ii).matrix = func_handle(x, y(ii).matrix,varargin{:});
                       else
                           % Explicit settings of type
                           type = class(func_handle(x(1),y(ii).matrix(1),varargin{:}));
                           z(ii).format = type;
                           for t = 1:y(ii).matrixSize('t')
                               z(ii).matrix(:,:,:,t) = func_handle(x, y(ii).matrix(:,:,:,t),varargin{:});
                           end
                       end
                       
                   end
               end
               
           else % Likely this error cannot happen. But if it does, a message is appropriate to find the bug!
               error('Matrix4D:binaryOperation','At least one of the inputs to the binary operation must be a Matrix4D object.');
           end
  
        end   
        
        function varargout = roiOperation(m4,roi,roiMeasure_handle,useSoftROI,varargin)
            % A general ROI operation on the m4 data. 
            % 
            % Inpar:
            % m4                - An array of m4 objects, must be the same size as roi unless roi only is one element or m4 is one element.
            % roi               - An array of m4 objects, must be the same size
            %                     as m4 unless m4 only is one element or roi is one element.
            %                     Can be a matrix and is then counted as
            %                     one single element. Can be empty [] which
            %                     is equivalent to a roi covering the
            %                     entire m4.
            % roiMeasure_handle - A function handle to a functions that
            %                     evaluate the roi to a result. Can return
            %                     anything and should take atleast one
            %                     input (the data inside the roi) if
            %                     useSoftROI is false. Should take atleast
            %                     two arguments if useSoftROI is true. E.i.
            %                     the data in the ROI and the ROI values.
            % useSoftROI        - Weigth the voxels with the ROI if this is
            %                     set to true. (Optional default = false)
            % varargin          - Passed as extra arguments to roiMeasure_handle.
            %
            %
            % Outpar:           - For each element in the bigger of m4 or
            %                     roi a cell array with results from the
            %                     roiMeasure function is returned. One cell
            %                     element per timepoint.
            %
            % Restrictions on the input data
            % - The m4 and roi must have the same size unless one of them
            %   only contain a single element.
            % - The m4 and the roi must refere to the same physical data.
            % - m4(ii) and roi(ii) must have the same number of time points
            %   for all ii. Unless m4(ii) or roi(ii) have a singelton time
            %   dimension.
            % - If roi is supplied as a matrix it is viewed exactly as a
            %   single roi m4-object. Which is spatially compatible with
            %   the m4 array if the matrix-sizes agree. The same rule for
            %   the time dimension as for the m4-object roi applies.
            
            
            
            % Check that the type of input is ok
            if (~(isa(m4,'Matrix4D') && isa(roiMeasure_handle,'function_handle')))
                error('Matrix4D:roiOperation','The first argument must be a m4 and the second argument must be a function handle.');
            end
            if (~isempty(roi))
                if (~(isa(roi,'Matrix4D') || isnumeric(roi)))
                    error('Matrix4D:roiOperation','The third argument must be a m4 or a numeric matrix.');
                end
            end
            
            if (nargin<4)
                useSoftROI = false;
            end
            
            % Check that the inputs are valid and compatible
            errorOnInvalid(m4);
            if (~isempty(roi))
               if (isa(roi,'Matrix4D'))
                errorOnInvalid(roi); 
                try
                 tf = isSpatialCompatible(m4,roi);
                 if (any(~tf(:)))
                    error('Matrix4D:roiOperation','The m4 and roi spatial dimensions are incompatible.'); 
                 end
                catch err % Incompatible array sizes
                    error('Matrix4D:roiOperation','The m4 and roi array sizes are incompatible.');
                end
                
                % Check data content is ok and that the time dimension is
                % ok.
                for ii = 1:numel(roi)
                   if (~roi(ii).isReal())
                       error('Matrix4D:roiOperation','The elements in the ROI must be real.');
                   end
                   
                   if (max(roi(ii).matrix(:)) > 1 || min(roi(ii).matrix(:)) < 0)
                       error('Matrix4D:roiOperation','The elements in the ROI have values in the range [0,1].');
                   end
                   
                   troi = matrixSize(roi(ii),'t');
                   tm4  = matrixSize(roi(ii),'t');
                   
                   if (troi ~= tm4 && troi > 1 && tm4 > 1)
                      error('Matrix4D:roiOperation','Time dimesion missmatch.'); 
                   end
                end
                
               else % Numeric ROI
                   [nx,ny,nz,nt] = size(roi);
                   
                   if (max(roi(:)) > 1 || min(roi(:)) < 0)
                       error('Matrix4D:roiOperation','The elements in the ROI have values in the range [0,1].');
                   end
                   
                   for ii = 1:numel(m4)
                       siz = matrixSize(m4(ii));
                       if (~isequal([nx,ny,nz],siz(1:3)))
                          error('Matrix4D:roiOperation','Space dimesion missmatch.'); 
                       end
                       
                       if (nt ~= 1)
                           if (nt ~= siz(4) && nt ~= 1)
                               error('Matrix4D:roiOperation','Time dimesion missmatch.'); 
                           end
                       end
                   end
               end
               
            end % End check ROI
            
            % The case when no ROI is supplied
            if (isempty(roi))
                
                varargout = cell(1,numel(m4));
                for ii = 1:numel(m4)
                   roiResult = cell(1,matrixSize(m4,'t'));
                   for t = 1:matrixSize(m4,'t')
                        mat_t = m4(ii).matrix(:,:,:,t);
                        if (useSoftROI)
                            roiResult{t} = roiMeasure_handle(mat_t(:),[],varargin{:});
                        else
                            roiResult{t} = roiMeasure_handle(mat_t(:),varargin{:});
                        end
                   end
                   varargout{ii} = roiResult;
                end     
            
            % The case when a numeric roi is supplied
            elseif (isnumeric(roi))
                if (~useSoftROI)
                   % Make the ROI a hard ROI.
                   roi = roi > 0.5;  
                end
                varargout = cell(1,numel(m4));
                for ii = 1:numel(m4)
                   nt = max([matrixSize(m4(ii),'t'),size(roi,4)]); 
                   roiResult = cell(1,nt);
                   for t = 1:nt
                        im4  = min([t,matrixSize(m4(ii),'t')]);
                        iroi = min([t,size(roi,4)]);
                        roi_i = roi(:,:,:,iroi);
                        mat_t = m4(ii).matrix(:,:,:,im4);
                        if (useSoftROI)
                            roiResult{t} = roiMeasure_handle(mat_t(roi_i>0),roi_i(roi_i>0),varargin{:});
                        else
                            roiResult{t} = roiMeasure_handle(mat_t(roi_i>0.5),varargin{:});
                        end
                   end
                   varargout{ii} = roiResult;
                end 
               
            % The case when the roi is m4    
            else
                if (~useSoftROI)
                   % Make the ROI a hard ROI.
                   roi = roi > 0.5;  
                end
                nOut = max([numel(m4),numel(roi)]);
                varargout = cell(1,nOut);
                
                for ii = 1:nOut
                   nm4 = min([ii,numel(m4)]);
                   nroi = min([ii,numel(roi)]);
                   
                   nt = max([matrixSize(m4(nm4),'t'),matrixSize(roi(nroi),'t')]); 
                   roiResult = cell(1,nt);
                   for t = 1:nt
                        tm4  = min([t,matrixSize(m4(nm4),'t')]);
                        troi = min([t,matrixSize(roi(nroi),'t')]);
                        roi_t = roi(nroi).matrix(:,:,:,troi);
                        mat_t = m4(nm4).matrix(:,:,:,tm4);
                        
                        if (useSoftROI)
                            roiResult{t} = roiMeasure_handle(mat_t(roi_t>0),roi_t(roi_t>0),varargin{:});
                        else
                            roiResult{t} = roiMeasure_handle(mat_t(roi_t>0.5),varargin{:});
                        end

                   end
                   varargout{ii} = roiResult;
                end 
                
            end
            
            
        end % End function
        
        function varargout = isFourierDimension(m4,dims)
            % Tell if data in some dimension specified as 'xyzt' in input is 
            % represeted in fourier transform space.
            %
            % Inpar:
            % m4    - Array of m4 objects
            % dims  - Dimensions to check. Use dims = 'xyzt' or subsets
            %
            % Outpar:
            % If m4 is 1 x 1 a logical array of the same size as dims
            % If m4 is not 1 x 1 a cell array of logical arrays.
            
            % Check that the input is valid
            errorOnInvalid(m4);
            if (nargin == 1)
               dims =  Matrix4D.dimOrder;
            end
            if (sum(ismember(dims,Matrix4D.dimOrder)) ~= numel(dims))
               error('Matrix4D:isFourierDimension','fourierDimensions must represeted as x,y,z, or t.'); 
            end
            varargout = cell(size(m4));
            for ii = 1:numel(m4)
                varargout{ii} = ismember(dims,m4(ii).fourierDimensions);
            end 
        end
    end
    
    % Helper methods
    methods (Access = private)
        function  tf = internalIsSpatialCompatible(m41,m42)
         size1 = m41.matrixSize();
         size2 = m42.matrixSize();   
         tf = isequal(size1(1:3),size2(1:3)) && isequal(m41.voxelSize,m42.voxelSize) && isequal(m41.position,m42.position) && ...
              (m41.orientation == m42.orientation);
        
        end
        
        function tf = errorOnInvalid(m4)
            invalidMatrix = ~m4.isvalid();
            if (any(invalidMatrix(:)))
                tf = true;
            else
                tf = false;
            end
            if (nargout == 0)
                if (tf)
                    error('Matrix4D:errorOnInvalid','The object is no longer a valid Matrix 4D object since the size of the data has changed. You have assigned a matrix to m4.matrix that have incorrect size. Please debug your code.')
                end
            end
        end
        
        function m4 = internalFT(m4,type,dim)
            errorOnInvalid(m4);
            
            
            for ii = 1:numel(m4)
                % Check that the format of the matrixes in m4 is accurate.
                % E.i. single or double. Separate loop to not make the user
                % wait for failur.
                if (~isequal(m4(ii).format,'single') && ~isequal(m4(ii).format,'double'))
                    error(['Matrix4D:',type],'All m4s in m4 must have datatype double or single.');
                end
            end
            
            newFTDim = false(1,4);
            for ii = 1:numel(dim)
                index = find(Matrix4D.dimOrder == dim(ii),1);
                newFTDim(index) = true;
            end
            for ii = 1:numel(m4)
                % Set which dimensions that are represetned in fourier space
                % after the FT operation.
                oldFTDim = m4(ii).isFourierDimension;
                
                m4(ii).fourierDimensions = xor(oldFTDim,newFTDim);
                
                % Change matrix format if required
                m4(ii).matrix = localFuncFT(m4(ii).matrix,dim);
            end
            
            % Performs the actual fourier transform
            function mat = localFuncFT(mat,dim)
                
                for d = dim
                    dimIndex = find(d == Matrix4D.dimOrder,1);
                    mat = ifftshift(mat,dimIndex); 
                    switch (type)
                        case 'FT'
                            mat = fft(mat,[],dimIndex)/sqrt(size(mat,dimIndex));
                        case 'iFT'
                            mat = ifft(mat,[],dimIndex)*sqrt(size(mat,dimIndex));
                    end
                    mat = fftshift(mat,dimIndex);
                end
                
            end
            
        end
        
        
        function index3D = get3DIndexFromLinearIndex(m4,index1D)
            index3D = zeros(3,numel(index1D));
            siz = m4.matrixSize(1:3);
            outsideMatrix = index1D<1 | index1D>prod(siz);
            index3D(:,outsideMatrix) = NaN;
            [index3D(1,~outsideMatrix),index3D(2,~outsideMatrix),index3D(3,~outsideMatrix)] = ind2sub(siz,index1D(~outsideMatrix));
        end
        
        function index1D = getLinearIndexFrom3DIndex(m4,index3D)
            siz = m4.matrixSize(1:3);
            % Find indexes outside the volume matrix
            outsideMatrix = (index3D(1,:) < 1) | (index3D(2,:) < 1) | (index3D(3,:) < 1) | ...
                            (index3D(1,:) > siz(1)) | (index3D(2,:) > siz(2)) | (index3D(3,:) > siz(3));
            index1D = NaN(1,size(index3D,2));          
            % Find inside matrix
            index1D(~outsideMatrix) = sub2ind(siz,index3D(1,~outsideMatrix),index3D(2,~outsideMatrix),index3D(3,~outsideMatrix));                
        end
        
        function index3D = applyBoundingBox(m4,index3D)
            index3D(index3D<1) = NaN;
            for idim = 1:3
             index3D(idim,index3D(idim,:)>matrixSize(m4,idim)) = NaN;
            end
        end     
        
        function mat = itkResampleWrapper(m4,newFOV,versor,center,interpOrder,extrapv)
            % Use ITK to resample (and transform) the data in m4 to a new FOV. 
            mat = zeros([newFOV.size,m4.matrixSize('t')],getFormat(m4));
            for t = 1:m4.matrixSize('t')    
               % Allow one for all or one for one 
               if (size(versor,2)>1)
                  v = versor(:,t); 
               else
                  v = versor; 
               end
               
               if (size(center,2)>1)
                  c = center(:,t); 
               else
                  c = center; 
               end
               
               % There is an issue with the resampleAndTransformMex file
               % that it cannot handle 1D or 2D images as the original
               % image. A uggly fix is used here. Any singelton dimension
               % is converted to 2 pixels with half the size. Ideally this
               % should be changed with a better version of
               % resampleAndTransformMex if possible.
               
               % Resample
               
               % Find singelton dimensions
               tmpDim = [1 1 1];
               sDims = m4.matrixSize(1:3) == 1;
               tmpDim(sDims) = 2;
               tmpMat = repmat(m4.matrix(:,:,:,t),tmpDim);
               vSize = m4.voxelSize(:)./tmpDim(:);
               % The position of the upper corner moves -1/4 of original
               % voxelsize in the direction were the size of the matrix has
               % been changed to 2 (from 1).
               pos = m4.position - m4.orientation*(m4.voxelSize(:).*double(sDims(:))/4);
               
               if (m4.isReal())
                   mat(:,:,:,t) = resampleAndTransformMex(tmpMat,pos,m4.orientation.matrix,vSize, ...
                       newFOV.position, newFOV.orientation.matrix, newFOV.voxelSize, newFOV.size, ...
                       v,c,extrapv,interpOrder);
                   % Old version with problem with 1D and 2D
%                     mat(:,:,:,t) = resampleAndTransformMex(m4.matrix(:,:,:,t),m4.position,m4.orientation.matrix,m4.voxelSize, ...
%                                                         newFOV.position, newFOV.orientation.matrix, newFOV.voxelSize, newFOV.size, ...
%                                                         v,c,extrapv,interpOrder); 
               else
                   mat(:,:,:,t) = resampleAndTransformMex(real(tmpMat),pos,m4.orientation.matrix,vSize, ...
                       newFOV.position, newFOV.orientation.matrix, newFOV.voxelSize, newFOV.size, ...
                       v,c,extrapv,interpOrder) + ...
                       1i*resampleAndTransformMex(imag(tmpMat),pos,m4.orientation.matrix,vSize, ...
                       newFOV.position, newFOV.orientation.matrix, newFOV.voxelSize, newFOV.size, ...
                       v,c,extrapv,interpOrder);
                   
                   % Old version with problem with 1D and 2D
%                     mat(:,:,:,t) = resampleAndTransformMex(real(m4.matrix(:,:,:,t)),m4.position,m4.orientation.matrix,m4.voxelSize, ...
%                                                         newFOV.position, newFOV.orientation.matrix, newFOV.voxelSize, newFOV.size, ...
%                                                         v,c,extrapv,interpOrder) + ...
%                                    1i*resampleAndTransformMex(imag(m4.matrix(:,:,:,t)),m4.position,m4.orientation.matrix,m4.voxelSize, ...
%                                                         newFOV.position, newFOV.orientation.matrix, newFOV.voxelSize, newFOV.size, ...
%                                                         v,c,extrapv,interpOrder);
                   
               end
            end 
        end
        
        % Helper for rigid3DTransform
        function [c,v] = getUniformResampleParamsAndCheck(m4,centerOfRotation,versor,FOV)
           % Check FOV
           if (~(isa(FOV,'struct')))
              error('Matrix4D:getUniformResampleParamsAndCheck','The FOV must be a FOV-structure.') 
           end
           
           if (~all(isfield(FOV,{'size','orientation','position','voxelSize'})))
              error('Matrix4D:getUniformResampleParamsAndCheck','Field(s) are missing in the FOV-structure.') 
           end
           
           if (~isequal(size(FOV.size),[1 3]))
              error('Matrix4D:getUniformResampleParamsAndCheck','The FOV size must be a 1 x 3 vector'); 
           end
           
           if (~isequal(size(FOV.position),[3 1]))
              error('Matrix4D:getUniformResampleParamsAndCheck','The position size must be a 3 x 1 vector'); 
           end
           
           if (~isa(FOV.orientation,'Rotation'))
              error('Matrix4D:getUniformResampleParamsAndCheck','The orientation must be a Rotation'); 
           end
           
           if (~isequal(size(FOV.voxelSize),[3 1]))
              error('Matrix4D:getUniformResampleParamsAndCheck','The voxel size must be a 3 x 1 vector'); 
           end
           
           % Check centerOfRot and make the same size as the m4 (in
           % timedim)
           if (~isa(centerOfRotation,'double'))
              error('Matrix4D:getUniformResampleParamsAndCheck','The centerOfRoation must be of type double.'); 
           end
           
           if (~isequal(size(centerOfRotation,1),3))
              error('Matrix4D:getUniformResampleParamsAndCheck','The centerOfRotation must be a 3 x n matrix.'); 
           end
           
           if (size(centerOfRotation,2) == 1)
               c = centerOfRotation * ones(1,m4.matrixSize('t'));
           else
               c = centerOfRotation;
           end
           
           if (size(c,2) ~= m4.matrixSize('t'))
               error('Matrix4D:getUniformResampleParamsAndCheck','The size of centerOfRotation is not compatible with the timedimension of the Matrix4D object.');
           end
    
           
           % Check versor and make the same size as the m4 (in
           % timedim)
           if (~isa(versor,'double'))
              error('Matrix4D:getUniformResampleParamsAndCheck','The versor must be of type double.'); 
           end
           
           if (~isequal(size(versor,1),6))
              error('Matrix4D:getUniformResampleParamsAndCheck','The versor must be a 6 x n matrix.'); 
           end
           
           if (size(versor,2) == 1)
               v = versor * ones(1,m4.matrixSize('t'));
           else
               v = versor;
           end
           
           if (size(v,2) ~= m4.matrixSize('t'))
               error('Matrix4D:getUniformResampleParamsAndCheck','The size of versor is not compatible with the timedimension of the Matrix4D object.');
           end
        end
        
    end
    
    % Static helper methods
    methods (Static = true, Access = private)
        function [defaultViewer,defaultImportFileFormat] = getConfigurationSettings() %#ok<STOUT>
           % Should be reimplemented to fetch the info from a file!! 
           fid = fopen('m4config.txt','r');
           str = fread(fid,Inf,'uint8=>char')';
           fclose(fid);
           eval(str);
        end
        
        function mu = weightedMean(x,w)
            if (isempty(w))
                mu = mean(x(:));
            else
                mu = sum(x(:).*w(:))/sum(w(:));
            end
        end
        
        function s = weightedStd(x,w)
            % The weighted sample mean using roi as weights
            % s^2 = V/(V^2-V)*sum(w(i)*(x(i)-mu)^2)
            % mu = sum(x(i)*w(i))/V
            % V = sum(w(i))
            if (isempty(w))
                s = std(x(:));
            else
                V = sum(w(:)); % Total weight
                mu = Matrix4D.weightedMean(x,w); % Weighted mean
                s = sqrt(V/(V^2-V)*sum(w(:).*(x(:)-mu).^2)); % Weighted std
            end
        end
        
        function pval = percentile(x,p)
           % Calculates the percentiles of x defined in p
           
           % Check input: p in [0 100]
           if (any(p(:)<0) || any(p(:)>100))
               error('Matrix4D:percentile','The percentiles must be in the interval [0 100]');
           end
           
           x = sort(x(:));
           index = (1 + round((numel(x)-1)*p/100));
           
           pval = x(index(:));
        end
        
        function thist = transposedHist(x,edges)
           thist = histc(x(:),edges)'; 
        end
        
        function m4 = init(matrix, timeStamp, sampledTimeStamp, position, orientation, patientOrientation, voxelSize, sampledVoxelSize, ...
                   sampledVoxelDistance, sampledMatrixSize, sampledPosition, sampledOrientation, imageUnit, imagingInfo, name, isoCenter)
            % Init input and check for errors. 
        
            if (isempty(matrix))
               error('Matrix4D:init','The data matrix cannot be empty.'); 
            end
            % Check the input parameters individually
            Matrix4D.checkInput(timeStamp, sampledTimeStamp, position, orientation, patientOrientation, voxelSize, sampledVoxelSize, ...
                    sampledVoxelDistance, sampledMatrixSize, sampledPosition, sampledOrientation, imageUnit, imagingInfo, name, isoCenter, false);
                
            % Check that the matrix size and the timestamp are compatible
            [~,~,nz,nt] = size(matrix);
            [ts_nz,ts_nt] = size(timeStamp);
            
            if (~(nz == ts_nz && nt == ts_nt))
                error('Matrix4D:init','The sizes of the data matrix and the timestamp are not compatible.');
            end
        
            % Check that the sampled matrix size and the sampled timestamp
            % are compatible.
            [ts_nz,ts_nt] = size(sampledTimeStamp);
            
            if (~(sampledMatrixSize(3) == ts_nz && sampledMatrixSize(4) == ts_nt))
                error('Matrix4D:init','The sizes of the sampled data matrix and the sampled timestamp are not compatible.');
            end
            

            
            % Assign
            m4.matrix                 = matrix;
            m4.timeStamp              = timeStamp;
            m4.sampledTimeStamp       = sampledTimeStamp;
            m4.position               = position;
            m4.orientation            = orientation; 
            m4.patientOrientation     = patientOrientation;
            m4.voxelSize              = voxelSize; 
            m4.sampledVoxelSize       = sampledVoxelSize; 
            m4.sampledVoxelDistance   = sampledVoxelDistance;
            m4.sampledMatrixSize      = sampledMatrixSize;
            m4.sampledPosition        = sampledPosition;
            m4.sampledOrientation     = sampledOrientation; 
            m4.imageUnit              = imageUnit; 
            m4.imagingInfo            = imagingInfo; 
            m4.name                   = name; 
            m4.isoCenter              = isoCenter;

        end
        
        function [timeStamp, sampledTimeStamp, position, orientation, patientOrientation, voxelSize, sampledVoxelSize, ...
         sampledVoxelDistance, sampledMatrixSize, sampledPosition, sampledOrientation, imageUnit, imagingInfo, name, isoCenter] = parseInput(varargin)
         % Parse input and set missing data to empty.
         
         timeStamp              = [];
         sampledTimeStamp       = [];
         position               = [];
         orientation            = []; 
         patientOrientation     = [];
         voxelSize              = []; 
         sampledVoxelSize       = []; 
         sampledVoxelDistance   = [];
         sampledMatrixSize      = [];
         sampledPosition        = [];
         sampledOrientation     = []; 
         imageUnit              = []; 
         imagingInfo            = []; 
         name                   = [];
         isoCenter              = [];

         for ii = 1:2:numel(varargin)
             if (~isa(varargin{ii},'char'))
                error('Matrix4D:parseInput','The input values must be in name, value pairs.'); 
             end
             switch (lower(varargin{ii}))
                 case 'timestamp' 
                     timeStamp = varargin{ii+1};
                 case 'sampledtimestamp'
                     sampledTimeStamp = varargin{ii+1};
                 case 'position'
                     position = varargin{ii+1};
                 case 'orientation' 
                     orientation = varargin{ii+1};
                 case 'patientorientation'
                     patientOrientation = varargin{ii+1};
                 case 'voxelsize'
                     voxelSize = varargin{ii+1};
                 case 'sampledvoxelsize'   
                     sampledVoxelSize = varargin{ii+1};
                 case 'sampledvoxeldistance' 
                     sampledVoxelDistance = varargin{ii+1};
                 case 'sampledmatrixsize'
                     sampledMatrixSize = varargin{ii+1};
                 case 'sampledposition'
                     sampledPosition = varargin{ii+1};
                 case 'sampledorientation'
                     sampledOrientation = varargin{ii+1};
                 case 'imageunit'
                     imageUnit = varargin{ii+1};
                 case 'imaginginfo'  
                     imagingInfo = varargin{ii+1};
                 case 'name'
                     name = varargin{ii+1};
                 case 'isocenter'
                     isoCenter = varargin{ii+1};  
                 otherwise
                     error('Matrix4D:parseInput',['Unknown property name: ',varargin{ii}]);
             end
         end
         
         % Check each input parameter individually
         Matrix4D.checkInput(timeStamp, sampledTimeStamp, position, orientation, patientOrientation, voxelSize, sampledVoxelSize, ...
                    sampledVoxelDistance, sampledMatrixSize, sampledPosition, sampledOrientation, imageUnit, imagingInfo, name, isoCenter, true);
        end
        
        function [matrix,timeStamp, sampledTimeStamp, position, orientation, patientOrientation, voxelSize, sampledVoxelSize, ...
         sampledVoxelDistance, sampledMatrixSize, sampledPosition, sampledOrientation, imageUnit, imagingInfo, name, isoCenter] = fillinMissing2Default(matrix, timeStamp, sampledTimeStamp, position, orientation, patientOrientation, voxelSize, sampledVoxelSize, ...
                           sampledVoxelDistance, sampledMatrixSize, sampledPosition, sampledOrientation, imageUnit, imagingInfo, name, isoCenter)
            % Fill in missing data to default values and/or use existing data
            % as support.
            
            % Matrix cannot be empty
            if (isempty(matrix))
               error('Matrix4D:fillinMissing2Default','The data matrix cannot be empty.'); 
            end
            
            % Fillin the sampledMatrixSize
            if (isempty(sampledMatrixSize))
                sampledMatrixSize = [0 0 0 0];
               [sampledMatrixSize(1),sampledMatrixSize(2),sampledMatrixSize(3),sampledMatrixSize(4)] = size(matrix); 
            end
            
            % No sliceIsoCenter? Fill it in.
            if (isempty(isoCenter))
                isoCenter = [NaN,NaN,NaN]'; 
            end
            
            % No timeStamp? Check if sampledTimeStamp size fit that of the
            % matrix. If use it. Otherwise use the the matrix size and set it to zeros.
            if (isempty(timeStamp))
               if (isempty(sampledTimeStamp))
                  timeStamp = zeros(size(matrix,3),size(matrix,4)); 
               elseif (size(matrix,3) == size(sampledTimeStamp,1) && size(matrix,4) == size(sampledTimeStamp,2))
                  timeStamp = sampledTimeStamp; 
               else
                  timeStamp = zeros(size(matrix,3),size(matrix,4));  
               end
            end
            
            
            % No sampledTimeStamp? Check if timeStamp size fit that of the
            % sampled matrix size. If use it. Otherwise use sampled matrix size and set it to zeros.
            if (isempty(sampledTimeStamp))
               if (isempty(timeStamp))
                  sampledTimeStamp = zeros(sampledMatrixSize(3),sampledMatrixSize(4)); 
               elseif (sampledMatrixSize(3) == size(timeStamp,1) && sampledMatrixSize(4) == size(timeStamp,2))
                  sampledTimeStamp =  timeStamp; 
               else
                  sampledTimeStamp = zeros(sampledMatrixSize(3),sampledMatrixSize(4));  
               end
            end    
            
            % Missing position or orientation
            [position,sampledPosition] = Matrix4D.crossInitOrDefault(position,sampledPosition,[0 0 0]');
            [orientation,sampledOrientation] = Matrix4D.crossInitOrDefault(orientation,sampledOrientation,Rotation());

            % Missing patientOrientation
            if (isempty(patientOrientation))
                patientOrientation = Rotation();
            end
            
            % Missing voxelsize / sampledVoxelSize / sampledVoxelDistance
            if (isempty(voxelSize))
                [sampledVoxelSize,sampledVoxelDistance] = Matrix4D.crossInitOrDefault(sampledVoxelSize,sampledVoxelDistance,[1 1 1]');
                [voxelSize,sampledVoxelDistance] = Matrix4D.crossInitOrDefault(voxelSize,sampledVoxelDistance,[1 1 1]');      
            else
                if (isempty(sampledVoxelSize) && isempty(sampledVoxelDistance))
                   sampledVoxelDistance = voxelSize;
                   sampledVoxelSize     = voxelSize;
                else
                    [sampledVoxelSize,sampledVoxelDistance] = Matrix4D.crossInitOrDefault(sampledVoxelSize,sampledVoxelDistance,[1 1 1]');
                end
            end               
        end
        
        function checkInput(varargin)
                inputNames = {'timeStamp', 'sampledTimeStamp', 'position', 'orientation', 'patientOrientation', 'voxelSize', 'sampledVoxelSize', ...
                    'sampledVoxelDistance', 'sampledMatrixSize', 'sampledPosition', 'sampledOrientation', 'imageUnit', 'imagingInfo', 'name','isoCenter'};  
                classes = {{'double'},{'double'},{'double'},{'Rotation'},{'Rotation'},{'double'},{'double'},{'double'},{'double'},{'double'},{'Rotation'},{'char'},{'struct'},{'char'},{'double'}};
                nDims = 2*ones(1,16);
                sizes = {[],[],3,[1 1],[1 1],3,3,3,4,3,[1 1],[],[1 1],[],3};
                isVector =       [0 0 1 0 0 1 1 1 1 1 0 0 0 0 0];
                emptyAlwaysOk =  [0 0 0 0 0 0 0 0 0 0 0 1 1 1 0];
                emptyOk = emptyAlwaysOk | varargin{end};
                
                % Check the input parameters that they individually are ok
                for ii = 1:(numel(varargin)-1)
                    Matrix4D.checkInputParam(varargin{ii}, classes{ii}, nDims(ii), sizes{ii}, isVector(ii), emptyOk, inputNames{ii});
                end
        end
         
        function checkInputParam(param, classes, nDims, sizes, isVector, emptyIsOk, paramName) 
            % Check a single input parameter
            
            if (~emptyIsOk)
             if (isempty(param))
                 error('Matrix4D:checkInputParam',['Empty parameter : ',paramName]);
             end
            elseif (isempty(param))
                return; % Empty was ok!
            end
            
            tf = false;
            for ii = 1:numel(classes)
                if (isa(param,classes{ii}))
                    tf = true;
                end
            end
            if (~tf)
               error('Matrix4D:checkInputParam',['Wrong class = ', class(param),', for the input: ',paramName]); 
            end
            
            if (isVector)
               if (~isvector(param))
                   error('Matrix4D:checkInputParam',['The input is not a vector: ',paramName]);
               end
               if (~isempty(sizes))
                  if (sizes(1) ~= numel(param))
                     error('Matrix4D:checkInputParam',['The input vector (',paramName ,') has the wrong size =  ',num2str(numel(param)),' should be: ',num2str(sizes(1))]); 
                  end
               end
            else
                for ii = 1:numel(sizes)
                  if (sizes(ii) ~= size(param,ii))
                     error('Matrix4D:checkInputParam',['The input matrix (',paramName ,') has the wrong size =  ',num2str(numel(param)),' on dim = ', num2str(ii),' should be: ',num2str(sizes(ii))]); 
                  end
                end
            end
            
            if (~isempty(nDims))
                if (nDims ~= numel(size(param)))
                    error('Matrix4D:checkInputParam',['The input ',paramName,' has ',num2str(numel(size(param))),' dims. Should be: ',num2str(nDims)]);
                end
            end
        end
        
        function [x,y] = crossInitOrDefault(x,y,default)
        % If one of x or y is empty. Set the empty to the nonempty. If both empty, x = y = default.    
            if (isempty(x))
               if (isempty(y))
                   x = default;
               else
                   x = y;
               end
            end
            if (isempty(y))
               if (isempty(x))
                   y = default;
               else
                   y = x;
               end
            end
        end
        
        % Helpers for rigid3DTransform
        function tf = isAllVersor(v)
            tfArray = false(1,numel(v));
            for ii = 1:numel(v)
               if (isa(v,'double'))
                  if (size(v,1)==6)
                     tfArray(ii) = true; 
                  end
               end
            end
            tf = all(tfArray);
        end
        
        function tf = isAllRotation(r)
            tfArray = false(1,numel(r));
            for ii = 1:numel(r)
               if (isa(v,'Rotation'))
                     tfArray(ii) = true; 
               end
            end
            tf = all(tfArray);
        end
        
        
        
    end
    
    % DICOM import helper functions
    methods (Access = private, Static = true)
        
        function [m4Array,importInfo] = importDICOM3D(filePath, settings)
           % Imports dicoms based on the v3 of the standard. This function is not fully developed and can therefore 
           % contain BUGS! Uses Matlabs functions and can therefore be
           % slow.
           %
           % Input:
           % filePath       - Path to file or a folder containing files.
           % settings       - Settings used for the loading of the images.
           %    .recursive  - True if subfolders should be searched for
           %                  files.
           %
           % Output:
           % m4Array        - The imported images organized as m4s
           % importInfo     - Info about the import.
           
           
           % Get all files
           if (iscell(filePath))
               files = filePath;
           elseif (~isdir(filePath))
               % Single file
               files = {filePath};
           else
               if (settings.recursive)
                   filePath = regexp(genpath(filePath),';','split');
               else
                   filePath = {filePath};
               end
               
               files = {};
               for ii = 1:numel(filePath)
                   fileStruct = dir(fullfile(filePath{ii}));
                   
                   fileRange = numel(files)+ 1:numel(fileStruct);
                   files = [files,cell(1,numel(fileStruct))]; %#ok<AGROW>
                   for jj = fileRange
                      if (~fileStruct(jj).isdir)
                          files{jj} = fullfile(filePath{ii},fileStruct(jj).name); 
                      else
                          files{jj} = [];
                      end
                   end 
                end
           end
           
           % To be done!
           
%            % Read file data and check if dicom v3
%            isDICOMv3 = false(1,numel(files));
%            info = cell(1,numel(files));
%            data = cell(1,numel(files));
%            
%            p = Progressor('Loading DICOM');
%           
%            
%            % Loop over files (and folders)
%            for ii = 1:numel(files)
%               p.setProgress(ii/(numel(files)));
%                % Ensure that it was a file
%                if (~isempty(files{ii}))
%                   % Try to load the file
%                   try 
%                       [data{ii},info{ii}] = loadDICOM(files{ii});
%                       
%                   catch e % Not dicom
%                       disp(e.Message)
%                       isDICOMv3(ii) = false;
%                   end
%                   
%                else
%                    isDICOMv3(ii) = false;
%                end
%            end
%            
%            % Load data and create Matrix4D objects
%            info = info(isDICOMv3);
%            data = info(isDICOMv3);
%            
%            if (isempty(info))
%                m4Array = [];
%                importInfo = [];
%                return; % No more to do
%            end
%            
%            
%            % Create cell array to hold the output
%            m4Array = cell(1,numel(info));
%            importInfo = cell(1,numel(info));
%            % Loop over files
%            for ii = 1:numel(m4Array)
%                siz = cell(1,11);
%                [siz{:}] = size(data{ii});
%                siz([1,2,3,5])={':',':',':',':'};
%                lc = LoopCounter(siz);
%                
%                
%            end
%            
%            
% %            m4Array = Matrix4D.array(1,numel(info));
% %            for ii = 1:numel(info)
% %                % Load data
% %                X = dicomread(info{ii});
% %                
% %                % Extract metainfo for the M4 object
% %               % info{ii}.
% %                
% %                % Create Matrix4D objects
% %                m4Array(ii) = Matrix4D(X);
% %                m4Array(ii).imagingInfo = info{ii};
% %                p.setProgress(1/2+ii/(2*numel(info)));
% %                
% %            end
% %            importInfo = []; 
        end
        
        function [m4Array,importInfo] = importNIFTI(filePath,settings)
            % Main function for loading NIFTI into m4
            disp('WARNING: The Nifti standard is poorly defined. This function is made to ensure that nii-files from "dcm2nii" give the same coordinates as the original dicom files.')
            
            % Get filenames
            if (iscell(filePath))
                files = filePath;
            elseif (~isdir(filePath))
                % Single file
                files = {filePath};
            else
                if (settings.recursive)
                    filePath = regexp(genpath(filePath),';','split');
                else
                    filePath = {filePath};
                end
                
                files = {};
                for ii = 1:numel(filePath)
                   fileStruct = dir(fullfile(filePath{ii},'*.nii')); 
                   
                   fileRange = numel(files)+ 1:numel(fileStruct);
                   files = [files,cell(1,numel(fileStruct))]; %#ok<AGROW>
                   for jj = fileRange
                      files{jj} = fullfile(filePath{ii},fileStruct(jj).name); 
                   end  
                end
            end
            
            % Allocate dummy m4s in an array
            m4Array = Matrix4D.array(1,numel(files),1);
            importInfo = cell(1,numel(files));
            
            % Load the nii file and store data in m4
            for ii = 1:numel(files)
               [~, fname, ext] = fileparts(files{ii});
               importInfo{ii} = [fname,ext]; 
               
               niiFile = load_untouch_nii(files{ii});
               
               % Get the units of space and time
               u = niiFile.hdr.dime.xyzt_units;
               spaceFactor = (bitand(u,3)==1)*1000 + (bitand(u,3)==2) + (bitand(u,3)==3)*1e-3; % 1 = m, 2 = mm, 3 = um
               timeFactor = (bitand(u,24)==8)+(bitand(u,24)==16)*1e-3 + (bitand(u,24)==24)*1e-6; % 8 = s, 16 = ms, 24 = us
               
               lvoxelSize = niiFile.hdr.dime.pixdim(2:4)*spaceFactor;
               
               nt = niiFile.hdr.dime.dim(5);
               nz = niiFile.hdr.dime.dim(4);
               
               if (any(niiFile.hdr.dime.dim(6:end) > 1))
                  error('Matrix4D:importNIFTI','nifti files with more than 4 dimensions cannot be imported to Matrix4D'); 
               end
               ltimeStamp = ones(nz,1)*(0:(nt-1))*timeFactor*niiFile.hdr.dime.pixdim(5);
               %  OBS: DICOM's coordinate system is 180 degrees rotated about the z-axis
               %  from the neuroscience/NIFTI coordinate system.  To transform between DICOM
               %  and NIFTI, you just have to negate the x- and y-coordinates.
               lposition(1) = -niiFile.hdr.hist.qoffset_x;
               lposition(2) = -niiFile.hdr.hist.qoffset_y;
               lposition(3) = niiFile.hdr.hist.qoffset_z;
               quaternion = [0,niiFile.hdr.hist.quatern_b,niiFile.hdr.hist.quatern_c,niiFile.hdr.hist.quatern_d];
               
               % Quaternion needs normalization
               if (norm(quaternion(2:end),2) > 1)
                  quaternion(2:end) = quaternion(2:end)/norm(quaternion(2:end),2); 
               end
               quaternion(1) = sqrt(1-sum(quaternion(2:end).^2));
               
               % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               % Nifti is a very!! poorly defined "standard" and the format is virtually
               % useless because of that. Ad-hoc changes are neccecary
               % for the nifti coordinates to fit dicom!!
               % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               fixIt = [-1 1 1;-1 1 1;1 -1 -1];
               lorientation = Rotation(Rotation.quaternion2Matrix(quaternion).*fixIt); 
               
               % Need to flip the second dimension in the matrix. (See
               % below.) Because of this, the position of the volume must
               % also change. Why, who nows??!
               
               lposition = lposition(:) - lorientation.matrix(:,2)*lvoxelSize(2)*(niiFile.hdr.dime.dim(3)-1);

               limageUnit = '';
               limagingInfo.origin = 'Nifti file';
               lname = niiFile.hdr.hist.descrip;
               lisoCenter = [NaN NaN NaN]'; % Unknown!
               lpatientOrientation = Rotation([0 0 0]); % Don't know how to get this info from the nifti file. Set it to no rotation. I.e. HFS.
               lsampledTimeStamp = ltimeStamp;
               lsampledVoxelSize = lvoxelSize;
               lsampledVoxelDistance = lvoxelSize;
               lsampledMatrixSize = niiFile.hdr.dime.dim(2:5);
               lsampledPosition = lposition;
               lsampledOrientation = lorientation;
               
               % Likely to contain bugs. Especially regarding orientation.
               % Create a M4 object. Need to reshape and flip second
               % dimension. Whe the flip is needed I don't know. Some odd
               % stupid convention...
               m4Array(ii) = Matrix4D(flipdim(niiFile.img,2),ltimeStamp,lsampledTimeStamp,lposition,lorientation,lpatientOrientation,lvoxelSize,lsampledVoxelSize,lsampledVoxelDistance,...
                                      lsampledMatrixSize,lsampledPosition,lsampledOrientation,limageUnit,limagingInfo,lname,lisoCenter); 
            end
            
            
        end
        
        function [m4Array,importInfo] = importMHD(filePath,settings)
            % Get filenames
            if (iscell(filePath))
                files = filePath;
            elseif (~isdir(filePath))
                % Single file
                files = {filePath};
            else
                if (settings.recursive)
                    filePath = regexp(genpath(filePath),';','split');
                else
                    filePath = {filePath};
                end
                
                files = {};
                for ii = 1:numel(filePath)
                   fileStruct = dir(fullfile(filePath{ii},'*.mhd')); 
                   
                   fileRange = numel(files)+ 1:numel(fileStruct);
                   files = [files,cell(1,numel(fileStruct))]; %#ok<AGROW>
                   for jj = fileRange
                      files{jj} = fullfile(filePath{ii},fileStruct(jj).name); 
                   end  
                end
            end
            
            % Allocate output
                        % Allocate dummy m4s in an array
            m4Array = Matrix4D.array(1,numel(files),1);
            importInfo = cell(1,numel(files));
            
            % Load the rawdata files and store data in m4
            for ii = 1:numel(files)
               [~, fname, ext] = fileparts(files{ii});
               importInfo{ii} = [fname,ext]; 
               header = getHeaderInfo(files{ii});

               fid = fopen([header.rawFile]);
               mat = fread(fid,prod(header.siz),header.ElementType);
               fclose(fid);
               
               
               
               imgInfo.import = 'Imported from mhd.';
               m4Array(ii) = Matrix4D(reshape(mat,header.siz),'name',files{ii},'timeStamp',header.time,'position',header.pos,...
                                      'orientation',Rotation(header.os),'voxelSize',header.vox,'imagingInfo',imgInfo);
            end
            
            
            function header = getHeaderInfo(file)
                % Get vital information
                fid1 = fopen(file,'r');
                    mhd = textscan(fid1, '%s %s', 'delimiter', '=','whitespace', '');
                fclose(fid1);
                
                fpath = fileparts(file);
                
                % Dim size
                header.siz = str2num(mhd{2}{find(cellfun(@sum,strfind(mhd{1},'DimSize'))')});%#ok<*ST2NM,*FNDSB>
                
                % Data file
                header.rawFile = mhd{2}{find(cellfun(@sum,strfind(mhd{1},'ElementDataFile'))')};              
                header.rawFile = fullfile(fpath,strtrim(header.rawFile));
                
                % Orientation matrix
                header.os = zeros(3,3);
                header.os(:) = str2num(mhd{2}{find(cellfun(@sum,strfind(mhd{1},'TransformMatrix'))')})';
                
                
                % Voxel size
                header.vox = zeros(3,1);
                header.vox(:) = str2num(mhd{2}{find(cellfun(@sum,strfind(mhd{1},'ElementSpacing'))')})';
                
                % Position
                header.pos = zeros(3,1);
                header.pos(:) = str2num(mhd{2}{find(cellfun(@sum,strfind(mhd{1},'Offset'))')})';
                
                % N.o. values per voxel
                try
                    el = str2num(mhd{2}{find(cellfun(@sum,strfind(mhd{1},'ElementNumberOfChannels'))')})';
                    header.siz(4) = el;
                    header.time = ones(header.siz(3),1)*(0:header.siz(4)-1);
                catch
                    header.siz(4) = 1;
                    header.time = zeros(header.siz(3),header.siz(4));
                end
                
                % Format
                frmt = mhd{2}{find(cellfun(@sum,strfind(mhd{1},'ElementType'))')};
                frmt(frmt==' ') = [];
                switch frmt
                    case 'MET_CHAR'
                        ElementType = 'int8';
                    case 'MET_UCHAR'
                        ElementType = 'uint8';
                    case 'MET_SHORT'
                        ElementType = 'int16';
                    case 'MET_USHORT'
                        ElementType = 'uint16';
                    case 'MET_UINT'
                        ElementType = 'uint32';
                    case 'MET_INT'
                        ElementType = 'int32';
                    case 'MET_FLOAT'
                        ElementType = 'single';
                    case 'MET_DOUBLE'
                        ElementType = 'double';
                    otherwise
                end
                header.ElementType = ElementType;
            end
            
        end
        
        function [m4Array,importInfo] = importDICOM(filePath,settings)
            % Main function for loading dicom images info m4.
            
            % What attributes do we need?
            selattrs = regexp(settings.selectionString,'\$(\w+)','tokens');
            selectionAttributeNames = unique([selattrs{:}]);
            attributeArrayNames = [selectionAttributeNames, settings.splitTags];
            
            % A progressbar
            progressbar2(1,1,1);
            progressbar2('Import DICOM: Total progress','File scan','Load images');
            
            
            % Get the attributes
            [attributeArray,files] = DicomAttribute.read(filePath,attributeArrayNames,settings.recursive,@Matrix4D.updateProgressbarScanFiles);
            progressbar2(0.3,1,0);
            
            % Evaluate the selection string
            N = numel(selectionAttributeNames);
            if (~isempty(settings.selectionString))
                [files,attributeArray] = Matrix4D.selectionStringRefinement(files,attributeArray,settings.selectionString,selectionAttributeNames,attributeArray(1:numel(selectionAttributeNames)));
            end
            nToLoad = numel(files.value);
            % If no files fullfill the selection
            if (numel(files.value) == 0)
                m4Array = [];
                importInfo = [];
                progressbar2(1,1,0);
                return;
            end
            
            % Split the files into groups based on spitTags
            files4D = files.partition(attributeArray((N+1):end));
            
            % Each files4D will become a Matrix4D
            m4Arr = Matrix4D.array(size(files4D));
            
            % Each files4D will have additional information that can be
            % extracted from a single DICOM image.
            representativeFiles = cell(size(files4D));
            
            % Loop over the groups (future m4s)
            nLoaded = 0;
            for ii = 1:numel(files4D)
                % Get some attributes
                if (isempty(settings.dateTimeTag))
                    attr4D = DicomAttribute.read(files4D(ii).value,{'ImagePositionPatient','ImageOrientationPatient',settings.dateTag,...
                        settings.timeTag,settings.timeOffsetTag,'Modality','PixelSpacing'},false);
                else
                     attr4D = DicomAttribute.read(files4D(ii).value,{'ImagePositionPatient','ImageOrientationPatient',settings.dateTimeTag,...
                        settings.dateTimeTag,settings.timeOffsetTag,'Modality','PixelSpacing'},false);
                end
                
                % Assemble a Matrix4D
                [m4Arr(ii),representativeFiles{ii},nLoaded] = Matrix4D.assebleMatrix4DFromDicomData(files4D(ii),attr4D,settings,nLoaded,nToLoad);
            end
            
            
            % ---- Sort the data into an ND-array ---- %
            
            % Get info about ordering
            orderTags = DicomAttribute.read(representativeFiles,settings.orderTags);
            counterDims = cell(1,numel(orderTags));
            for ii = 1:numel(counterDims)
                val = orderTags(ii).value;
                if (isnumeric(val{1}))
                  val = cell2mat(val); 
                end
                counterDims{ii} = unique(val);
            end
            
            % Order the m4 matrixes 
            lc = LoopCounter(counterDims);
            switch (lower(settings.outputType))
                case 'm4array'
                    if (lc.nDims > 1)
                        m4Array = Matrix4D.array(lc.size);
                    else
                        m4Array = Matrix4D.array(1,lc.size);
                    end
                case 'cellarray'
                    if (lc.nDims > 1)
                        m4Array = cell(lc.size);
                    else
                        m4Array = cell(1,lc.size);
                    end
                otherwise
                    error('Matrix4D:importDICOM','Unknown output type');
            end
            
            while (lc.running)
                selection = true(size(orderTags(1).value));
                for ii = 1:numel(orderTags)
                    selection = selection & (orderTags(ii) == lc.value{ii});
                end
                m4Selection = m4Arr(selection);
                
                switch (lower(settings.outputType))
                    case 'm4array'
                        if (numel(m4Selection) == 1)
                            m4Array(lc.index{:}) = m4Selection;
                        else
                            error('Matrix4D:importDICOM',['Cannot put ', num2str(numel(m4Selection)),' elements in a single position. For this feature use outputType = ''cellArray''.']);
                        end
                    case 'cellarray'
                        m4Array{lc.index{:}} = m4Selection;
                    otherwise
                        error('Matrix4D:importDICOM','Unknown output type');
                end
                
                lc = lc.increment();
            end
            
            % --- Create outputs --- %
            importInfo.dimNames = settings.orderTags;
            importInfo.dimValues = counterDims;
            importInfo.dimSize = lc.size;
            progressbar2(1,[],[]);
        end
        
        function [m4,representativeFile,nLoaded] = assebleMatrix4DFromDicomData(files,attrs,settings,nLoaded,nToLoad)
            % attrs(1) - Image orientation patient
            % attrs(2) - Image position patient
            % attrs(3) - Acquisition date or datetime
            % attrs(4) - Acquisition time or datetime
            % attrs(5) - Time offset relative to acquisition time
            % attrs(6) - Modality
            % attrs(7) - Pixel spacing
            
            % Get the slice position for each image
            if (any(attrs(2).empty))
               error('Matrix4D:assebleMatrix4DFromDicomData','Image orientation (patient) is missing.'); 
            end
            zpos = cross(attrs(2).value{1}(1:3),attrs(2).value{1}(4:6))'*cell2mat(attrs(1).value');
            % The slice positions should agree within a tolerance that is
            % related to the pixelsize
            tolerance = norm(attrs(7).value{1})*1e-3;
            zposTol = round(zpos/tolerance)*tolerance;
            % Get distinct z positions (and order them).
            [~,uniqueIndex,distinctZPositionIndex] = unique(zposTol);
            distinctZPositions = zpos(uniqueIndex);
            % Check that the slice distance is uniform within some
            % tolerance
            if (numel(distinctZPositions) > 2)
                if (mean(abs(diff(diff(distinctZPositions)))) > ((mean(abs(diff(distinctZPositions))))*1e-3)) % 0.1% of slice thickness tolerance
                    error('Matrix4D:assebleMatrix4DFromDicomData','Nonuniform distance between slices.');
                end
            end
            
            iop0 = attrs(2).value{1};
            pixelSpacing0 = attrs(7).value{1};
            for ii = 1:numel(files.value)
                if (~isequal(iop0,attrs(2).value{ii}) || ~isequal(pixelSpacing0,attrs(7).value{ii}))
                    error('Matrix4D:assebleMatrix4DFromDicomData','Pixelspacing or orientation is not consistent within volume.');
                end
            end
            
            if (1~=numel(unique(attrs(6).value)))
                error('Matrix4D:assebleMatrix4DFromDicomData','Modality changes within the volume.')
            end
            
            % Sort the files and create a timestamp.
            nz = numel(distinctZPositions);
            nt = numel(zpos)/nz;
            if (round(nt) ~= nt)
                error('Matrix4D:assebleMatrix4DFromDicomData','Number of slices, timepoints and number of acquisitions do not match.')
            end
            localTimeStamp = zeros(nz,nt);
            sliceTimeStamp = cell(1,nt);
            sliceTimeOffset = zeros(1,nt);
            sortedFiles = cell(nz,nt);
            for z = 1:nz
                % Get the data for the slice position
                selectedData = distinctZPositionIndex==z;
                if (sum(selectedData) ~= nt)
                    error('Matrix4D:assebleMatrix4DFromDicomData','Inconsistency in data.')
                end
                selectedFiles = files.subset(selectedData);
                
                % Get the slice timestamp
                if (isempty(settings.dateTimeTag))
                    date    = attrs(3).subset(selectedData);
                    time    = attrs(4).subset(selectedData);
                    offset  = attrs(5).subset(selectedData);
                    % Make the format more uniform
                    for t = 1:nt
                        if (offset.empty(t))
                            sliceTimeOffset(t) = 0;
                        else
                            
                            sliceTimeOffset(t) = offset.value{t};
                        end
                        sliceTimeStamp{t} = [date.value{t}(date.value{t} ~= '.'),time.value{t}(time.value{t} ~= ':')];
                    end
                else
                    datetime = attrs(3).subset(selectedData);
                    for t = 1:nt
                        if (offset.empty(t))
                            sliceTimeOffset(t) = 0;
                        else
                            
                            sliceTimeOffset(t) = offset.value{t};
                        end
                        timeZoonOffset = (datetime.value{t} == '&');
                        if (any(timeZoonOffset))
                            sliceTimeStamp{t} = datetime.value{t}(1:(find(timeZoonOffset)-1));
                        else
                            sliceTimeStamp{t} = datetime.value{t};
                        end
                    end
                end
                % OBS offset is not used. It may for some PET images be an
                % alternative (better?) to the date and time stamps.
                if (numel(sliceTimeStamp{1}) > 14) % Different date formats are used. Some with and some without ms. Check the first and assume the same format in all.
                    localTimeStamp(z,:) = datenum(sliceTimeStamp,'yyyymmddHHMMSS.FFF')'*3600*24;
                else
                    localTimeStamp(z,:) = datenum(sliceTimeStamp,'yyyymmddHHMMSS')'*3600*24;
                end
                
                % Sort based on timestamp
                [localTimeStamp(z,:),timeIndex] = sort(localTimeStamp(z,:),2,'ascend');
                sortedFiles(z,:) = selectedFiles.value(timeIndex);
            end % End forloop
            
            % Get attributes
            [ztTagNames,ztInfoNames,tTagNames,tInfoNames,zTagNames,zInfoNames,simpleTagNames,simpleInfoNames] = Matrix4D.getImagingInfoTagNames(attrs(6).value{1});
            infoAttrs = DicomAttribute.read(reshape(sortedFiles,[1,nz*nt]),[ztTagNames,tTagNames,zTagNames,simpleTagNames],false);
            ztAttributes = infoAttrs(1:numel(ztTagNames));
            tAttributes = infoAttrs(numel(ztTagNames)+(1:numel(tTagNames)));
            zAttributes = infoAttrs((numel(ztTagNames)+numel(tTagNames)) + (1:numel(zTagNames)));
            simpleAttributes = infoAttrs((numel(ztTagNames)+numel(tTagNames) + numel(zTagNames)) + (1:numel(simpleTagNames)));
            
            % Read the simple attributes
            simpleAttributeValues = cell(1,numel(simpleTagNames));
            for ii = 1:numel(simpleTagNames)
                simpleAttributeValues{ii} = simpleAttributes(ii).value{1};
            end
            
            % ---- Read the attributes with z-dependence ---- %
            zAttributeValues = cell(1,numel(zTagNames));
            for ii = 1:numel(zTagNames)
                switch (zAttributes(ii).VR)
                    case ''
                        zAttributeValues{ii} = [];
                        continue;
                    case {'FL','FD','SL','SS','DS','IS','UL','AS'}
                        % Check if scalar
                        scalar = true;
                        for jj = 1:numel(zAttributes(ii).value)
                            if (~isscalar(zAttributes(ii).value{jj}))
                                scalar = false;
                                break;
                            end
                        end
                        if (scalar)
                            zAttributeValues{ii} = zeros(nz,1);
                        else
                            zAttributeValues{ii} = cell(nz,1);
                        end
                    otherwise
                        zAttributeValues{ii} = cell(nz,1);
                end
                values = reshape(zAttributes(ii).value,[nz,nt]);
                for z = 1:nz
                    if (iscell(zAttributeValues{ii}))
                        zAttributeValues{ii}{z,1} = values{z,1};
                    else
                        zAttributeValues{ii}(z,1) = values{z,1};
                    end
                end
            end
            
            
            % ---- Read the attributes with t-dependence ---- %
            tAttributeValues = cell(1,numel(tTagNames));
            for ii = 1:numel(tTagNames)
                switch (tAttributes(ii).VR)
                    case ''
                        tAttributeValues{ii} = [];
                        continue; % No need to do any more if no data is 
                        % available for the attribute...
                    case {'FL','FD','SL','SS','DS','IS','UL','AS'}
                        % Check if scalar
                        scalar = true;
                        for jj = 1:numel(tAttributes(ii).value)
                            if (~isscalar(tAttributes(ii).value{jj}))
                                scalar = false;
                                break;
                            end
                        end
                        if (scalar)
                            tAttributeValues{ii} = zeros(1,nt);
                        else
                            tAttributeValues{ii} = cell(1,nt);
                        end
                    otherwise
                        tAttributeValues{ii} = cell(1,nt);
                end
                values = reshape(tAttributes(ii).value,[nz,nt]);
                for t = 1:nt
                    if (iscell(tAttributeValues{ii}))
                        tAttributeValues{ii}{1,t} = values{1,t};
                    else
                        tAttributeValues{ii}(1,t) = values{1,t};
                    end
                end
            end
            
            % ---- Read the attributes with both t and z-dependence ---- %
            ztAttributeValues = cell(1,numel(ztTagNames));
            for ii = 1:numel(ztTagNames)
                switch (ztAttributes(ii).VR)
                    case ''
                        ztAttributeValues{ii} = [];
                        continue;
                    case {'FL','FD','SL','SS','DS','IS','UL','AS'}
                        % Check if scalar
                        scalar = true;
                        for jj = 1:numel(ztAttributes(ii).value)
                            if (~isscalar(ztAttributes(ii).value{jj}))
                                scalar = false;
                                break;
                            end
                        end
                        if (scalar)
                            ztAttributeValues{ii} = zeros(nz,nt);
                        else
                            ztAttributeValues{ii} = cell(nz,nt);
                        end
                    otherwise
                        ztAttributeValues{ii} = cell(nz,nt);
                end
                values = reshape(ztAttributes(ii).value,[nz,nt]);
                for z = 1:nz
                    for t = 1:nt
                        if (iscell(ztAttributeValues{ii}))
                            ztAttributeValues{ii}{z,t} = values{z,t};
                        else
                            ztAttributeValues{ii}(z,t) = values{z,t};
                        end
                    end
                end
            end
            
            
            % ---- Read the pixel data ---- %
            mat4d = [];
            for t = 1:nt
                % Read 3D volume with itk
                [mat3d,orientMat,origin,localVoxelSize] = itk3DVolumeReader(sortedFiles(:,t));
                nLoaded = nLoaded + nz;
                progressbar2(0.3+0.7*nLoaded/nToLoad,[],nLoaded/nToLoad);
                
                % Put information into matrix
                if (isempty(mat4d))
                    [nx,ny,nz] = size(mat3d);
                    mat4d = zeros([nx,ny,nz,nt],class(mat3d));
                    mat4d(:,:,:,t) = mat3d;
                else
                    mat4d(:,:,:,t) = mat3d; %#ok<AGROW>
                end
            end
            
            % ---- Create the output ---- %
            
            % Create the imaging info
            imagingInfoNames = [ztInfoNames,tInfoNames,zInfoNames,simpleInfoNames];
            imagingInfoValues = [ztAttributeValues,tAttributeValues,zAttributeValues,simpleAttributeValues];
            localImagingInfo = cell2struct(imagingInfoValues,imagingInfoNames,2);
            
            % Get some more info
            patOrientation = Matrix4D.getPatientOrientationInMachine(files.value{1});
            localName = Matrix4D.getDicomNamingName(files.value{1},settings.naming);
            representativeFile = files(1).value{1};
            
            % Create the Matrix4D object - Finally!
            [snx,sny,snz,snt] = size(mat4d);
            sampledMatrix = [snx,sny,snz,snt];
            m4 = Matrix4D(mat4d,localTimeStamp,localTimeStamp,origin,Rotation(orientMat),patOrientation,localVoxelSize,localVoxelSize,localVoxelSize,...
                          sampledMatrix,origin,Rotation(orientMat),'',localImagingInfo,localName,[NaN,NaN,NaN]');
            
        end
        
        function [ztTagNames,ztInfoNames,tTagNames,tInfoNames,zTagNames,zInfoNames,simpleTagNames,simpleInfoNames] = getImagingInfoTagNames(modality)
            % Get imaging info (specific for the modality).
            
            % Get attributes to load for imaging info
            fid = fopen([modality,'imaginginfo.txt']);
            infoAttrs = textscan(fid, '%s %s %d %d','WhiteSpace','\b\t');
            fclose(fid);
            z = infoAttrs{3} == 1;
            t = infoAttrs{4} == 1;
            zt = z & t;
            z = z & ~zt;
            t = t & ~zt;
            simple = ~z & ~t & ~zt; 
            
            ztTagNames = infoAttrs{1}(zt)';
            ztInfoNames = infoAttrs{2}(zt)';
            tTagNames = infoAttrs{1}(t)';
            tInfoNames = infoAttrs{2}(t)';            
            zTagNames = infoAttrs{1}(z)';
            zInfoNames = infoAttrs{2}(z)';
            simpleTagNames = infoAttrs{1}(simple)';
            simpleInfoNames = infoAttrs{2}(simple)';            
%
        end
        
        function R = getPatientOrientationInMachine(filename)
            % Get the patient orientation in the machine. Specific for
            % manufacturer. This is valid for siemens MR camera.
            ppCode = DicomAttribute.read({filename},{'PatientPosition'});
            str = ppCode.value{1};
            if (isequal(str(1:2),'HF')) % Head first
                v3 = [0 0 -1]';
            else % Feat first
                if (~isequal(str(1:2),'FF'))
                    error(['Unknown patient orientation: ',str])
                end
                v3 = [0 0 1]';
            end
            
            switch (str(3:end))
                case 'S' % Supine
                    v1 = [1 0 0]';
                    v2 = [0 -1 0]';
                case 'P' % Prone
                    v1 = [-1 0 0]';
                    v2 = [0 1 0]';
                case 'DL' % Decubitus Left - Left down
                    v1 = [0 -1 0]';
                    v2 = [-1 0 0]';
                case 'DR' % Decubitus Right - Rigth down
                    v1 = [0 1 0]';
                    v2 = [1 0 0]';
                otherwise
                    error(['Unknown patient orientation: ',str])
            end
            
            R = Rotation([v1,v2,v3]);
        end
        
        function name = getDicomNamingName(filename,naming)
            % Create a name for the m4 object based on dicom tags
            attrs = DicomAttribute.read({filename},naming);
            str = '';
            for ii = 1:numel(attrs)
                if (~ischar(attrs(ii).value{1}))
                    error('DicomAttribute:getDicomNamingName','The naming of the Matrix4D object must be based on string valued attibutes.');
                end
                str = [str,attrs(ii).value{1},' + ',]; %#ok<AGROW>
            end
            str = str(1:(end-3));
            name = regexprep(str, '[\\/:*?"<>|]*', '_');
        end
        
        % Refine a set of files based on a string.
        function [out_files,out_attributes] = selectionStringRefinement(in_files,in_attributes,selectionString,selectionAttributeNames,attributeArray) %#ok<INUSD>
            % Create variables with names that matches the attribute names
            for ii = 1:numel(selectionAttributeNames)
                eval([selectionAttributeNames{ii},' = attributeArray(ii);']);
            end
            
            % Remove $ from the string
            selectionString = selectionString(selectionString ~= '$');
            
            % Get selected files
            selection = eval(selectionString);
            out_files = in_files.subset(selection);
            for ii = 1:numel(in_attributes)
                out_attributes(ii) = in_attributes(ii).subset(selection); %#ok<AGROW>
            end
        end
        
        
    end
end

%%%#Public: "Matrix 4D"





















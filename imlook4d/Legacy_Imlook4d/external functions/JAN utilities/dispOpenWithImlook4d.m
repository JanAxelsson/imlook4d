function dispOpenWithImlook4d( varargin )

    text = '';
    message = '';
    if nargin==1
        filePath = varargin{1};
    end
    
    if nargin==2
        text = varargin{1};
        filePath = varargin{2};
    end
    
    % Check if file exists
    if ~ ( exist(filePath, 'file') == 2 )  % Check full name
        if ~ ( exist(filePath(1:end-2) , 'file') == 2 ) % TPM.nii,3 => TPM.nii
            message = ' (FILE MISSING)';
        end
    end
    
    % Display 
    disp( [ text '<a href="matlab:imlook4d(''' filePath ''')">' filePath '</a>' message]);
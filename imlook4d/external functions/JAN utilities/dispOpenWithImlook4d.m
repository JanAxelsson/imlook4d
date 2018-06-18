function dispOpenWithImlook4d( varargin )

    text = '';
    if nargin==1
        filePath = varargin{1}
    end
    
    if nargin==2
        text = varargin{1};
        filePath = varargin{2};
    end
    disp( [ text '<a href="matlab:imlook4d(''' filePath ''')">' filePath '</a>' ]);
function [ output ] = num2str_pad( varargin  )
% Pad with spaces
% Inputs:
%      Same arguments as num2str
%      Extra argument at end = total number of spaces

    a=num2str(varargin {1:end-1});
    length=varargin{end};
    output=string_pad(a,length);
end


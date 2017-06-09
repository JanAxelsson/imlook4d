function [ output ] = string_pad( string, length  )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

    output=['                             ' string ];
    output=output( end-length:end);
end


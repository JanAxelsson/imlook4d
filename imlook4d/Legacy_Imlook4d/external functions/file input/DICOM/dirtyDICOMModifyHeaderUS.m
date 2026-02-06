function newHeader=dirtyDICOMModifyHeaderUS(header, group, element,explicit, value)
%
% ASSUMPTION:  Little Endian file, Little Endian operating system
%
% This function writes an US (unsigned integer) to DICOM.
%
% NOTE: Assume little-endian operating system (all intel systems)
%
% It uses the string function dirtyDICOMModifyHeaderString
%


% Calculate low and high byte
    HighByte=floor( value/256 );
    LowByte=value-256*HighByte;

% Format to string 
    string=char( uint8([LowByte HighByte]) );

% Use function that manipulates strings
    newHeader=dirtyDICOMModifyHeaderString(header, group, element,explicit, string);
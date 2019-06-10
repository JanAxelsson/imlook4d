function d = DicomBytesToDouble( VR, bytes)
% Converts from bytes to value using VR
% Jan Axelsson

string = char(bytes)';

switch VR
    case 'DS'
        d = str2num( string);
    case 'FL'
        d = typecast( uint8(bytes) , 'double');
    case 'FD'
        d = typecast( uint8(bytes) , 'double');
    case 'IS'
        d = str2num( string);
    case 'SL'
        d = typecast( uint8(bytes),'int32');
    case 'SS'
        d = typecast( uint8(bytes),'int16');
    case 'UL'
        d = typecast( uint8(bytes),'uint32');
    case 'US'
        d = typecast( uint8(bytes),'uint16');
    otherwise
        d = str2num( string);
end




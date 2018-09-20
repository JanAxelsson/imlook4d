function data=dirtyDICOMHeaderData(headers, col, group, element,explicit,stopAt)
%
% ASSUMPTION:  Little Endian file, Little Endian operating system
%
% This function reads a specific tag from dicom binary header
% The assumption is that the bytes look as follow:
%
% Bytes
% ----------------------
% 0     groupL (low byte, least sigificant byte)
% 1     groupH (high byte, most significant byte)
% 2     elementL
% 3     elementH
% ----------------------
% 4     valueLength L
% 5     valueLength H
% ----------------------
% 6     data
%
%
% Inputs:
%     headers   cell of binary headers, one per file (as found from
%               imlook4d/workspace/export menu, giving workspace variable:
%               imlook4d_current_handles.image.dirtyDICOMHeader )
%     col       number of files (column in headers)
%     group     hexadecimal value, for instance '0028'
%     element   hexadecimal value, for instance '1053'
%     explicit  =2 means two extra bytes before valueLengthL, otherwise =0
%     stopAt    OPTIONAL, normally stops at first occurence, if stopAT=N then set stop at occurence N
%
% Output:
%     data.bytes       in byte format (uint8)
%     data.string      in string format
%     data.indexLow    index to first data byte in header
%     data.indexHigh   index to last data byte in header
%     data.valueLength length of data

%
% OVERRIDE THIS METHOD
%
%data=dirtyDICOMHeaderData_NEW(headers, col, group, element,explicit);
%return

%
% INITIALIZE
%
    rangeH=1:2;  rangeL=3:4;    % Byte order for hexadecimal value
    %rangeH=3:4;  rangeL=1:2;    % Byte order for hexadecimal value
    
    if strcmp(group,'0002') %(Group 0002 elements should always be EXPLICIT VR LITTLE ENDIAN)
       explicit=2;
    end
    
%
% FIND ELEMENT
%

    % Get low and high bytes for group and element
    groupH=hex_to_uint8(group(rangeH));groupL=hex_to_uint8(group(rangeL));
    elementH=hex_to_uint8(element(rangeH));elementL=hex_to_uint8(element(rangeL));

    
    header=headers{col};
 
    %indecesToFirstByte=find(header==groupL);  % Find positions where first byte in group matches search
    indecesToFirstByte = strfind(header', [groupL groupH elementL elementH]);

    % Loop all indices that matched first byte 
    countElement = 0; % counter to number of found elements
    if ~isempty(indecesToFirstByte)
    for j=1:length(indecesToFirstByte)
        i=indecesToFirstByte(j);  % Look only in positions where first byte was found

        try
        %
        % PARSE Tag
        %
            
            %
            % EXPLICIT - Little endian
            %
                if (explicit)
                    % Always same
                    VR.pos=i+4;
                    vr=char( header( VR.pos: VR.pos+1))';

                    % Select method depending on VR
                    if ( max(strcmp( vr,{'OB', 'OW', 'OF', 'SQ', 'UT', 'UN'})) )
                        % One of: OB, OW, OF, SQ, UT OR UN
                        % 00 01   02 03   04 05   06 07   08 09 10 11   12 13 ...  
                        % GR GR | EL EL | VR VR | xx xx | VL VL VL VL | Data bytes.....
                        % where: GR=group, EL=element, VR=value-representation, xx=not-used, VL=value-length
                        VL.pos=i+8;
                        Data.pos=i+12;
                        Data.length=header(VL.pos)+256*header(VL.pos+1)+256*256*( header(VL.pos+2)+256*header(VL.pos+3) );
                    else
                        % NOT one of: OB, OW, OF, SQ, UT OR UN
                        % 00 01   02 03   04 05   06 07   08 09 ...
                        % GR GR | EL EL | VR VR | VL VL | Data bytes.....
                        % where: GR=group, EL=element, VR=value-representation, xx=not-used, VL=value-length
                        VL.pos=i+6;
                        Data.pos=i+8;
                        Data.length=header(VL.pos)+256*header(VL.pos+1);
                    end


                    % Get data
                    data.valueRepresentation=vr;
                    %data.bytes=header(Data.pos:Data.pos+Data.length-1);  
                    data.valueLength=Data.length;
                    try
                        data.bytes=header(Data.pos:Data.pos+Data.length-1);   
                    catch
                      % disp(['Failed in dirtyDICOMHeaderData [' group ',' element ']' ]); 
                    end
                end              
                
 
            %
            % IMPLICIT - Little endian
            %
                % Here it has happened that I get random finds where for instance (0008,0022)
                % is found in (0008,0008)VL=34 (=x0022)
            
            
                if (~explicit)
                    % All tags the same:
                    % 00 01   02 03   04 05   06 07   08 09 ...
                    % GR GR | EL EL | VL VL | VL VL | Data bytes.....
                    % where: GR=group, EL=element, VR=value-representation, xx=not-used, VL=value-length
                    VL.pos=i+4;
                    Data.pos=i+8;
                    Data.length=header(VL.pos)+256*header(VL.pos+1)+256*256*( header(VL.pos+2)+256*header(VL.pos+3) );

                    % Get data
                    %data.bytes=header(Data.pos:Data.pos+Data.length-1);
                    data.valueLength=Data.length;
                    %if (Data.valueLength<header.length())
                        data.bytes=header(Data.pos:Data.pos+Data.length-1);
                    %else
                    %    throw(MException('Id:id','message'));
                    %end
                end

            data.indexLow=Data.pos;
            data.indexHigh=VL.pos + Data.length -1;
            data.indexHigh=Data.pos+data.valueLength-1;
            
            %data.bigEndianBytes=header(index+ValueLength_bytes-1:-1:index);
            data.string=char(data.bytes)';
        
            if exist( 'stopAt')
                countElement = countElement +1;
                if stopAt == countElement
                    return % Break so only first instance is reported back
                end
            else
                return % Break so only first instance is reported back
            end
        catch
            if ~strcmp( element, '0000') && ~strcmp( group, '7FE0')
                % The element '0000' is not mandatory
                % The group '7FE0' does not have any header data
                %
                % If error caught for other conditions, report them:
                disp([ '(' group ',' element ') index='  num2str(i) '  ERROR in dirtyDICOMHeaderData - keep looking in this header' ]);
            end
        end

    end  % LOOP
    end %IF

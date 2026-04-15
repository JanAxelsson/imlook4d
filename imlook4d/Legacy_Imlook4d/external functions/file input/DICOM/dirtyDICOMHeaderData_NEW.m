function data=dirtyDICOMHeaderData(headers, col, group, element,explicit)
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
%
% Output:
%     data.bytes       in byte format (uint8)
%     data.string      in string format
%     data.indexLow    index to first data byte in header
%     data.indexHigh   index to last data byte in header
%     data.valueLength length of data



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
% 
%     % Get low and high bytes for group and element
     groupH=hex_to_uint8(group(rangeH));groupL=hex_to_uint8(group(rangeL));
     elementH=hex_to_uint8(element(rangeH));elementL=hex_to_uint8(element(rangeL));
     
     groupInteger=hex_to_uint16(group);     
     elementInteger=hex_to_uint16(element);
     
     lastGroupInteger=hex_to_uint16('7FE0');   
     lastElementInteger=hex_to_uint16('0010');   
% 
%     
     header=headers{col};
%  
%     %indecesToFirstByte=find(header==groupL);  % Find positions where first byte in group matches search
%     indecesToFirstByte = strfind(header', [groupL groupH elementL elementH]);
    
     
    i=133;  % start index
    
    

    % Loop all indices that matched first byte 
%     for j=1:size(indecesToFirstByte,1)
%         i=indecesToFirstByte(j);  % Look only in positions where first byte was found

    keepLooping=true;
    
    while keepLooping
        try
        %
        % PARSE Tag
        %
            %
            % Determine if tag is explicit
            %

                tagIsExplicit=(explicit>0);  % 

                % If group 0002, then always explicit little-endian
                if ( header(i)+256*header(i+1)==2 )
                    tagIsExplicit=true;
                end
        
            %
            % EXPLICIT - Little endian
            %
                if tagIsExplicit
                    % Always same
                    VR.pos=i+4;
                    VR.chars=char( header( VR.pos: VR.pos+1))';

                    % Select method depending on VR
                    if ( max(strcmp( VR.chars,{'OB', 'OW', 'OF', 'SQ', 'UT', 'UN'})) )
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

                    %data.valueRepresentation=VR.chars;
                    %data.valueLength=Data.length;
                end              
                
 
            %
            % IMPLICIT - Little endian
            %
                % Here it has happened that I get random finds where for instance (0008,0022)
                % is found in (0008,0008)VL=34 (=x0022)
            
            
                if (~tagIsExplicit)
                    % All tags the same:
                    % 00 01   02 03   04 05   06 07   08 09 ...
                    % GR GR | EL EL | VL VL | VL VL | Data bytes.....
                    % where: GR=group, EL=element, VR=value-representation, xx=not-used, VL=value-length
                    VL.pos=i+4;
                    Data.pos=i+8;
                    Data.length=header(VL.pos)+256*header(VL.pos+1)+256*256*( header(VL.pos+2)+256*header(VL.pos+3) );

                    %data.valueLength=Data.length;
                end

        
        catch
            disp([ '(' group ',' element ') index='  num2str(i) '  ERROR in dirtyDICOMHeaderData - keep looking in this header' ]);
            % Keep looping if random hit 
            keepLooping=false;
        end

        
        %
        % End loop?
        %
        
        % A) Correct tag found
        if (sum( (header(i:i+3)== [groupL groupH elementL elementH]') )==4)
            keepLooping=false;
            data.bytes=header(Data.pos:Data.pos+Data.length-1);
            data.string=char(data.bytes)';
            
            data.indexLow=Data.pos;
            data.indexHigh=Data.pos+data.valueLength-1;
            data.valueLength=Data.length;
            if tagIsExplicit
                data.valueRepresentation=VR.chars;
            end
            
            %data.bigEndianBytes=header(index+ValueLength_bytes-1:-1:index);
            
            keepLooping=false;
        end
        
        % B) Tag passed
        if ( header(i)+256*header(i+1) > groupInteger) 
            if (header(i+2)+256*header(i+3) > elementInteger )
                keepLooping=false;
            end
            
             % Correct Tag passed if SQ-delimitation           
             if (  header(i)+256*header(i+1)  == 65534) 
                keepLooping=true;
             end
        end

        
        
        
        % C) Image tag (7FE0,0010)
        if (  header(i)+256*header(i+1) == lastGroupInteger) && ( header(i+2)+256*header(i+3)  == lastElementInteger) 
            keepLooping=false;
        end        
     
        
        %
        % Next i
        %
                old_i=i;
                
            % Typical
                i=Data.pos+data.valueLength;

            % Correct next i if SQ
            if (data.valueLength == 4294967295)
                % SQ tag  (CHECK IF RIGHT STEP - test Hoffman phantom)
                i=Data.pos; 
            end
            
             % Correct next i if SQ-delimitation           
            if (  header(old_i)+256*header(old_i+1)  == 65534) 
                %SQ delimitation tag (No VR)
                if (explicit)
                    % Guessed wrong because added two assuming normal explicit
                    % tag (but the SQ delimitation is implicit).  Subtract two
                    % positions!
                    i=Data.pos;
                else
                    i=Data.pos;
                end
            end
            
            
            
        end

   end

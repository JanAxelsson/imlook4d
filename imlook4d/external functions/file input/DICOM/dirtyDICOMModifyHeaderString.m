function newHeader=dirtyDICOMModifyHeaderString(header, group, element,explicit, newString)
%
% ASSUMPTION:  Little Endian file, Little Endian operating system
%
% Two functions:
% 1) This function writes a new string into the DICOM tag defined by group and  element.
% 2) Update the valueLength of the image tag according to number of pixels
% in image (a value represented as a string, in input variable newString)
% 
% Alternative 1)
% is done by 
% - keeping the header up to valueLength L
% - Inserting the number of characters in newString into valueLength L and valueLength H
% - keeping the header following original data
% - updating the sequence length tag (xxxx,0000), if exists
%
% Alternative 2)
% is done by
% - keeping the header but calculating a new value for the valueString (which for the image happens to be the last 4 bytes, stored in endHeader)
%
% The bytes follow one of the two following orders:
%
% IMPLICIT:
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
% 7     valueLength 3d byte
% 7     valueLength 4th byte
% ----------------------
% 8     data
%
% or EXPLICIT:
%
% Bytes
% ----------------------
% 0     groupL (low byte, least sigificant byte)
% 1     groupH (high byte, most significant byte)
% 2     elementL
% 3     elementH
% ----------------------
% 4     VR char 1  (value representation)
% 5     VR char 2
% ----------------------
% 6     valueLength L
% 7     valueLength H
% ----------------------
% 8     data%
%
% First, the header is subdivided into the following segments:
%     startHeader
%    ---------  here follows group length tag (xxxx,0000)
%     tag1
%     vr1
%     valueLength1
%     value1
%    ---------  here follows header up to tag we want to modify
%     midHeader
%    ---------- here follows the tag we want to modify (group,element)
%     tag2
%     vr2
%     valueLength2
%     value2
%    ---------
%     endHeader
%
% Next, value2, valueLength2 are modified.
%
% Then, valueLength1 is updated to reflect the length difference between
%       new and old value2
%
% Inputs:
%     header    a single binary header
%     group     hexadecimal value, for instance '0028'
%     element   hexadecimal value, for instance '1053'
%     explicit  =2 means two extra bytes before valueLengthL, otherwise =0
%
%     newString string we want to put into this tag
%
% Output:
%     newHeader   a modified header.

try
%
% INITIALIZE
%
    rangeH=1:2;  rangeL=3:4;    % Byte order for hexadecimal value

    if strcmp(group,'0002') %(Group 0002 elements should always be EXPLICIT VR LITTLE ENDIAN)
        explicit=2;
    end    
    
%
% SPLIT HEADER INTO SEGMENTS
%
    % Read group length tag, and 
    try
        data1=dirtyDICOMHeaderData({header}, 1, group, '0000',explicit);  % group length (if exist)
        
        % Verify that valuelength=4 or 2 (otherwise not a proper group length, but a random hit)
        if ( data1.valueLength==4 || data1.valueLength==2  )
            groupLengthExists=1;
        else
            groupLengthExists=0;
            %disp(['(' group ',' '0000' ') ' 'Group length not found']);
        end
    catch
        %disp(['(' group ',' '0000' ') ' 'Group length not found']);
        groupLengthExists=0;
    end
    
    if not(groupLengthExists)
        % Group length tag does not exist
        data1.indexLow=50;  % Dummy value reasonable low
        data1.indexHigh=60; % Dummy value reasonable low
        %tag1=[];
        %vr1=[];
        % valueLength1 will be getting some value later on, based on its
        % byte position.
    end
    
    data2=dirtyDICOMHeaderData({header}, 1, group, element,explicit); % the tag we want to modify

    % Start header
    startHeader=header(1 : data1.indexLow-8-1);
    
    % Section 1
    tag1=header(data1.indexLow-8 : data1.indexLow-4-1);
    if (explicit==2)
        vr1 = header(data1.indexLow-4: data1.indexLow-2-1);
        valueLength1= header(data1.indexLow-2: data1.indexLow-0-1);
    else
        vr1 = [];
        valueLength1= header(data1.indexLow-4: data1.indexLow-0-1);
    end
    value1=header(data1.indexLow : data1.indexHigh);
    
    % Mid header
    midHeader=header(data1.indexHigh+1 : data2.indexLow-8-1);
    
    % Section 2
    tag2=header(data2.indexLow-8 : data2.indexLow-4-1);
    if (explicit==2)
        vr2 = header(data2.indexLow-4: data2.indexLow-2-1);
        valueLength2= header(data2.indexLow-2: data2.indexLow-0-1);
    else
        vr2 = [];
        valueLength2= header(data2.indexLow-4: data2.indexLow-0-1);
    end
    
    try
        value2=header(data2.indexLow : data2.indexHigh);
    catch
       value2=[];  % 7FE0 has no data.  It is in matrix instead 
    end
    
    % For error tracing - unmodified values
    value2org=value2;
    valueLength2org=valueLength2;

    % End header
    endHeader=header(data2.indexHigh+1 : end);
    
    
%      disp('*tag');disp(dec2hex(tag2));
%      disp('*VR');disp(char(vr2));
%      disp('*ValueLength');disp(num2str(valueLength2(1)+256*valueLength2(2)));
%      disp('*String value');disp(char(value2)');
 
    
%
% MODIFY 
%

    % value2
    
        % Make even number of chars
        if mod( length(newString),2 )
            if char(vr2') == 'UI'
                newString=[newString char(0)]; % NULL
            else
                newString=[newString ' ']; % Space
            end
        end

        diffLength=length(newString)-length(value2);    % Difference in length for group  
        value2=double(newString');            % Replace with new value

    % valueLength2

        % New value length
        value=length(value2); 
        valueLengthH=floor( value/256 );
        valueLengthL=value-256*valueLengthH;

        if (explicit==2)
            valueLength2=[valueLengthL; valueLengthH];          % 2 byte value length
        else
            valueLength2=[valueLengthL; valueLengthH; 0; 0];    % 4 byte value length (assume less than 256 bytes)
        end
    
    % value1 (modify only if group length tag (xxxx,0000) exists )
        if groupLengthExists
            value=value1(1)+value1(2)*256+value1(3)*65536+value1(4)*16777216+diffLength;  % GroupLength
            valueH=floor( value/256 );
            valueL=value-256*valueH;  
            if valueLength1(1)==4
                value1=[valueL; valueH;0;0];
            end
            if valueLength1(1)==2
                value1=[valueL; valueH];
            end
        end
        
        
%     disp('*tag');disp(dec2hex(tag2));
%     disp('*VR');disp(char(vr2));
%     disp('*ValueLength');disp(num2str(valueLength2(1)+256*valueLength2(2)));
%     disp('*String value');disp(char(value2'));
    
%
% BUILD HEADER 
%   

        
    % Build header
    try
        if strcmp(group,'7FE0')&&strcmp(element,'0010')  % Special case: Image tag (7FE0,0010)
            % Only need to modify valueLength
            newValueLength=double( typecast( uint32(str2num(newString)),'uint8')' );
            newHeader=[ header(1:end-4); newValueLength];
            
            if (length(header)~= length(newHeader) )
                disp('ERROR - header length changed for image tag (7FE0,0010).  This should not happen!'); 
            end
            
        else  % All other tags:
            newHeader=[startHeader; ...
                tag1; vr1; valueLength1; value1; ...
                midHeader; ...
                tag2; vr2; valueLength2; value2; ...
                endHeader];
        end
    catch
        disp(['(' group ',' element ') ERROR making newHeader']);
        if strcmp(group,'7FE0')&&strcmp(element,'0010')
            disp( ['Valuelength:  was=' num2str(valueLength) ' became=' num2str(newValueLength) ]);
        else
            disp( ['Valuelength:  was=' num2str(valueLength) ' became=' num2str(newValueLength) ]);
            test=dirtyDICOMHeaderData({newHeader}, 1, group, element,explicit);
            disp([ 'Data:         was = ' data2.string '-END    became= ' newString '-END']);
        end
    end   
    
    
    
    
    
    % TEST
    if (length(header)~= length(newHeader) )
        test=dirtyDICOMHeaderData({newHeader}, 1, group, element,explicit);
%         disp(['(' group ',' element ') ' 'Was =' data2.string '-END']);
%         disp(['(' group ',' element ') ' 'Goal=' newString '-END']);
%         disp(['(' group ',' element ') ' 'Is  =' test.string '-END']);
     end   
%
% FINALIZE
%
        
catch
    % If errors, leave header intact
    % Typically - if tag does not exist.
    %disp(['(' group ',' element ') ERROR']);
    %disp(lasterror);
    newHeader=header;

    %disp(['ERROR - could not modify Dicom Header  tag=(' group ',' element ')']);

end
%disp([ num2str( header(end-3:end)') '   ' num2str( newHeader(end-3:end)') ]);

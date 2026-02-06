function [ answer ] = makeAbsoluteSliceNumber( answer, imlook4d_slice, numberOfSlices )   
% Makes absolute slice numbers from relative slice numbers
% Used int SCRIPTS Copy_ROI, Threshold_ROI

%
% Handle range to end or rel range to zero
%
        if strcmp(answer{2},'end')
            answer{2}=num2str(numberOfSlices);
        end
        if strcmp(answer{1}(1),'0') 
            answer{1}=num2str(imlook4d_slice);
        end
        if strcmp(answer{2}(1),'0') 
            answer{2}=num2str(imlook4d_slice);
        end

%
% Handle Relative or Absolute slice positions:
%
        if strcmp(answer{1}(1),'-') || strcmp(answer{1}(1),'+') 
            if strcmp(answer{1}(1),'-') 
                firstSlice=imlook4d_slice-str2num( answer{1}(2:end) );
            end
            if strcmp(answer{1}(1),'+') 
                firstSlice=imlook4d_slice+str2num( answer{1}(2:end) );
            end
        else
            firstSlice=str2num(answer{1});
        end
        if strcmp(answer{2}(1),'-') || strcmp(answer{2}(1),'+')                     
            if strcmp(answer{2}(1),'-') 
                lastSlice=imlook4d_slice-str2num( answer{2}(2:end) );
            end
            if strcmp(answer{2}(1),'+') 
                lastSlice=imlook4d_slice+str2num( answer{2}(2:end) );
            end
        else
            lastSlice=str2num(answer{2});
        end
        
%
% Fix if outside matrix
%
        if lastSlice> numberOfSlices
           lastSlice=numberOfSlices; 
        end
        
        answer{1}=num2str(firstSlice);
        answer{2}=num2str(lastSlice);



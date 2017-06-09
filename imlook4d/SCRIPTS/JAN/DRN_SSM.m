Export

% File headers, and dicom mode
sortedHeaders=imlook4d_current_handles.image.dirtyDICOMHeader;
mode=imlook4d_current_handles.image.dirtyDICOMMode;

% Get info
i=1;

% Weight
weight=dirtyDICOMHeaderData(sortedHeaders, i, '0010' , '1030' ,mode);
disp(['Weight=' num2str(weight.string)  '[ kg]' ]);


% Sex
sex=dirtyDICOMHeaderData(sortedHeaders, i, '0010' , '0040' ,mode);
disp(['Sex=' sex.string   ]);

% Birth date
birthDate=dirtyDICOMHeaderData(sortedHeaders, i, '0010' , '0030' ,mode);
birthDate=birthDate.string;
birthDate=birthDate(1:4);
disp(['Birth year=' num2str(birthDate) ]);

% Time per bed-position
bedTime=imlook4d_duration(1);
disp(['Bed time=' num2str(bedTime/60) ' [min]' ]);


% Injected time 
injTime=dirtyDICOMHeaderData(sortedHeaders, i, '0018' , '1072' ,mode);
disp(['Injection time=' injTime.string   ]);

% Injected activity 
injAct=dirtyDICOMHeaderData(sortedHeaders, i, '0018' , '1074' ,mode);
disp(['Injected activity=' num2str( str2num(injAct.string) /1e6 ) ' [MBq]' ]);

% Counts

% Sum each bed

previousCounts.float=0;
sumCounts=0;
numberOfBeds=0;
for i=1:size(imlook4d_Cdata,3)
    counts=dirtyDICOMHeaderData(sortedHeaders, i, '0009' , '1071' ,mode);
    if (previousCounts.float ~= counts.float )
        sumCounts=sumCounts+counts.float;
        numberOfBeds=numberOfBeds+1;
        previousCounts=counts;
    end
end

disp(['Counts=' num2str(sumCounts/1000) ' [kilo-counts]' ]);


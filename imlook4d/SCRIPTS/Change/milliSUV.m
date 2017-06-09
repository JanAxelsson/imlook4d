% milliSUV.m
%
% Copy of SUV.m, with 
%
% Jan Axelsson


% INITIALIZE

    if ~strcmp(imlook4d_current_handles.image.fileType, 'DICOM')
       warndlg('Only DICOM is supported');
       return
    end


    % Export to workspace
    imlook4d('exportToWorkspace_Callback', imlook4d_current_handle,{},imlook4d_current_handles);  % Export to workspace
    
    % Read from imlook4d_current_handles
        mode=imlook4d_current_handles.image.dirtyDICOMMode;
        halflife=imlook4d_current_handles.image.halflife;  
        headers=imlook4d_current_handles.image.dirtyDICOMHeader;
    
    
    % Read from DICOM header
       % Weight
       try
       out3=dirtyDICOMHeaderData(headers, 1, '0010', '1030',mode);
       disp(['Weight [kg]=' out3.string]);
       weigth_kg=out3.string;
       catch
           weigth_kg='0';
       end
       
       defaultanswer{1}=weigth_kg;
       
       % Injection time
       try
           try
               out3=dirtyDICOMHeaderData(headers, 1, '0018', '1078',mode);
               InjectionTime=out3.string(9:end);  % DateTime
           catch
                out3=dirtyDICOMHeaderData(headers, 1, '0018', '1072',mode);
                InjectionTime=out3.string;  % Time
           end
       catch
           InjectionTime='HHMMSS'
       end
       
       disp(['Radionuclide Start Time=' InjectionTime]);
       defaultanswer{2}=InjectionTime;
       
       % Injected dose
       try
            out3=dirtyDICOMHeaderData(headers, 1, '0018', '1074',mode);
            DoseMBq=num2str(  str2num(out3.string)/1e6  );  % Convert to MBq
       catch
            DoseMBq='enter injected MBqs';
       end
       disp(['Radionuclide Total Dose [MBq]=' DoseMBq ]);  
       defaultanswer{3}=DoseMBq; 
       
       % Series start time (time for all decay corrections)
       out3=dirtyDICOMHeaderData(headers, 1, '0008', '0031',mode);
       SeriesTime=out3.string;
       disp(['SeriesTime=' SeriesTime]);
       
       % Unit
       try
           out3=dirtyDICOMHeaderData(headers, 1, '0054', '1001',mode);
           
       catch
          warndlg('Image unit not defined');
          
       end
       if strcmp(out3.string,'BQML') 
           conversionFactorTokBq=1e-3;
       end
       
       

    % User input: Verify input parameters
        prompt={'Patient Weight [kg] ',...
                'Injection time [hhmmss]',...
                'Injected activity [MBq]'};
        title='SUV parameters';
        numlines=1;
        answer=inputdlg(prompt,title,numlines,defaultanswer);
        
        weight_kg=str2num(answer{1});
        InjectionTime=answer{2};
        DoseMBq=str2num(answer{3});


%
%  PROCESS (Calculate  SUV)
%
       InjectionTimeInSeconds=str2num(InjectionTime(1:2))*3600 + str2num(InjectionTime(3:4))*60 + str2num(InjectionTime(5:6));
       SeriesTimeInSeconds=str2num(SeriesTime(1:2))*3600 + str2num(SeriesTime(3:4))*60 + str2num(SeriesTime(5:6));
       
       % [series time]-[inj time]
       deltaT=SeriesTimeInSeconds-InjectionTimeInSeconds;
       disp(['Time from injection to scan start=' deltaT ' s' ]);
       decayFactor=2^-(deltaT/halflife);
       disp(['Decay from injection to scan start=' decayFactor  ]);

              
    % Loop frames and slices
        for i=1:size(imlook4d_Cdata,3)
            for j=1:size(imlook4d_Cdata,4)
                SUV_factor=1/( DoseMBq / weight_kg  );
                SUV_factor=SUV_factor;  % Convert from Bq/ml to kBq/ml
                imlook4d_Cdata(:,:,i,j)=conversionFactorTokBq*imlook4d_Cdata(:,:,i,j)*SUV_factor /decayFactor;
            end
        end

        
%
% SECTION SPECIAL TO milli-SUV
%

    Duplicate;  % Make a copy of imlook4d instance, to put data into
            
    % New unit
    newHandles.image.unit='mSUV';  % SUV unit (same for SUV_BW and other SUV's)
    
    % Make milli-SUV
    imlook4d_Cdata=1000*imlook4d_Cdata;
    
    % Record history (what this image has been through)
    historyDescriptor='mSUV';
    newHandles.image.history=[historyDescriptor '-' newHandles.image.history  ];
        
        
%
% FINALIZE
% 
    guidata(newHandle, newHandles);
    
    % Import data
    imlook4d('importFromWorkspace_Callback', newHandle,{},newHandles);  % Import from workspace
    
    % Set title
    oldName=get(imlook4d_current_handle,'Name');
    set(newHandle,'Name', [historyDescriptor ' ' oldName ]); 
    
    % Clean up  
    clear DoseMBq InjectionTime InjectionTimeInSeconds SUV_factor SeriesTime SeriesTimeInSeconds 
    clear answer conversionFactorTokBq decayFactor defaultanswer deltaT halflife headers i 
    clear imlook4d_Cdata imlook4d_ROI imlook4d_ROINames imlook4d_duration 
    clear imlook4d_frame imlook4d_slice imlook4d_time j mode newHandle newHandles numlines out3 prompt title weight_kg weigth_kg
    clear historyDescriptor imlook4d_ROI_number oldName

    

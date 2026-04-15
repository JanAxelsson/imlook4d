function returnStatus=getFromPacs(DICOM_PACS)
%
% INITIALIZE
%
    returnStatus=1;                   % OK=1, NOT_OK=0, 
    EOL=sprintf('\n');          % End-of-line string for PACS reply
    TAB=' . .  ';

    rememberPath=pwd();
    
    % FIND PATH TO APPLICATION DATA (C:\Documents and Settings\jana\Application Data)
    call_string='echo %APPDATA%';
    cd('C:'); % Need to avoid being on network path (cmd.exe doesn't like this).  Thus set to C:
    [status result]=system( call_string );  % EOL at end of result
    APPDATA=strtrim(result);                % Windows APPDATA variable
    SETTINGSDIRECTORY=[strtrim(result) filesep 'imlook4d'];  % Storage of CLIENT settings
    
    
    % SETUP CLIENT
    %run DICOM_CLIENT
    %CLIENT=[CLIENTAE '@' CLIENTIP];

    % SETUP DCM4CHE
    [pathstr1,name,ext] = fileparts(which('imlook4d')); 
    %DCM4CHE=[pathstr1 filesep 'PACS' filesep 'dcm4che' filesep 'bin' filesep];  % In PACS directory under imlook4d
    DCM4CHE=[pathstr1 filesep 'external functions' filesep 'dcm4che' filesep 'bin' filesep];  % In 'external functions' directory under imlook4d
    
    
    % SETUP PACS
    %run DICOM_PACS
    %eval(['run ' which(DICOM_PACS)])
    %eval(['run ' pathstr1 filesep  'PACS' filesep DICOM_PACS])
    %%eval(['run ' '''' pathstr1 filesep  'PACS' filesep DICOM_PACS '''']);
    %%eval([ '''' pathstr1 filesep  'PACS' filesep DICOM_PACS '''']);
    eval(['run ' '''' pathstr1 filesep  'PACS' filesep DICOM_PACS ''''])
    PACS=[PACSAE '@' PACSIP ':' PACSPORT];

% ------------------------------------------------------------------------
% PART 0)   IF LOCAL SETTINGS DO NOT EXIST, MAKE NEW FILE, ELSE READ CLIENT
%           DATA
% ------------------------------------------------------------------------
    if isdir(SETTINGSDIRECTORY)   % Local settings directory exist
        
        % Read client settings
            run([ SETTINGSDIRECTORY filesep 'DICOM_CLIENT']);
            CLIENT=[CLIENTAE '@' CLIENTIP];

            
         % Check that temporary directory exist, otherwise create it
             if not( isdir(CLIENT_FILE_DESTINTATION) )
                 mkdir(CLIENT_FILE_DESTINTATION);
             end

        
    else  % Local settings directory does not exist
        
        % Create directory
            mkdir(SETTINGSDIRECTORY);
        
        % Make CLIENT file
            s=which('DICOM_CLIENT_template.m');
            newfile=[SETTINGSDIRECTORY filesep 'DICOM_CLIENT.m'];
            copyfile(s, newfile );
            edit(newfile);
            h=msgbox({'Please edit settings.', 'The settings must agree with what is registered on a PACS.', 'Then try again'}, 'imlook4d info');

        % Make CLIENT receiver file
            %s=which('listening_server_template.bat');
            %copyfile(s, [SETTINGSDIRECTORY filesep 'listening_server.bat']);
            %edit([SETTINGSDIRECTORY filesep 'listening_server.bat' ]);
            
            returnStatus=0;
            return

    end
        
  
% ------------------------------------------------------------------------
% PART 0.5)  VERIFY CONNECTION TO PACS
% ------------------------------------------------------------------------

    %
    % DICOM PING PACS
    %
            disp(' ');
            try     
                disp(['DICOM PING PACS=' PACS]);
                call_string=['"' DCM4CHE 'dcmecho' '" '  ' -L' CLIENTAE  ' ' PACS]
                %disp(call_string);
                [status result]=system( call_string );
                %%disp(status);
                if (status>0)
                    disp([' PING FAILED - COULD NOT CONNECT TO PACS (' PACS ')' ]);
                    errordlg({'PING FAILED - COULD NOT CONNECT TO PACS', PACS});
                    return
                else
                    disp(' PING SUCCESFULL');
                end
            catch
                disp(result);
            end      
    
% ------------------------------------------------------------------------
% PART 1)  STUDY SEARCH
% ------------------------------------------------------------------------
    %
    % Build Query String
    %
        try
            %QUERYTYPE=' --patient '
            QUERYTYPE=' --study '
            
            % NOTE: 
            % -r flag with something we query for (for instance patientID in both -r and -q flags) seems to cause too many hits.
            %  Therefore avoid asking for return (-r flag) for patientID, patientName, StudyDate
            
            %QUERY_RETURN=[ ' -r0008103E -r0081030 -r00100020 -r0020000E'  ];  % Return seriesDesc, studyDesc, patientID, seriesInstanceUID
            QUERY_RETURN=[ ' -r0008103E -r0081030 -r0020000E'  ];  % Return seriesDesc, studyDesc, seriesInstanceUID
            QUERY_RETURN=[ QUERY_RETURN '  -r00080060 -r0020000D' ];          % Return modality, studyInstanceUID, studyDate


            prompt={'Patient Name',...
                    'Patient ID',...
                    'Study Date (YYYYMMDD or YYYYMMDD-YYYYMMDD)'};
            title=['PATIENT search (on' PACSAE ')'];
            numlines=1;
            defaultanswer={'', '', ''};
            answer=inputdlg(prompt,title,numlines,defaultanswer);
            QUERY1=[' -qPatientName="' answer{1} '*" -qPatientID="*' answer{2} '*" -qStudyDate="' answer{3}  '" '];
            QUERY=[ QUERY_RETURN QUERY1 QUERYTYPE]
        catch
            disp('You canceled the selection');
            returnStatus=0;
            return
        end

    %
    % Query PACS
    %    

        % Query PACS
        disp('QUERY SENT');
        disp(['PACS=' PACS]);
        call_string=['"' DCM4CHE 'dcmqr' '" ' PACS ' -L ' CLIENT ' ' QUERY]

        [status result]=system( call_string );

        % Analyze PACS response
        clear rows
        rows=strsplit_jan(EOL,result);

        %EOL=sprintf('\r'); 
        % Find row of each query response
        counter=0;
        for i=1:size(rows,2)
            if findstr(  rows{i} , 'Query Response')
                counter=counter+1;
                rowNumber(counter)=i;
                %disp(rows{i});
            end
        end

        % Loop each query response 
        rowNumber(counter+1)=size(rows,2);   % Add last row

    %
    % Populate table
    %    

        disp('Populating PATIENT table');
        for i=1:counter  % Loop responses
            disp(i);
            response(i).patientName=' ';
            response(i).studyDesc=' ';
            response(i).seriesDesc=' ';
            response(i).studyDate=' ';
            response(i).modality=' ';
            response(i).studyInstanceUID=' ';
            response(i).seriesInstanceUID=' ';

            for j=rowNumber(i)+1:rowNumber(i+1)-1  % Loop rows within a response

                %disp([ sprintf('\n') rows{j} ]);
                %disp([num2str(j) '  ' readString(rows{j}) ' --- ' rows{j} ]);

                if findstr(  rows{j} , '(0010,0010)')
                    response(i).patientName=readString(rows{j});
                    disp([num2str(j) ' Patient Name=' response(i).patientName]);
                end
                if findstr(  rows{j} , '(0008,1030)')
                    response(i).studyDesc=readString(rows{j});
                    disp([num2str(j) ' Study desc=' response(i).studyDesc ]);
                end
                if findstr(  rows{j} , '(0008,103E)')
                    response(i).seriesDesc=readString(rows{j});
                    disp([num2str(j) ' Series desc=' response(i).seriesDesc ]);
                end
                if findstr(  rows{j} , '(0010,0020)')
                    response(i).patientID=readString(rows{j});
                    disp([num2str(j) ' Patient ID=' response(i).patientID ]);
                end      
                if findstr(  rows{j} , '(0020,000D)')
                    response(i).studyInstanceUID=readString(rows{j});
                    disp([num2str(j) ' Study Instance UID=' response(i).studyInstanceUID]);
                end   
                if findstr(  rows{j} , '(0020,000E)')
                    response(i).seriesInstanceUID=readString(rows{j});
                    disp([num2str(j) ' Series Instance UID=' response(i).seriesInstanceUID]);
                end    
                if findstr(  rows{j} , '(0008,0020)')
                    response(i).studyDate=readString(rows{j});
                    disp([num2str(j) ' Study Date=' response(i).studyDate]);
                end
                if findstr(  rows{j} , '(0008,0060)')
                    response(i).modality=readString(rows{j});
                    disp([num2str(j) ' Modality=' response(i).modality]);
                end            
            end

            list{i}=[ '<HTML>' ...
                    '<FONT color="blue">' response(i).modality TAB  ...
                    '<FONT color="gray">' response(i).studyDate TAB  ...
                    '<FONT color="blue">' response(i).patientName TAB  ...
                    '<FONT color="gray">' response(i).patientID TAB  ...
                    '<FONT color="blue">' response(i).studyDesc TAB  ...
                    '</HTML>' ];    
        end

        disp(['Found ' num2str(counter) ' PATIENTS on ' PACS]);
        
       if counter==0
          errordlg({'No patients found','', ['on ' PACSAE],'',['(' PACS ')']},'No patients found on PACS')
          returnStatus=0;
          return
       end

    %
    % Select Patient
    %

        % Display list
            [s,ok] = listdlg('PromptString','Select patient:',...
                'SelectionMode','multiple',...
                'ListSize', [700 400], ...
                'ListString',list);

            disp(['Selected row=' num2str(s)]);    

                    disp(['   Patient Name=' response(s).patientName]);
                    disp(['   Study desc=' response(s).studyDesc ]);
                    disp(['   Series desc=' response(s).seriesDesc ]);
                    disp(['   Patient ID=' response(s).patientID ]);
                    disp(['   Study Instance UID=' response(s).studyInstanceUID]);
                    disp(['   Series Instance UID=' response(s).seriesInstanceUID]);
                    disp(['   Study Date=' response(s).studyDate]);
                    disp(['   Modality=' response(s).modality]);
                    disp(' ');
                    
             if not(ok)
                 disp('You canceled the selection');
                 returnStatus=0;
                 return
             end



% ------------------------------------------------------------------------
% PART 2)  SERIES SEARCH
% ------------------------------------------------------------------------

    %
    % Build Query String
    %    

        QUERY_RETURN=[ ' -r0008103E -r0081030 -r00100020 -r0020000E'  ];  % Return seriesDesc, studyDesc, patientID, seriesInstanceUID
        QUERY_RETURN=[ QUERY_RETURN '  -r00080060 -r00100010' ];  % Return modality, studyDate, patientName
        QUERYTYPE=' --series '
        QUERY2=[' -q0020000D="' response(s).studyInstanceUID '" '];
        QUERY=[ QUERY_RETURN QUERY2 QUERYTYPE]
        call_string=['"' DCM4CHE 'dcmqr' '" ' PACS ' -L ' CLIENT ' ' QUERY]

        [status result]=system( call_string )

        % Analyze PACS response
        clear rows
        rows=strsplit_jan(EOL,result);

        %EOL=sprintf('\r'); 
        % Find row of each query response
        counter=0;
        for i=1:size(rows,2)
            if findstr(  rows{i} , 'Query Response')
                counter=counter+1;
                rowNumber(counter)=i;
                %disp(rows{i});
            end
        end

        % Loop each query response 
        rowNumber(counter+1)=size(rows,2);   % Add last row

    %
    % Populate table
    %    
        clear response list

        disp('Populating SERIES table');
        for i=1:counter  % Loop responses
            disp(i);
            response(i).patientName=' ';
            response(i).studyDesc=' ';
            response(i).seriesDesc=' ';
            response(i).studyDate=' ';
            response(i).modality=' ';
            response(i).studyInstanceUID=' ';
            response(i).seriesInstanceUID=' ';

            for j=rowNumber(i)+1:rowNumber(i+1)-1  % Loop rows within a response

                %disp([ sprintf('\n') rows{j} ]);
                %disp([num2str(j) '  ' readString(rows{j}) ' --- ' rows{j} ]);

                if findstr(  rows{j} , '(0010,0010)')
                    response(i).patientName=readString(rows{j});
                    disp([num2str(j) ' Patient Name=' response(i).patientName]);
                end
                if findstr(  rows{j} , '(0008,1030)')
                    response(i).studyDesc=readString(rows{j});
                    disp([num2str(j) ' Study desc=' response(i).studyDesc ]);
                end
                if findstr(  rows{j} , '(0008,103E)')
                    response(i).seriesDesc=readString(rows{j});
                    disp([num2str(j) ' Series desc=' response(i).seriesDesc ]);
                end
                if findstr(  rows{j} , '(0010,0020)')
                    response(i).patientID=readString(rows{j});
                    disp([num2str(j) ' Patient ID=' response(i).patientID ]);
                end      
                if findstr(  rows{j} , '(0020,000D)')
                    response(i).studyInstanceUID=readString(rows{j});
                    disp([num2str(j) ' Study Instance UID=' response(i).studyInstanceUID]);
                end   
                if findstr(  rows{j} , '(0020,000E)')
                    response(i).seriesInstanceUID=readString(rows{j});
                    disp([num2str(j) ' Series Instance UID=' response(i).seriesInstanceUID]);
                end    
                if findstr(  rows{j} , '(0008,0020)')
                    response(i).studyDate=readString(rows{j});
                    disp([num2str(j) ' Study Date=' response(i).studyDate]);
                end
                if findstr(  rows{j} , '(0008,0060)')
                    response(i).modality=readString(rows{j});
                    disp([num2str(j) ' Modality=' response(i).modality]);
                end            
            end

            list{i}=[ '<HTML>' ...
                    '<FONT color="blue">' response(i).modality TAB  ...
                    '<FONT color="gray">' response(i).studyDate TAB  ...
                    '<FONT color="blue">' response(i).patientName TAB  ...
                    '<FONT color="gray">' response(i).studyDesc TAB  ...
                    '<FONT color="blue">' response(i).seriesDesc  ...
                    '</HTML>' ];    
        end

        disp(['Found ' num2str(counter) ' SERIES on ' PACS]);

    %
    % Select scan
    %

        % Display list
            [s,ok] = listdlg('PromptString','Select series:',...
                'SelectionMode','multiple',...
                'ListSize', [700 400], ...
                'ListString',list);

            disp(['Selected row=' num2str(s)]);    
            try
                    disp(['   Patient Name=' response(s).patientName]);
                    disp(['   Study desc=' response(s).studyDesc ]);
                    disp(['   Series desc=' response(s).seriesDesc ]);
                    disp(['   Patient ID=' response(s).patientID ]);
                    disp(['   Study Instance UID=' response(s).studyInstanceUID]);
                    disp(['   Series Instance UID=' response(s).seriesInstanceUID]);
                    disp(['   Study Date=' response(s).studyDate]);
                    disp(['   Modality=' response(s).modality]);
                    disp(' ');
            catch
            end

                    
             if not(ok)
                 disp('You canceled the selection');
                 returnStatus=0;
                 return
             end
% ------------------------------------------------------------------------
% PART 3)  START RECEIVER SCRIPT
% ------------------------------------------------------------------------

            
         % Make CLIENT receiver file (using client settings)
            %0\..\dcm4che\bin\dcmrcv AE_LASSE@192.168.1.213:11112 -dest C:/TEMP_imlook4d
            %bat_command=['%0\..\dcm4che\bin\dcmrcv ' CLIENTAE '@' CLIENTIP ':' CLIENTPORT ' -dest ' CLIENT_FILE_DESTINTATION];
            bat_command=['"' which('dcmrcv.bat') '" ' CLIENTAE '@' CLIENTIP ':' CLIENTPORT ' -dest ' CLIENT_FILE_DESTINTATION];

            fid = fopen([SETTINGSDIRECTORY filesep  'listening_server.bat'], 'wt+');
            fwrite(fid, bat_command);
            %fwrite(fid, 'PAUSE');
            fclose(fid);


        try     
            disp(['Starting receiving server']);
            
            [pathstr1,name,ext] = fileparts(which('imlook4d'));
            %call_string=['"' pathstr1 filesep 'PACS' filesep 'listening_server.bat' '"'];
            %call_string=['"' pathstr1 filesep 'PACS' filesep 'listening_server.bat' '"'];
            

            call_string=['"' SETTINGSDIRECTORY filesep 'listening_server.bat' '"']
            
            call_string=['start "DICOM receiver" cmd /C  ' call_string ];  % Run start command in DOS, to get a separate window

            [status result]=system( call_string );
            %%disp(result);

        catch
            disp(result);
        end   

       
%         call_string=['"' pathstr1 filesep 'PACS' filesep 'listening_server.bat' '"'];
%         call_string=['start "DICOM receiver" cmd /C  ' call_string ];  % Run start command in DOS, to get a separate window
%         [status result]=system( call_string ); 


% ------------------------------------------------------------------------
% PART 4)  VERIFY CONNECTIONS
% ------------------------------------------------------------------------

    %
    % DICOM PING CLIENT
    %
            disp(' ');
            CLIENT=[CLIENTAE '@' CLIENTIP ':' CLIENTPORT]; 
            try     
                disp(['DICOM PING CLIENT=' CLIENT]);
                call_string=['"' DCM4CHE 'dcmecho' '" ' CLIENT]
                %disp(call_string);
                [status result]=system( call_string );
                disp(status)
                if (status>0)
                    disp([' PING FAILED - COULD NOT CONNECT TO LOCAL DICOM RECEIVER ' ]);
                    errordlg({'PING FAILED - COULD NOT CONNECT TO LOCAL DICOM RECEIVER', CLIENT});
                    return
                else
                    disp(' PING SUCCESFULL');
                end
            catch
                disp(result);
            end   

    %
    % DICOM PING PACS
    %
            disp(' ');
            try     
                disp(['DICOM PING PACS=' PACS]);
                call_string=['"' DCM4CHE 'dcmecho' '" '  ' -L' CLIENTAE  ' ' PACS]
                %disp(call_string);
                [status result]=system( call_string );
                %%disp(status)
                if (status>0)
                    disp([' PING FAILED - COULD NOT CONNECT TO PACS (' PACS ')' ]);
                    return
                else
                    disp(' PING SUCCESFULL');
                end
            catch
                disp(result);
            end    

             


% ------------------------------------------------------------------------
% PART 5)  GET FILES FROM PACS
% ------------------------------------------------------------------------
    
    %%for i=1:length(s)
    %
    % ASK FOR FILES
    %
            disp('RECEIVING FILES');
            h = msgbox({'Waiting for files from PACS.', 'File will open in new window.', 'See DICOM receiver window for results'}, 'imlook4d info','help');
            try
                disp('Trying to get files');
                %QUERY=[QUERY ' -q0020000E=' response(s).seriesInstanceUID];
    %             QUERY=[QUERY ' -q00100010="' response(s).patientName '"'];
    %             QUERY=[QUERY ' -q00100020="' response(s).patientID '"'];
    %             QUERY=[QUERY ' -q00081030="' response(s).studyDesc '"'];
    %             QUERY=[QUERY ' -q0008103E="' response(s).seriesDesc '"'];

                QUERY=['-S -q0020000E="' response(s).seriesInstanceUID '" ' QUERY1];  %Reuse 

                % PROBLEM - get whole study instead of selected series.
                call_string=['"' DCM4CHE 'dcmqr' '" ' ' -L' CLIENTAE  ' ' PACS ' ' QUERY ' -cmove ' CLIENTAE  ]



                %dcmqr -LIMANETPACS SUASPETPACS@192.168.1.50:104 -qStudyDate=20090513 -cmove IMANETPACS
                if ok
                    [status result]=system( call_string )
                else
                   disp('YOU DID NOT SELECT ANY SCAN'); 
                end
            catch
                disp(result);
            end
            
            try
                close(h);
            catch
                % msgbox was closed by user.
            end
            
                                
             if not(ok)
                 returnStatus=0;
                 return
             end

  
    disp('DONE');


    %
    % OPEN FILES
    %
        fileList=dir(CLIENT_FILE_DESTINTATION);                            % List temporary directory
        filePath=[ CLIENT_FILE_DESTINTATION filesep fileList(end).name];
        imlook4d(filePath);  % Open imlook4d
        delete([CLIENT_FILE_DESTINTATION filesep '*']);                    % Remove temp files    

  %%end % End looping series
  
   cd(rememberPath)

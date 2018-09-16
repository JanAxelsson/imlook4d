
function SaveTact(hObject, eventdata, handles)
% Called from modelWindow

            %handles=guidata(handle);  % Handles to imlook4d instance creating the button
            
    % RECORD
   try
    if (handles.record.enabled == 1)
        EOL = sprintf('\n');
        handles.record.editor.insertTextAtCaret(['Button(''TACT to file'')' EOL]);  % Insert text at caret
    end
   catch
   end           
                   

            
            
            %
            % Save to openmenu
            %
                %[file,path] = uiputfile('TACT.xls','TACT-curve Save file name');

                %[file,path, filterindex] = uiputfile( ...

                [file,path] = uiputfile( {...       
                    '*.txt', 'imlook4d TABs (*.txt)'; ...
                    '*.tac', 'Pmod (*.tac)'; ... 
                     '*.xls', 'imlook4d (*.xls)'; ...
					 '*.xlsx', 'imlook4d (*.xlsx)'; ...
                    '*.sif', 'Turku (blood/weight)  (*.sif)' ...
                    }, ... 
                    'TACT-curve (Select type)', 'TACT.txt');%TS xlsx
                

 
                
                [pathstr,name,ext] = fileparts(file);  % To get extension 
                fullPath=[path file];

                roiNames = handles.TACT.roiNames;
                frameNumbers = handles.TACT.frameNumber ;
                timeScale = handles.TACT.startTime;
                duration = handles.TACT.duration ;
                activity = handles.TACT.tact;
                stdev = handles.TACT.std;

                
                
                switch ext
                    case '.xls' % imlook4d TS xls
                        tempHeader={'frame', 'time [s]', 'duration [s]', roiNames{:} };
                        
                        % Add std columns, one per ROI
                        for i=1:length(roiNames)
                            tempHeader = [ tempHeader { ['std ' roiNames{i}] } ];
                        end
                        
                        
                       % tempHeader = [ tempHeader { sprintf(['std %s' '\t'], roiNames{:}) } ];
                       A = [ tempHeader 
                            num2cell([ frameNumbers timeScale duration double(activity) double(stdev)] ) ]
                        try  
                            xlswrite(fullPath,A);
                            save('A.mat','A');%TS
                        catch
                           disp('ERROR -- try .txt option instead'); 
                        end
                        
                        
					case '.xlsx' % imlook4d TS xlsx
                        tempHeader={'frame', 'time [s]', 'duration [s]', roiNames{:} };
                        
                        % Add std columns, one per ROI
                        for i=1:length(roiNames)
                            tempHeader = [ tempHeader { ['std ' roiNames{i}] } ];
                        end
                        
                        
                       % tempHeader = [ tempHeader { sprintf(['std %s' '\t'], roiNames{:}) } ];
                       A = [ tempHeader 
                            num2cell([ frameNumbers timeScale duration double(activity) double(stdev)] ) ]
                        try  
                            xlswrite(fullPath,A);
                            save('A.mat','A');
                        catch
                           disp('ERROR -- try .txt option instead'); 
                        end
                        
                        
                     case '.txt' % imlook4d
                        tempHeader={'frame', 'time [s]', 'duration [s]', roiNames{:} };
                        tactHeader=[sprintf(['%s' '\t'], tempHeader{:})  sprintf(['std %s' '\t'], roiNames{:}  )];
                        %tactHeader=[sprintf(['%s' '\t'], tempHeader{:}) ];
                        tactHeader=tactHeader(1:end-1); % Remove last TAB
                        try
                            save_cellarray( num2cell([ frameNumbers timeScale duration double(activity) double(stdev)]), fullPath, tactHeader );
                        catch
                            %disp('You selected not to save TACT curve');
                        end
                        
                        
                        
                    case {'.tac'}
                        %start[seconds]	end[kBq/cc]	Group	cer	striatum
                        unitFactor=1;
                        unitString=handles.image.unit;
                        if strcmp( unitString, 'BQML') % DICOM unit
                            unitString='kBq/cc';
                            unitFactor=1/1000;
                        end
                        
                        tempHeader={'start[seconds]', ['end[' unitString ']'] , roiNames{:} };
                        tactHeader=[sprintf(['%s' '\t'], tempHeader{:}) ];
                        tactHeader=tactHeader(1:end-1); % Remove last TAB
                        try
                            % Unit conversion factor BQML->kBq/cc
                            
                            save_cellarray( num2cell([ timeScale (timeScale+duration) unitFactor*double(activity) ]), fullPath, tactHeader );
                        catch
                            %disp('You selected not to save TACT curve');
                        end
                        
                    case {'.dft'}
                        % Turku should go here
                        
                    case {'.sif'}
                        % Turku sif file 
                        
                        % Simplified sif file, from one ROI
                        
                        % Header info
                        scan_start_time = 'xx/xx/xxxx xx:xx:xx'
                        number_of_frames = length(frameNumbers);
                        number_of_columns = 2 + size(activity,2) ;
                        SIF_version = '1';
                        study_ID = 'xxxx';
                        isotope = 'X-XX';

                        
                        if (  size(activity,2) == 1 )
                           activity = [ activity activity ];  % Sif seems to require 4 columns (minimum) 
                           number_of_columns = 2 + size(activity,2) ;
                        end
                        
                        tactHeader=[sprintf(['%s' '\t'], scan_start_time, num2str(number_of_frames), num2str(number_of_columns), SIF_version, study_ID, isotope) ];
                        tactHeader=tactHeader(1:end-1); % Remove last TAB
                        
                        unitFactor = 1; % Do nothing
                        try

                            save_cellarray( num2cell([ timeScale (timeScale+duration) unitFactor*double(activity) ]), fullPath, tactHeader );
                        catch
                            %disp('You selected not to save TACT curve');
                        end                       
                        
                        

                    otherwise
                        warning('Unexpected file type. No file created.')
                end
                
                
                
        % Dummy function to override duration from timefun toolbox in Matlab 2014b
        function duration ()
% DICOM_info.m
%
% Displays a DICOM header for current frame and slice

%
% INITIALIZE
%
    % Export to work space
    imlook4d('exportToWorkspace_Callback', imlook4d_current_handle,{},imlook4d_current_handles);  % Export to workspace
    
    handles=imlook4d_current_handles;
    
    numberOfSlices=size(imlook4d_Cdata,3);
    
    % SETUP DCM4CHE
    [pathstr1,name,ext] = fileparts(which('imlook4d')); 
    

    
    
    %DCM4CHE=[pathstr1 filesep 'PACS' filesep 'dcm4che' filesep 'bin' filesep];  % In PACS directory under imlook4d
    DCM4CHE=[pathstr1 filesep 'external functions' filesep 'dcm4che' filesep 'bin' filesep];  % In 'external functions' directory under imlook4d
    
    % Get file name if DICOM (otherwise bail out)
    if strcmp(imlook4d_current_handles.image.fileType,'DICOM')
        mode=handles.image.dirtyDICOMMode;
        i=imlook4d_slice+numberOfSlices*(imlook4d_frame-1);
        sortedHeaders=handles.image.dirtyDICOMHeader;
        filename=handles.image.dirtyDICOMFileNames{i}
        %[pathstr, name, ext, versn] = fileparts(handles.image.dirtyDICOMFileNames{i});
        
        % Correct beginning to \\ if pathstr1 starts with \
        if strcmp(filename(1),'\')
            filename=['\' filename];
        end
        
    else
        errordlg({'Error not a DICOM file','', filename,''})
        return
    end
    

    
%
% JAVA CLASPATH
%    
    d=fileparts( fileparts( which('dcm2txt.bat')));  % Identify where dcm4che2 is located from a bat-file in the package
    d=fullfile(d, 'lib');   % Find ../lib package
    
    javaaddpath(fullfile(d ,'dcm4che-tool-dcm2txt-2.0.19.jar'))
    javaaddpath(fullfile(d ,'dcm4che-core-2.0.19.jar'))
    javaaddpath(fullfile(d ,'slf4j-log4j12-1.5.0.jar'))
    javaaddpath(fullfile(d ,'slf4j-api-1.5.0.jar'))
    javaaddpath(fullfile(d ,'log4j-1.2.13.jar'))
    javaaddpath(fullfile(d,'commons-cli-1.1.jar'))
    
%
% RUN (NEW)
%
    
    % See API:  http://bradleyross.users.sourceforge.net/docs/dicom/doc/org/dcm4che2/tool/dcm2txt/Dcm2Txt.html
    import java.io.File;
    import org.dcm4che2.tool.dcm2txt.*;
    
    %F=File('C:\Users\Jan\Desktop\FILER\Fantomer\Striatum 1  (2013-SEP-23) - exam-4858\[CT] CTAC 3.27 - serie2\1')
    F=File(filename);
    myObject=Dcm2Txt;
    myObject.setMaxWidth(200)
    %result=myObject.dump(F)
    
    result=evalc('myObject.dump(F)');
    
    
%
% RUN (OLD)
%
      errormsg='';

%     oldDir=pwd();
%     cd('C:'); % Need to avoid being on network path (cmd.exe doesn't like this).  Thus set to C:
%     
%     call_string=['"' DCM4CHE 'dcm2txt' '" -w 200 "' filesep filename '" ']
%     
%     call_string=[ 'dcm2txt.bat' ' -w 200 "' filesep filename '" ']
% 
%     [status result]=system( call_string );
%     
%     errormsg='';
%     if status>0 
%         errormsg=['<h3> Error reading dicom info - try saving file first </h3>'  ];
%     end
    
    % Filter result
    
    
    % Display
    pageTitle='<h3> DICOM header </h3>';
    web(['text:// '  '<html><title>DICOM header</title>'...
        '<h1> DICOM header </h1>' ...
        '<h3>' errormsg '</h3>'...
        '<h3>' filename '</h3>'...
        ' <PRE>' result '</PRE>' ... 
        '</html>'] );

     
     
 %   
 % FINALIZE
 %
    try cd(oldDir) 
    catch
    end
    %clear tempHandle tempHandles
    clear handles DCM4CHE pathstr1 name ext versn mode i sortedHeaders filename call_string status result numberOfSlices imlook4d_slice imlook4d_frame oldDir
    clear myObject F d errormsg pageTitle
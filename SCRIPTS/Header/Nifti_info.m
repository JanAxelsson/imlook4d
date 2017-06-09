% Nifti_info.m
%
% Plots a DICOM tag value over slices for current frame

%
% INITIALIZE
%
    % Export to work space
   %imlook4d('exportToWorkspace_Callback', imlook4d_current_handle,{},imlook4d_current_handles);  % Export to workspace
   
   StoreVariables
   ExportUntouched

   % Dimension bit of header
       %s=imlook4d_current_handles.image.nii.original.hdr.dime;
       s=imlook4d_current_handles.image.nii.hdr.dime;
       fn=fieldnames(s(1)); % struct names
       sc=struct2cell(s(:));% struct values

       message='<TABLE>';
       message=[message '<TR><TH COLSPAN="2"><h3> dime </h3></TH></TR>'];
       for i=1:length(fn)
          a1=fn{i};
          a2=num2str(sc{i});
          message=[message parseHTMLTableRow( a1, a2)];
       end
       message=[message '</TABLE>'];
       

   % Hist bit of header   
       %s=imlook4d_current_handles.image.nii.original.hdr.hist;
       s=imlook4d_current_handles.image.nii.hdr.hist;
       fn=fieldnames(s(1)); % struct names
       sc=struct2cell(s(:));% struct values
       
       
       
       message=[message '<TABLE>'];
       message=[message '<TR><TH COLSPAN="2"><h3> hist </h3></TH></TR>'];
       for i=1:length(fn)
          a1=fn{i};
          a2=num2str(sc{i});
          try
                message=[message parseHTMLTableRow( a1, a2)];
          catch
              % Assume a2 is a matrix
              message=[message parseHTMLTableRow( a1,a2(1,:))];
              for j=2:size(a2,1)
                 message=[message parseHTMLTableRow( ' ',a2(j,:))];
              end
          end
       end
       message=[message '</TABLE>'];

    
    % Display
        filename=imlook4d_current_handles.image.nii.fileprefix;
        web(['text:// '  '<html><title>NIFTI info</title>'...
            '<h1> NIFTI header </h1>' ...
            '<h3>' filename '</h3>'...
            message ... 
            '</html>'] );

     
     
 %   
 % FINALIZE
 %
    %clear tempHandle tempHandles
    %clear handles DCM4CHE pathstr1 name ext versn mode i sortedHeaders filename call_string status result numberOfSlices imlook4d_slice imlook4d_frame oldDir
 ClearVariables
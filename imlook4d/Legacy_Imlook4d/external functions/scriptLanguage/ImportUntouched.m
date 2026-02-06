    
% NOTE: This function is not used right now, anywhere, and it is questionable if it works 

% Import into imlook4d from Workspace
        imlook4d('importUntouched_Callback', imlook4d_current_handle,{},imlook4d_current_handles); % Import from workspace to current imlook4d instance   
        
        
%         
%     % Import if changed
%     Cdata_Changed=(sum(abs(imlook4d_Cdata(:)-imlook4d_current_handles.image.Cdata(:)))>0 );
%     
%     if Cdata_Changed        
%         % Use case
%         %   Export, or Export-untouched.  
%         %   Purpose to change data.  
%         %   Changed data is imported.
%         %
%         %   If imlook4d_Cdata is changed, we don't import it.
%         
%         % Import into imlook4d from Workspace
%         imlook4d('importFromWorkspace_Callback', imlook4d_current_handle,{},imlook4d_current_handles); % Import from workspace to current imlook4d instance        
%     else
%         % Use case
%         %   Export.  (Export gives the PCA-filtered data to imlook4d_Cdata.  )  
%         %   
%         %   It is typically BAD to import PCA-filtered data into the image matrix.
%         %   (thus replacing the matrix with PCA-filtered data)
%         %
%         %   If imlook4d_Cdata is not changed, we don't import it.
% 
%         imlook4d('importFromWorkspace_Callback', imlook4d_current_handle,{},imlook4d_current_handles,'block'); % Import from workspace to current imlook4d instance 
%     end

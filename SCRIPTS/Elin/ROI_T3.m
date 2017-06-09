% Ett script som ber�knar roi f�r en tum�r utifr�n formeln T=I_bgd+eps*I_70 
% d�r T �r tr�skelv�rde f�r tum�ren, I_bgd �r intensiteten i bakgrunden och
% I_70 �r intensiteten inom omr�det med intensitet h�gre �n 70% av
% maxintensiteten. 

% Threshold.m
%
% SCRIPT for imlook4d to obtain ROI from pixels above threshold.
%
% Pixels in the currently selected frame are compared to the threshold.
%
% Threshold is specified in percent of maximum in each slice.
%
% 
%
%
% Jan Axelsson

% INITIALIZE

    %  imlook4d_current_handles is updated whenever SCRIPTS menu in imlook4d is
    %  selected
    StartScript
    historyDescriptor='Ny ROI'; 

    c = ontopMsgbox(imlook4d_current_handle,'Rita en VOI som innefattar hela det aktiva omr�det, men inga andra aktiva omr�den. N�r du �r klar, tryck ok.', 'Hj�lptext');
    
    Export
    
    ROI_large=single(imlook4d_ROI);
    ROI_large_content=ROI_large.*imlook4d_Cdata;
    
    
    [roi_max, z]=max(max(max(ROI_large_content)));
    [~, y]=max(max(ROI_large_content(:, :, z)));
    [~, x]=max(max(ROI_large_content(:, :, z).'));
    
    T_70=0.7*roi_max;
    
    ROI_70=regiongrowing_elin3(imlook4d_Cdata,T_70,x,y,z);
    I_70=sum(ROI_70(:).*imlook4d_Cdata(:))/sum(ROI_70(:));   
    
    %activeROI=get(imlook4d_current_handles.ROINumberMenu,'Value');
    
    f = ontopMsgbox(imlook4d_current_handle,'Rita en roi f�r bakgrund. Tryck sedan ok', 'Hj�lptext');
    
    Export
    
    
    ROI_bgd=single(imlook4d_ROI);
    I_bgd=sum(ROI_bgd(:).*imlook4d_Cdata(:))/sum(ROI_bgd(:));    
   
    eps=0.3;
    
    T_bgd=I_bgd+eps*I_70;
    
    
    ROI_T_bgd=regiongrowing_elin3(imlook4d_Cdata,T_bgd,x,y,z);
    I_T_bgd=sum(ROI_T_bgd(:).*imlook4d_Cdata(:))/sum(ROI_T_bgd(:));
    
    imlook4d_ROI=ROI_T_bgd;

    EndScript 

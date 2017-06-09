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

    g = ontopMsgbox(imlook4d_current_handle,'Bl�ddra till den slice d�r du vill skapa din ROI. Tryck sedan ok.', 'Hj�lptext');
    
    d = ontopMsgbox(imlook4d_current_handle,'N�r du har tryckt ok kommer ett kors att synas i bilden. Klicka d� d�r du vill skapa din ROI', 'Hj�lptext');
    [x, y]=ginput(1);
    x=round(x);
    y=round(y);
    z = floor(get(imlook4d_current_handles.SliceNumSlider,'Value'));  
    
    image_temp=imlook4d_Cdata(x-10:x+10, y-10:y+10, z-5:z+5);
    roi_max=max(image_temp(:));
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

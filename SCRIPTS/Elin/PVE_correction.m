% A script for correction for partial volume effects. The script takes the
% image and draws a VOI with an algorithm that calculates a theshold based
% on intensity in tumour and background. This VOI is used for calculation
% of a correct uptake based on the point spread function. 

% Att lägga till: 
% 1) Eventuell möjlighet att definiera olika bakgrunder för olika tumörer.
% 2) Möjlighet att modifiera VOI inför PVE-korrektion

StartScript
historyDescriptor='Ny ROI'; 

% Construct a questdlg with three options
choice = questdlg('Vilken rekonstruktion har bilden?', ...
	'Rekonstruktionsparametrar', ...
	'SharpIR 3 iterationer','SharpIR 6 iterationer','VP HD', 'VP HD');
% Handle response
switch choice
    case 'SharpIR 3 iterationer'
        answer=[3.47, 4.71, 0.3];
    case 'SharpIR 6 iterationer'
        answer=[3.4, 4.7, 0.3]; %Obs! Endast temporärt!
        a = ontopMsgbox(imlook4d_current_handle,'Observera att inställningarna för blider med denna rekonstruktion inte är färdiga. Resultaten blir därför felaktiga.', 'Hjälptext');
    case 'VP HD'
        answer=[7.3, 6.1, 0.38];
end

sigmaxy=answer(1)/(2.35*imlook4d_current_handles.image.pixelSizeX);
sigmaz=answer(2)/(2.35*imlook4d_current_handles.image.sliceSpacing);
eps=answer(3);

    f = ontopMsgbox(imlook4d_current_handle,'Rita en roi för bakgrund. Tryck sedan ok.', 'Hjälptext');
    
    Export
    
    
    ROI_bgd=single(imlook4d_ROI);
    I_bgd=sum(ROI_bgd(:).*imlook4d_Cdata(:))/sum(ROI_bgd(:));    
    imlook4d_ROI=0.*imlook4d_ROI;
    
    Import

    c = ontopMsgbox(imlook4d_current_handle,'Rita en ROI för varje tumör. Varje ROI ska innefatta ett ungefärligt maxvärde på tumören. När du är klar, tryck ok.', 'Hjälptext');
    
    Export
    
    roi=single(zeros(size(imlook4d_ROI)));    
    for i=1:max(imlook4d_ROI(:));
        roi_content=(imlook4d_ROI==i).*imlook4d_Cdata;
        [roi_max, z1]=max(max(max(roi_content)));
        [~, y1]=max(max(roi_content(:, :, z1)));
        [~, x1]=max(max(roi_content(:, :, z1).'));
        T_70_temp=roi_max*0.7;
        

        roi=roi+regiongrow(imlook4d_Cdata,T_70_temp,x1,y1,z1)*double(i);
    end
    imlook4d_ROI=roi;
    
    size_roi=size(imlook4d_ROI);
    ROI_large=single(imlook4d_ROI);
    T_bgd=zeros(1, max(imlook4d_ROI(:)));
    I_T_bgd=zeros(1, max(imlook4d_ROI(:)));
    tumour_size=zeros(1, max(imlook4d_ROI(:)));
    original_uptake=zeros(1, max(imlook4d_ROI(:)));
    corrected_uptake=zeros(1, max(imlook4d_ROI(:)));
    corr_spread_out=zeros(1, max(imlook4d_ROI(:)));
    corr_spread_in=zeros(1, max(imlook4d_ROI(:)));
    
    x=1:1:size_roi(1);
    x=single(x);
    y=1:1:size_roi(2);
    y=single(y);
    z=1:1:size_roi(3);
    z=single(z);
    [X, Y, Z]=ndgrid(x, y, z);
    mux=(size_roi(1)+2)/2;
    muy=(size_roi(2)+2)/2;
    muz=(size_roi(3)+1)/2;
    
    FFTN = @(x)fftshift(fftn(ifftshift(x)));
iFFTN = @(x)fftshift(ifftn(ifftshift(x)));



    psf=(1/(2*pi)^(3/2))*(1/(sigmaxy*sigmaxy*sigmaz))*exp(-(((X-mux).^2)/(2*sigmaxy^2)+((Y-muy).^2)/(2*sigmaxy^2)+((Z-muz).^2)/(2*sigmaz^2)));
    ftn_psf=FFTN(psf);
    
    
    
    imlook4d_ROI=zeros(size_roi);
    for i=1:max(ROI_large(:))
    
        ROI_large_temp=(ROI_large.*(ROI_large==i))/i;
        ROI_large_temp=single(ROI_large_temp);

        ROI_large_content=ROI_large_temp.*imlook4d_Cdata;


        [roi_max, z0]=max(max(max(ROI_large_content)));
        [~, y0]=max(max(ROI_large_content(:, :, z0)));
        [~, x0]=max(max(ROI_large_content(:, :, z0).'));

        T_70=0.7*roi_max;

        ROI_70=regiongrow(imlook4d_Cdata,T_70,x0,y0,z0);
        I_70=sum(ROI_70(:).*imlook4d_Cdata(:))/sum(ROI_70(:));   

        T_bgd(i)=I_bgd+eps*I_70;


        ROI_T_bgd_temp=regiongrow(imlook4d_Cdata,T_bgd(i),x0,y0,z0);
        I_T_bgd(i)=sum(ROI_T_bgd_temp(:).*imlook4d_Cdata(:))/sum(ROI_T_bgd_temp(:));
        imlook4d_ROI=imlook4d_ROI+ROI_T_bgd_temp*i;
    end
    Import
    
     b = ontopMsgbox(imlook4d_current_handle,'Kontrollera att visade VOI:s överensstämmer med tumörerna. Du har också möjlighet att ändra föreslagna VOI:s. När du är klar, tryck ok.', 'Hjälptext');
    Import
     d = waitbar(0,'Vänligen vänta...'); 
    for i=1:max(ROI_large(:))
        roi=single((imlook4d_ROI==i));

        ftn_roi=FFTN(roi);

        ftn_conv_roi=ftn_roi.*ftn_psf;
        conv_roi=iFFTN(ftn_conv_roi);

        inv_roi=roi;
        inv_roi(inv_roi==0)=20;
        inv_roi(inv_roi==1)=0;
        inv_roi(inv_roi==20)=1;

        ftn_inv_roi=FFTN(inv_roi);
        ftn_conv_inv_roi=ftn_inv_roi.*ftn_psf;
        conv_inv_roi=iFFTN(ftn_conv_inv_roi);

        corr_spread_out(i)=sum(conv_roi(:).*roi(:))/sum(roi(:));  %Kontrollera uttryck!!!
        corr_spread_in(i)=sum(conv_inv_roi(:).*roi(:))/sum(roi(:)); %Kontrollera uttryck!!!

        original_uptake(i)=sum(roi(:).*imlook4d_Cdata(:))/sum(roi(:));
        corrected_uptake(i)=(original_uptake(i)-corr_spread_in(i)*I_bgd)/corr_spread_out(i);

        tumour_size(i)=sum(roi(:))*imlook4d_current_handles.image.pixelSizeX*imlook4d_current_handles.image.pixelSizeY*imlook4d_current_handles.image.sliceSpacing/(1E3);

        waitbar(i/max(ROI_large(:)),d)

    end
    
    delete(d)

Import

fprintf('\n Tumörerna har storlek: \n');
fprintf('%5.2f ml, ', tumour_size);
fprintf('\n Upptag i tumörerna innan korrektion för PVE är: \n');
fprintf('%5.0f, ', original_uptake);
fprintf('\n Upptag i tumörerna efter korrektion för PVE är: \n');
fprintf('%5.0f, ', corrected_uptake);
fprintf('\n Korrektionsfaktorn för inspridning är: \n');
fprintf('%4.2f, ', corr_spread_in);
fprintf('\n Korrektionsfaktorn för utspridning är: \n');
fprintf('%4.2f, ', corr_spread_out);
fprintf('\n')

choice = questdlg('Vill du spara tumördatat i Excell?', ...
	'Spara?', ...
	'Ja','Nej','Nej');
% Handle response
switch choice
    case 'Ja'
        [file,path] = uiputfile('tumour_info.xls','spara som');
        tumour_number=1:1:max(imlook4d_ROI(:));
        data_name = {'tumör','originalupptag', 'korrigerat upptag', 'korr. inspridning' 'korr. utspridning', 'storlek tumör (ml)'};
        data=[tumour_number' original_uptake',  corrected_uptake', corr_spread_in', corr_spread_out', tumour_size'];

        cd(path)

        xlswrite(file, data_name, 1, 'B2');
        xlswrite(file, data, 1, 'B3');

    case 'Nej'
end

EndScript 
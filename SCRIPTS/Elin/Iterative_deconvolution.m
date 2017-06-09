% Start script
    StartScript;
    historyDescriptor='deconvolved'; % Make a descriptor to prefix new window title with

    % Get user input
    prompt={'Standard deviation in x direction, given in mm',...
                'Standard deviation in y direction',...
                'Standard deviation in z direction)',...
                'Number of iterations',...
                'Convergens rate (normaly between 1 and 2'};
        title='PSF data';
        numlines=1;
    	defaultanswer={'3', '3' '2.6', '20', '1'};

    answer=inputdlg(prompt,title,numlines,defaultanswer);
    
    sigmax=str2num(answer{1});
    sigmay=str2num(answer{2});
    sigmaz=str2num(answer{3});
    n=str2num(answer{4});
    alpha=str2num(answer{5});
    
    sigmax=sigmax/imlook4d_current_handles.image.pixelSizeX;
    sigmay=sigmay/imlook4d_current_handles.image.pixelSizeY;
    sigmaz=sigmaz/imlook4d_current_handles.image.sliceSpacing;
    
    FFTN = @(x)fftshift(fftn(ifftshift(x)));
    iFFTN = @(x)fftshift(ifftn(ifftshift(x)));
    image7=imlook4d_Cdata;
    si7=sum(image7(:));
    simage7=size(image7);
    x7=1:1:simage7(1);
    x7=single(x7);
    y7=1:1:simage7(2);
    y7=single(y7);
    z7=1:1:simage7(3);
    z7=single(z7);
    [X7, Y7, Z7]=meshgrid(x7, y7, z7);
    mux7=(simage7(1)+2)/2;
    muy7=(simage7(2)+2)/2;
    muz7=(simage7(3)+1)/2;
    psf7=(1/(2*pi)^(3/2))*(1/(sigmax*sigmay*sigmaz))*exp(-(((X7-mux7).^2)/(2*sigmax^2)+((Y7-muy7).^2)/(2*sigmay^2)+((Z7-muz7).^2)/(2*sigmaz^2)));
    PSF=FFTN(psf7);
    IMAGE=FFTN(image7);
    approx_image7=image7;
    r7=zeros(1, n);

    for i=1:n
        APPROX_IMAGE=FFTN(approx_image7);
        GUESS=APPROX_IMAGE.*PSF;
        guess7=iFFTN(GUESS);
        approx_image7=approx_image7+alpha*(image7-guess7);
        approx_image7(approx_image7<0)=0;
        approx_image7=abs(approx_image7);
        r7(i)=sum((guess7(:)-image7(:)).^2);
    end

    
    imlook4d_Cdata=zeros(simage7(1), simage7(2), simage7(3), 2);
    imlook4d_Cdata(:, :, :, 1)=image7;
    imlook4d_Cdata(:, :, :, 2)=approx_image7;

        % Finish script
        EndScript




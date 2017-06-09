% Setup AE_TITLE, IP, port for your DICOM receiver 
%(You define this, and register them at the PACS)
    CLIENTAE='AE_LASSE';        % LOCAL AE TITLE (as registered on PACS)
    CLIENTIP='192.168.1.213';     % LOCAL IP (this computer)
    CLIENTPORT='11112';         % PORT on client
    CLIENT_FILE_DESTINTATION='C:\TEMP_imlook4d';  % Save files received  from PACS here
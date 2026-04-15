function isNewVersion = checkForNewVersion()

    isNewVersion = false;
    currentVersion = getImlook4dVersion();


    %% Bail out if Develop version
    if (  strcmpi( currentVersion, 'Develop') ) 
        %return
    end


    %% Read latest available version from Github
    latestFileListURL = 'https://raw.githubusercontent.com/JanAxelsson/imlook4d/master/imlook4d/latest_releases.txt';
    o = weboptions('CertificateFilename',''); % Test to fix error behind firewall
    text = webread(latestFileListURL,o);

    data = strsplit( text);
    latestVersion = data{1}; % Latest version

    disp( [ 'Latest available version = ' latestVersion ]);



    %% Compare if already at latest version
    try
        if ( ~strcmp( currentVersion, latestVersion) )
            isNewVersion = true;
        end
    catch
    end

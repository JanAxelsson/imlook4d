function version=getImlook4dVersion()
      fid = fopen('version.txt');
      version = fgetl(fid)  % read line excluding newline character
                 
                 
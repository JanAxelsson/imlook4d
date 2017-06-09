function [frame_data, time, duration]= SHR_readMultipleFiles(  pathname ,  pixelx,  pixely);
% SHR_readfile
%
% Routine for reading all Hamamatsu SHR PET-data (*.ima*) files from a directory
%
% [frame_data, time, duration]= SHR_readMultipleFiles(  filename ,  pixelx,  pixely);
%
% Inputs:
%   pathname - path to ONE file in directory
%   pixelx -   number of pixels in first dimension
%   pixely -   number of pixels in second dimension
%
% Output:
%   frame_data -  4-dimensional matrix [X x Y x M * N] with image 
%				    size X x Y with M slices and N frames.
%   time      -  vector with frame start times  [s]
%   duration  -  vector with frame durations    [s]
%
% Uses:
%   SHR_readfile
%   loadtable
%
% Author:   
%   Jan Axelsson, Uppsala Imanet, 080409

 % Initialize
    numberOfSlices=31; % Always, for SHR 7700 data
    time=0;
    duration=0;
 
%
%  READ IMAGE FILES
%

    % List "ima" files in directory
    [pathstr, name, ext] = fileparts(pathname);
    filenames=dir([pathstr filesep '*.ima*']);

    numberOfFrames=size(filenames,1);
    disp(['Number of frames=' num2str(numberOfFrames)]);

    % Initialize
    frame_data=zeros( pixelx, pixely, numberOfSlices, numberOfFrames);

    % Build dynamic (4D) data set
    for i=1 : numberOfFrames
        disp(['Frame=' num2str(i) '   Filename=' filenames(i).name ]);
        frame_data(:,:,:,i)=SHR_readfile(  [pathstr filesep filenames(i).name] ,  pixelx,  pixely);
    end


%
%  READ TIME INFO
%

    % Read time data from mon file
    try
        TAB=sprintf('\t');
        monFileName=[pathstr filesep name '.mon'];
        disp(['File name for .mon-file=' monFileName ]);
        time_data = loadtable( monFileName, TAB, 1);


        % Operate on time data
        startRealTime=time_data{1,2};

        for i=1 : numberOfFrames
           % Calculate in seconds (Matlab's serial time in days times 60*60*24 seconds/day)
           time(i)=60*60*24*(datenum(time_data{i,2} )-datenum(startRealTime)  );
           duration(i)=60*60*24*(datenum(time_data{i,3})-datenum(time_data{i,2})  );
        end

    catch
        disp('Error involving .mon file');
        time_data=0;
    end

%
%  READ SCALE FACTOR
%

    % Read scale factor from inf file
    try
        infFileName=[pathstr filesep name '.inf'];
        disp(['File name for .inf-file=' infFileName ]);
        convFactor=1;


        % Loop input file
            %fid=fopen('C:\Documents and Settings\jana\Desktop\301378\080505_fcc_301378.inf');
            fid=fopen(infFileName);
            

            % Loop until EOF
            while 1
                tline = fgetl(fid);
                if ~ischar(tline),   break,   end


                try
                    if strcmp(tline(1:10),'Conversion')
                        %disp(tline);
                        %disp(tline(21:end));
                        convFactor=str2num(tline(21:end));
                        disp(['Conversion factor=' num2str(convFactor)]);
                    end
                catch % Catch if tline is shorter than 10 characters
                end
            end
            
            fclose(fid);

    catch
        disp('Error involving .inf file');
        scale_factor=1;
        fclose(fid);
    end    
    
    
%
% Multiply by scale factor
%
    frame_data=convFactor*frame_data;
    
        
    










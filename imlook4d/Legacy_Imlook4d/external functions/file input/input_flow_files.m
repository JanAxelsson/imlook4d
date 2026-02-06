function [bsx, bsy, rfx, rfy]= input_flow_files(dummy)
% INPUT_FLOW_FILES
%
% Routine for reading blood sampling and rates files into matrices.
%
% [bsx, bsy, rfx, rfy]= input_flow_files;
%   reads time and count rate data into vectors.  
%   File paths are selected via user interface.
%   The two files are graphed in a single window.
%
% input_flow_files; 
%   plots two files in a single window.  
%   File paths are selected via user interface.
%
% Inputs:
%   none
%
% Outputs:
%   bsx -   blood sample x (time)
%   bsy -   blood sample y (counts/s)
%   rfx -   rate file x (time)
%   rfy -   rate file y (counts/s)
%
% Uses:
%   read_bs -   routine for reading scanditronix blood sample files
%
% Author:   
%   Jan Axelsson, Uppsala Imanet, 031119
 

% Read scanditronix blood data file

 [FileName,PathName] = uigetfile('*.bsp','Select Blood Sample File');
 [bsx, bsy, bs_dt, bs_n, bs_calib] = read_bs([PathName FileName]);

 % Display scanditronix blood data file
 
 subplot(4,1,1); plot (bsx, bsy,'bo')
 
 xlabel('time (s)');
 ylabel('bs count (counts/s)');
 title('Scanditronix Blood Sample File','FontSize',12);
 
 % Read rate curve file
 
 [FileName,PathName] = uigetfile('*.r','Select Rate Curve File');
 data = dlmread([PathName FileName],'\t' ,1,0); 
 rfx=data(:,1)/10000;   % Time in seconds
 rfy=data(:,4);         % pdata column
    
 % Display rate curve file
 
 subplot(4,1,2);plot (rfx, rfy);
  
 xlabel('time (s)');
 ylabel('pdata (counts/s)');
 title('Head Curve File','FontSize',12);
 
 %Output first rows in files
 
 range=1:10;    % rows to display
 disp('START input_flow_files')
 disp('index            bsx              bsy            rfx              rfy')
 disp( num2str([range' bsx(range) bsy(range) rfx(range) rfy(range)],10));


%
% EXTRA STUFF THAT SHOULD BE MOVED TO ITS OWN ROUTINE
%

 % create equal number of data points from blood data as from rates file
    % This is done by lowering the number of data points in rates file to that
    % of blood file, using linear interpolation.
    
 yi = interp1(rfx,rfy,bsx,'linear')
 disp( [' size scanditronix=' num2str(size(rfx)) ...
         '   size blood=' num2str(size(bsx)) ...
         '   size (interpolated scanditronix)=' num2str(size(yi))]);
 
  subplot(4,1,3);plot (bsx,yi, 'bo');
    
 xlabel('time (s)');
 ylabel('pdata (counts/s)');
 title('Resampled Head Curve File','FontSize',12);
 
  % Do cross correlation 
    
  yi(1)=0;  % Set first value to zero (prefered compared to allow extrapolation in interp1 routine).
  
  cc1=conv(flipud(yi),bsy);
  %cc2=conv(bsy,flipud(yi)); % tested to give same result as cc1

  disp( [' size cc=' num2str(size(cc1))]);
  
  max_bsx=max(bsx);     % highest x value
  nx=size(bsx,1);        % number of rows
  x=(-nx+1):(nx-1);      % center zero, create same number of elements as cc will have
  x=(max_bsx/nx)*x;      % create a symmetric x axis centered around zero
  disp(['cross correlation axis=' num2str(min(x)) ' to ' num2str(max(x)) ]);
  
  %subplot(4,1,4);plot(x,cc1, 'b-', x,cc2,'r--')
  subplot(4,1,4);plot(x,cc1, 'b-')
  
  xlabel('time offset (s)');
  ylabel('Correlation');
  title('Cross correlation','FontSize',12);
  
  % Determine position of maximum cross correlation
  
  i = find(cc1==max(cc1));
  disp([ 'maximum cross correlation at index=' num2str(i) '   time=' num2str(x(i)) ]);
 
  
  % End
  
 disp('END input_flow_files')
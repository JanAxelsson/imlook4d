
Menu('Export filtered')


%
% Get file, and type of export
%
[file,path] = uiputfile({ ... 
    '*.mp4' ,'Save as .mp4 movie';...
    '*.avi' ,'Save as .avi movie' }, ...
    'Save Movie (Select type)', 'imlook4d_movie' );


[pathstr,name,ext] = fileparts(file);  % To get extension 
switch ext 
    case '.avi' % imlook4d TS xls
        format = 'Motion JPEG AVI';

    case '.mp4' % imlook4d TS xls
        format = 'MPEG-4';

    otherwise
        warning('Unexpected file type. No file created.')
end

%
% Get Matrix
%

if FRAME
    numberOfFrames = size( imlook4d_Cdata,4);  % Loop frames
    tempMatrix = imlook4d_Cdata(:,:,imlook4d_slice,:);
else
    
    numberOfFrames = size( imlook4d_Cdata,3);  % Loop slices
    tempMatrix = imlook4d_Cdata(:,:,:,imlook4d_frame);
end

maxValue = max( tempMatrix(:));


%
% Write video file
%
v = VideoWriter([path filesep file], format);
v.FrameRate = numberOfFrames / 3;  % Make a 3 second movie

open(v)

% Axes only
rect = get(imlook4d_current_handles.axes1,'Position');
xmaxRect = rect(1) + rect(3);

% % Add offset for colorbar width
% cbrect = get(imlook4d_current_handles.uipanel7,'Position');
% xmaxCbrect = cbrect(1);
% 
% XOffset = xmaxCbrect - xmaxRect;



% Loop and plot
for k = 1:numberOfFrames
    if FRAME
        EditField('FrameNumEdit', num2str(k));  % Move to next frame
    else
        EditField('SliceNumEdit', num2str(k));  % Move to next slice
    end
   writeVideo(v, getframe(imlook4d_current_handle, rect ) );

   %writeVideo(v, getframe(imlook4d_current_handle, rect + [0 -20 XOffset +40] )  );
end

close(v)



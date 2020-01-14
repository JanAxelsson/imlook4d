function outputImage=water( handles, matrix,outputFrameRange)

tic

        Cinp = reshape( handles.model.Water.Cinp, 1, []); 
        a = jjwater( matrix, ...
            handles.image.time/60, ...
            handles.image.duration/60, ...
            Cinp...
            );
        outputImage(:,:,1,1) = a.pars{1}; % Flow

toc


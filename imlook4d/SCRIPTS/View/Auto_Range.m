% Auto_Range.m
%
% SCRIPT for setting display range at 5 times global stdev (kind of like
% Rose's criterium)
%
% High limit is set to maximum in current image
% Low limit is set to 5 times global standard deviation of frame
%
% Jan Axelsson
% 2012-06-08

%
% INITIALIZE
%

    StoreVariables
    Export

    ROSE=5;  % Rose criterion on how to safely find image information (5 times the SNR)

%
% ACTION
%
    
    currentImage=imlook4d_Cdata(:,:,imlook4d_slice,imlook4d_frame);
    currentFrame=imlook4d_Cdata(:,:,:,imlook4d_frame);
    currentVector=currentFrame(:);
    
    lowLimit= std(currentVector)*ROSE;
    
    
   %indeces=find( (0<currentVector)&(currentVector<lowLimit) );  % Second iteration: stdev of suspected noise pixels (below our current limit)
   %lowLimit=num2str( std( currentVector(indeces)));

    lowLimitString=num2str( lowLimit);
    highLimitString=num2str( max( currentImage(:) ) );
    
    imlook4d('EditScale_Callback', imlook4d_current_handles.EditScale,{} ,imlook4d_current_handles, { lowLimitString highLimitString })

%
% FINALIZE
%
    Import
    ClearVariables

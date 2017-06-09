% BP_Turkudata.m
% For a particular Raclopride experiment
% Jan Axelsson 2011-10-10

%
% Initialize
%
    StartScript

    RangeA=16:21;
    RangeB=22:27;
    RefROI=7;

%
% Calculate BP and dBP
%

    % TACT
    [activity1, NPixels1, stdev1]=generateTACT(imlook4d_current_handles, imlook4d_ROI);

    % PET1
    CA=mean(imlook4d_Cdata(:,:,:,RangeA),4);
    Cref=mean(activity1(RefROI,RangeA));
    BP_A=(CA-Cref)/Cref;

    % PET2
    CB=mean(imlook4d_Cdata(:,:,:,RangeB),4);
    Cref=mean(activity1(RefROI,RangeB));
    BP_B=(CB-Cref)/Cref;
    
    % Mult med 1000
    BP_A=1000*BP_A;
    BP_B=1000*BP_B;
    
    
    % Diff
    dBP=BP_A-BP_B;



%
% Make images
%
    % PET1
    imlook4d_Cdata=BP_A;
    historyDescriptor='(BP_A) ';
    Title
    Import

    % PET2
    DuplicateOriginal;
    imlook4d_Cdata=BP_B;
    historyDescriptor='(BP_B) ';
    Title
    Import

    % dBP
    DuplicateOriginal;
    imlook4d_Cdata=dBP;
    historyDescriptor='(dBP) ';
    Title
    Import
 
    % std A
    DuplicateOriginal;
    imlook4d_Cdata=std(imlook4d_Cdata(:,:,:,RangeA),0,4);
    historyDescriptor='(stdev A) ';
    Title
    Import
    
    
    % std B
    DuplicateOriginal;
    imlook4d_Cdata=std(imlook4d_Cdata(:,:,:,RangeB),0,4);
    historyDescriptor='(stdev B) ';
    Import
    

%
% Finalize
%
    EndScript

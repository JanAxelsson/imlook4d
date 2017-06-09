% BP_Turkudata.m
% For a particular Raclopride experiment
% Jan Axelsson 2011-10-10

%
% Initialize
%
    StartScript

    RangeA=13:17,21;
    RangeB=18:20;

%
% Calculate BP and dBP
%

    % TACT
    [activity1, NPixels1, stdev1]=generateTACT(imlook4d_current_handles, imlook4d_ROI);

    % PET1
    C=mean(imlook4d_Cdata(:,:,:,RangeA),4);
    Cref=mean(activity1(1,RangeA));
    BP_A=(C-Cref)/Cref;

    % PET2
    C=mean(imlook4d_Cdata(:,:,:,RangeB),4);
    Cref=mean(activity1(1,RangeB));
    BP_B=(C-Cref)/Cref;

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
    Import

%
% Finalize
%
    EndScript

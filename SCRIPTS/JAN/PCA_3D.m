

%
% Initialize
%

    %StoreVariables
    %ExportUntouched
    StartScript

    firstComponent=1;

    % Input last component
    answer = inputdlg('Last principal component to keep:')
    lastComponent=str2num(answer{1});


    rows=size( imlook4d_Cdata,1);
    columns=size( imlook4d_Cdata,2);
    slices=size( imlook4d_Cdata,3);
    frames=size( imlook4d_Cdata,4);

%
% Transform volume to single slice
%
    Data=reshape( imlook4d_Cdata, [rows columns*slices 1 frames]);      % Full volume, not single slices

%
%  PCA filter
%

    [averageMatrix, stdevMatrix, Data]=standardizeSlices(Data);                        % scale data prior to PCA
    [fullEigenValues, fullEigenVectors, PCMatrix]=fullPCA(Data);                       % perform fullPCA
    
    [Data, explainedFraction]= quickInverseFullPCA(fullEigenValues, fullEigenVectors, PCMatrix, firstComponent, lastComponent);  % perform inverseFullPCA
    Data=unStandardizeSlices(averageMatrix, stdevMatrix, Data);                       % scale back data post inverse PCA
    
%
% Transform single-slice to volume
%
    PCMatrix=reshape(PCMatrix, [rows columns slices frames]);
    Data=reshape(Data, [rows columns slices frames]);


%
% Display
%
%     imlook4d(PCMatrix);
%     WindowTitle('PC images (Volume PCA)', 'prepend')
    %DuplicateOriginal
    imlook4d_Cdata=PCMatrix;
    Import
    WindowTitle('PC images (Volume PCA)', 'prepend')

%     imlook4d(Data);
%     WindowTitle('Filtered images (Volume PCA)', 'prepend')
        DuplicateOriginal
    imlook4d_Cdata=Data;
    Import
    WindowTitle('Filtered images (Volume PCA)', 'prepend')

%     imlook4d(Data-imlook4d_Cdata);
%     WindowTitle('Diff images [Volume PCA]-[Original]', 'prepend')
            DuplicateOriginal
    imlook4d_Cdata=Data-imlook4d_Cdata;
    Import
    WindowTitle('Diff images [Volume PCA]-[Original]', 'prepend')
    
%
% Finish
%
    ClearVariables
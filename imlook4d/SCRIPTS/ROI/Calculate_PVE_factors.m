pveFactors = [];
StoreVariables;
ExportUntouched;

sigma_pixels = [ 5 5  5];

measTACT = tactFromMatrix(imlook4d_Cdata,imlook4d_ROI)';
pveFactors = pveWeights( imlook4d_ROI, sigma_pixels);

ClearVariables;

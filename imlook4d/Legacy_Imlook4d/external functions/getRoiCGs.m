function A = getRoiCGs( ROI_matrix)

% Coordinates center of mass from ROIs
numberOfROIs = max(ROI_matrix(:));
for i = 1:numberOfROIs
            M=ROI_matrix;
            TotalMass=sum(M(:)==i);

            X=1:size(M,1); 
            SumX=sum( sum(M==i,3),2);  % creating a sum vector: sum Z values, then rows
            CG_X= sum(SumX(:).*X(:))/TotalMass;

            Y=1:size(M,2); %
            SumY=sum( sum(M==i,3),1); % creating a sum vector: sum Z values, then columns
            CG_Y= sum(SumY(:).*Y(:))/TotalMass;

            Z=1:size(M,3);
            SumZ=sum( sum(M==i,1),2); % creating a sum vector: sum columns, then rows
            CG_Z= sum(SumZ(:).*Z(:))/TotalMass;
            
            A(i,:) = [ CG_X, CG_Y, CG_Z ];
end
    
    
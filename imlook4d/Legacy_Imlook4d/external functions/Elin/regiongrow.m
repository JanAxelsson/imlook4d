function total_roi=regiongrow(I,T,x1,y1,z1)

Isizes = size(I); % Dimensions of input image
J = zeros(Isizes(1), Isizes(2)); % Output 

reg_size = 1; % Number of pixels in region

% Free memory to store neighbours of the (segmented) region
neg_free = 10000; neg_pos=0;
neg_list = zeros(neg_free,3); 

max_value =I(x1,y1,z1); 
reg_mean=I(x1,y1,z1); 
x=x1;
y=y1;
z=z1;

% Neighbor locations (footprint)
neigb=[0 0; -1 0; 1 0; 0 -1;0 1];

sum_current_roi=2;
total_roi=zeros(Isizes);
z_var=z;
z_dir='pos';

while sum_current_roi>1
    current_I=I(:, :, z_var);
    
    % Start regiogrowing until distance between regio and posible new pixels become
    % higher than a certain treshold
    while(max_value>T)

        % Add new neighbors pixels
        for j=1:5,
            % Calculate the neighbour coordinate
            xn = x +neigb(j,1); yn = y +neigb(j,2);

            % Check if neighbour is inside or outside the image
            ins=(xn>=1)&&(yn>=1)&&(xn<=Isizes(1))&&(yn<=Isizes(2));

            % Add neighbor if inside and not already part of the segmented area
            if(ins&&(J(xn,yn)==0)) 
                    neg_pos = neg_pos+1;
                    neg_list(neg_pos,:) = [xn yn current_I(xn,yn)];
                    J(xn,yn)=1;
            end
        end

        % Add a new block of free memory
        if(neg_pos+10>neg_free), neg_free=neg_free+10000; neg_list((neg_pos+1):neg_free,:)=0; end

        % Add pixel with intensity nearest to the mean of the region, to the region
        % OM STÖRRE ÄN T!!!
        dist = neg_list(1:neg_pos,3);
        [max_value, index] = max(dist); 
        if current_I(x, y)>=T
            J(x,y)=2; 
        end
        reg_size=reg_size+1;
        
        % Calculate the new mean of the region
        reg_mean= (reg_mean*reg_size + neg_list(index,3))/(reg_size+1);

        % Save the x and y coordinates of the pixel (for the neighbour add proccess)
        x = neg_list(index,1); y = neg_list(index,2);

        % Remove the pixel from the neighbour (check) list
        neg_list(index,:)=neg_list(neg_pos,:); neg_pos=neg_pos-1;
    end
    
    % Return the segmented area as logical matrix
    J=J>1;
    
    total_roi(:, :, z_var)=J;
    sum_current_roi=sum(J(:));
    
    if sum_current_roi<=1 && strcmp(z_dir,'pos');
        z_dir='neg';
        sum_current_roi=2;
        z_var=z-1;
    elseif strcmp(z_dir,'neg')
        z_var=z_var-1;
    elseif strcmp(z_dir,'pos')
        z_var=z_var+1;
    end
    max_value =I(x1,y1,z1);
    J=zeros(Isizes(1), Isizes(2));
    clear dist;
    x=x1;
    y=y1;
    z=z1;
    
end

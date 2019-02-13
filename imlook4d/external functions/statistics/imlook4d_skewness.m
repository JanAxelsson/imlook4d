function skew_out = imlook4d_skewness(x)
% See https://www.itl.nist.gov/div898/handbook/eda/section3/eda35b.htm


N = size(x,1)
frames = size(x,2);

for j = 1:frames
    skew = 0;
    avg = mean(x(:,j));
    s = std( x(:,j) ) * sqrt( (N-1) / N); % Stdev calculated with N instead of N-1,
    
    for i = 1 : N
        skew = skew + ( x(i,j) - avg )^3 / N ;
    end
    
    skew = skew / s^3;
    
    skew_out(j) = skew;
    
end
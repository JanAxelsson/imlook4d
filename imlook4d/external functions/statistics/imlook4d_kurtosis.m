function kurt_out = imlook4d_kurtosis(x)
% See https://www.itl.nist.gov/div898/handbook/eda/section3/eda35b.htm

N = size(x,1)
frames = size(x,2);

for j = 1:frames
    kurt = 0;
    avg = mean(x(:,j));
    s = std( x(:,j) ) * sqrt( (N-1) / N); % Stdev calculated with N instead of N-1,
    
    for i = 1 : N
        kurt = kurt + ( x(i,j) - avg )^4 / N ;
    end
    
    kurt = kurt / s^4; 
    
    kurt_out(j) = kurt;
    
end
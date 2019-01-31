function kurt = imlook4d_kurtosis(x)
% See https://www.itl.nist.gov/div898/handbook/eda/section3/eda35b.htm

x = x(:);

N = length(x);

kurt = 0;
avg = mean(x);
s = std(x) * sqrt( (N-1) / N); % Stdev calculated with N instead of N-1,

for i = 1 : N
    kurt = kurt + ( x(i) - avg )^4 / N ;
end

kurt = kurt / s^4; 
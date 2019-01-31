function skew = imlook4d_skewness(x)
% See https://www.itl.nist.gov/div898/handbook/eda/section3/eda35b.htm

x = x(:);

N = length(x);

skew = 0;
avg = mean(x);
s = std(x) * sqrt( (N-1) / N); % Stdev calculated with N instead of N-1,

for i = 1 : N
    skew = skew + ( x(i) - avg )^3 / N ;
end

skew = skew / s^3; 
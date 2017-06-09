function [ R2 ] = R2_linefit( X, Y, intercept, slope )
% R2_linefit gives the R2 calculated in Y-direction
%   Inputs:
%   X   vector of X data points
%   Y   vector of Y data points
%   intercept   m in equation y=kx+m
%   slope       k in equation y=kx+m


yfit =  slope * X + intercept;
yresid = Y - yfit;
SSresid = sum(yresid.^2);
SStotal = (length(Y)-1) * var(Y);

R2 = 1 - SSresid/SStotal;
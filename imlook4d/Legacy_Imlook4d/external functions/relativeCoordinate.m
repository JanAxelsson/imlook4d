function Xr=relativeCoordinate(X1, X2, Xabs)
% Calculates the relative coordinate from absolute coordinate and boundaries
%
% X1    low boundary position (relative coordinate 0)
% X2    high boundary position (relative coordinate 1)
% Xabs  absolute position, between, X1<=Xabs<=X2
% Xr    relative position of Xabs, 0<=Xr<=1

Xr=(Xabs-X1)/(X2-X1);
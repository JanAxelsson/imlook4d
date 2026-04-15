function Xabs=absoluteCoordinate(X1, X2, Xr)
% Calculates the absolute coordinate from relative value and boundaries
% 
% X1    low boundary position (relative coordinate 0)
% X2    high boundary position (relative coordinate 1)
% Xabs  absolute position, between, X1<=Xabs<=X2
% Xr    relative position of Xabs, 0<=Xr<=1
Xabs=X1+Xr*(X2-X1);
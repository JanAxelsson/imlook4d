function tab=Hot(n)

% Default N:=255;
if nargin == 0
    n=255;
end

% RGB färgtabellen. En rad per pixel i PIX.
tab=hot(n);

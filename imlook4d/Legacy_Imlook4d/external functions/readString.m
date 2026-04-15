function outString=readString( inString)
   [token, remain]=strtok(inString, '[');
   [token, remain]=strtok(remain, ']');
   outString=token(2:end);
   %outString=inString;
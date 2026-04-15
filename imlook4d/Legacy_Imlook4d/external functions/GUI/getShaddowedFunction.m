function shipped = getShaddowedFunction( name)

  this = [ name '.m']; % the name of function in MATLAB we are shadowing

  % Call default function
  list = which(this, '-all'); % find all the functions which shadow it
  
  % Find shaddowed function
  for i=1:length(list)
      test = findstr( list{i}, 'external functions\GUI' );
      if isempty(test)
          p = list{i};
          old_folder = cd( p(1:end-length(this)) ); % temporarily switch to the containing folder
          shipped = str2func(this(1:end-2)); % grab a handle to the function
          cd(old_folder); % go back to where we came from
      end
  end
%   
%   
%   f = strncmp(list, matlabroot, length(matlabroot)); % locate 1st in list under matlabroot
%   list = list{find(f, 1)}; % extract from list the exact function we want to be able to call
%   here = cd(list(1:end-length(this))); % temporarily switch to the containing folder
%   shipped = str2func(this(1:end-2)); % grab a handle to the function
%   cd(here); % go back to where we came from

  
  
  
  


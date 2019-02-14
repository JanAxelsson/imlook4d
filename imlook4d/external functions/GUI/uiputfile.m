function [file,path, filterindex] = uiputfile(varargin)
  % Shaddowing the default matlab function
  % Alt 1) Calls default matlab function
  % Alt 2) If Workspace has a cell array INPUTS, then the arguments of 
  %        workspace variable INPUTS are used instead.
  %
  % Inputs alt 1):
  %     Same inputs as uiputfile takes
  %
  % Inputs alt 2):
  %     INPUTS = { filepath }  % Workspace variable being read giving full file path
  %                            % for example:
  %                            % INPUTS = {'E:\Ume� work\D03\jan_test4.nii'};
  %
  % Output:
  %     file 
  %     path

  this = 'uiputfile'; % the name of function in MATLAB we are shadowing   
  disp([ 'imlook4d function overriding matlab''s default ' this ' function' ])
  
  % Try to get input from workspace INPUTS variable
      try
          % Try to get input from workspace INPUTS variable
          INPUTS=getINPUTS();
          [pathstr,name,ext] = fileparts(INPUTS{1});
          file = [name ext];
          path = [pathstr filesep];
          evalin('base','clear INPUTS');
      catch
          % Call default function instead
          shipped = getShaddowedFunction(this);
          [file,path, filterindex] = shipped(varargin{:});
          INPUTS = {[ path file ]};
          recordInputsText(INPUTS);  % Insert text at caret

      end
  
  
  


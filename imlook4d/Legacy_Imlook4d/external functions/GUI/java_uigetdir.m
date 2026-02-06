function outputPath=java_uigetdir(guessedDirectory, dialogTitle, save);
    % Inputs:
    % guessedDirectory - default
    % dialogTitle - title 
    % (Optional) save - true if save dialog, false if open dialog.  Save default if this parameter is missing
    % Fallback
    import javax.swing.*
    
    if ~exist('save','var')
        save = true;
    end
    
    % Matlab bug fix
    pause(0.1); % Any previous inputdlg seems to need some time, otherwise the java code used in java_uigetdir freezes


  this = 'java_uigetdir'; % the name of function 
  disp([ 'imlook4d function ' this ' ' ])

  
  % Try to get input from workspace INPUTS variable
      try
          % Try to get input from workspace INPUTS variable
          INPUTS=getINPUTS();
          outputPath=INPUTS{1};
          evalin('base','clear INPUTS');
          
          
          
      catch
            % Code
            f = JFrame('My Title');
            f.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

            fc = JFileChooser();
            fc.setDialogTitle(dialogTitle);
            fc.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);

            fc.setCurrentDirectory(java.io.File(guessedDirectory));

            if save
                out=fc.showSaveDialog( f );
            else
                out=fc.showOpenDialog( f );
            end
            
            if out == 0
                outputPath=char(fc.getSelectedFile().toString());
            else
                outputPath = 0;  % Same behaviour as uigetdir
            end
            
            INPUTS = { outputPath };
            recordInputsText(INPUTS);  % Insert text at caret
         
      end
      
      



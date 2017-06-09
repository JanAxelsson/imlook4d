function outputPath=java_uigetdir(guessedDirectory, dialogTitle);
    % Fallback
    import javax.swing.*
    
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

            out=fc.showSaveDialog( f );

            outputPath=char(fc.getSelectedFile().toString());
            
            INPUTS = { outputPath };
            recordInputsText(INPUTS);  % Insert text at caret
         
      end
      
      



       function [outFilesArray outDirsArray]=listDirectory(dirPath)
            % List a directory same way with mac and windows
            %
            % Input:  directory path
            % Output: cell array, containing file names
            
            outFilesArray={};
            outDirsArray={};
            
            list=dir(dirPath);  % Returns an array of struct
            fileCounter=0;
            dirCounter=0;

            for i=1:size(list,1)% Loop all things in directory
               if list(i).isdir
                  % A directory
                  dirCounter=dirCounter+1;
                  outDirsArray{dirCounter,1}=list(i).name;

               else
                  % A file
                  fileCounter=fileCounter+1;
                  outFilesArray{fileCounter,1}=list(i).name;

               end
            end
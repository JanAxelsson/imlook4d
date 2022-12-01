  function  output_txt = dataCursorUpdateFunction(~,event_obj)     
        % ~            Currently not used (empty)
        % event_obj    Object containing event data structure
        % output_txt   Data cursor text (string or cell array 
        %              of strings)

        
        pos = get(event_obj,'Position');
        handles = guidata(gcf);
        
        EOL = sprintf('\n');
                
                
        x = round( pos(1) +0.5);
        y = round( pos(2) +0.5);
        z = round(get(handles.SliceNumSlider,'Value'));
        t = round(get(handles.FrameNumSlider,'Value'));
        
        % Exchange x and y if image in original orientation (not FlipAndRotate)
        if ~get(handles.FlipAndRotateRadioButton,'Value')
            temp=x;   x=y; y=temp;
        end

        %

        % ROI   
        try
            
            roi = handles.image.ROI(x,y,z);
            roiNames=get(handles.ROINumberMenu,'String'); % Cell array

        catch
        end

        % Value
        try 
            %value = handles.image.Cdata(x,y,z,t);
            
            valuesInROI =  handles.image.Cdata( handles.image.ROI == roi);
            avg = mean( valuesInROI(:) );
            highest = max( valuesInROI(:) );
            lowest = min( valuesInROI(:) );
            
            % Fast Calculate pixel value (use generateImage, thus gettting models, PCA-filter etc)
            handles.image.Cdata = handles.image.Cdata(x,y,z,:);  % Call using [1,1,1,:] matrix for this pixel only
            [tempData, explainedFraction, fullEigenValues]=imlook4d('generateImage',handles, 1, t);
            value = tempData;
            
            
            output_txt = {  ...
                ['Pixel value: ',num2str( value,'%10.5g\n') ], ...
                };    
            
            
            output_txt = { output_txt{:}, EOL};        
            output_txt = { output_txt{:}, ['X=',num2str(x) '  Y=',num2str(y)  '  Z=',num2str(z) ]};
        
            
            % Only if ROI exists
            if (roi > 0 )

                output_txt = { output_txt{:}, EOL, '------------------------', EOL};


                output_txt = { output_txt{:}, ...  
                    ['ROI = "' roiNames{roi} ] ...
                };

                output_txt = { output_txt{:}, EOL}; 

                output_txt = { output_txt{:}, ...
                    ['Mean : ', num2str(avg) ], ...
                    };  

                output_txt = { output_txt{:}, EOL};

                output_txt = { output_txt{:}, ...
                    ['Max : ', num2str(highest) ], ...
                    };  

                output_txt = { output_txt{:}, ...
                    ['Min : ', num2str(lowest) ], ...
                    };      
            end
            
            
            
            % If background image exists
            try
                h2 = handles.image.backgroundImageHandle;
                handles2 = guidata(h2);
                frame2 = round(get(handles2.FrameNumSlider,'Value'));
                value_bck = handles2.image.Cdata(x,y,z,frame2);
                
                output_txt = { output_txt{:}, EOL, '------------------------'};
                output_txt = { output_txt{:}, ...
                    ['Foreground: ',num2str( value,'%10.5g\n') ], ...
                    ['Background: ',num2str( value_bck,'%10.5g\n') ], ...
                    };
            catch
            end
            


            
        catch
            value = handles.image.Cdata(x,y,z,t);
            output_txt = { output_txt{:}, ...
                ['Value: ',num2str( value,'%10.5g\n') ], ...
                };          
        end
        
        
        
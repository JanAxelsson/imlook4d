  function  output_txt = dataCursorUpdateFunction(~,event_obj)     
        % ~            Currently not used (empty)
        % event_obj    Object containing event data structure
        % output_txt   Data cursor text (string or cell array 
        %              of strings)

        
        pos = get(event_obj,'Position');
        handles = guidata(gcf);
                
                
        x = round( pos(1) +0.5);
        y = round( pos(2) +0.5);
        z = round(get(handles.SliceNumSlider,'Value'));
        t = round(get(handles.FrameNumSlider,'Value'));
        
        output_txt = {['X=',num2str(x) '  Y=',num2str(y)  '  Z=',num2str(z) ]};

        % ROI   
        try
            
            roi = handles.image.ROI(x,y,z);
            
            % output_txt = { output_txt{:}, ...
            
            % ['ROI: ',num2str(roi) ] ...
            
            % };
            
            roiNames=get(handles.ROINumberMenu,'String'); % Cell array
            
            output_txt = { output_txt{:}, ...
                
            ['ROI= "' roiNames{roi} '" (' num2str(roi) ')'] ...
            
            };
        
        catch
        end

        % Value
        try 
            value = handles.image.Cdata(x,y,z,t);
            
            % If background image exists
            h2 = handles.image.backgroundImageHandle;
            handles2 = guidata(h2);
            frame2 = round(get(handles2.FrameNumSlider,'Value'));
            value_bck = handles2.image.Cdata(x,y,z,frame2);
            
%             output_txt = { output_txt{:}, ...
%                 ['Foreground: ',num2str( value,4) ], ...
%                 ['Background: ',num2str( value_bck,4) ], ...
%                 };
            
             
            output_txt = { output_txt{:}, ...
                ['Foreground: ',num2str( value,'%10.5g\n') ], ...
                ['Background: ',num2str( value_bck,'%10.5g\n') ], ...
                };

            
        catch
            value = handles.image.Cdata(x,y,z,t);
            output_txt = { output_txt{:}, ...
                ['Value: ',num2str( value,'%10.5g\n') ], ...
                };          
        end
        
        
        
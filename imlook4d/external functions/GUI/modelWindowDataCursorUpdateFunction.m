  function  output_txt = modelWindowDataCursorUpdateFunction(~,event_obj)     
        % ~            Currently not used (empty)
        % event_obj    Object containing event data structure
        % output_txt   Data cursor text (string or cell array 
        %              of strings)

        
        pos = get(event_obj,'Position')          
        x = pos(1);
        y = pos(2);

        frame = find( abs(event_obj.Target.XData -x) < 1e-6);
        
        %output_txt = {['X=',num2str(x) '\n  Y=',num2str(y)  '   frame =' num2str(frame) ]};
        output_txt = sprintf(['X=',num2str(x) '\nY=',num2str(y)  '\nframe =' num2str(frame) ]);




 return

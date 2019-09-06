%
% Remove  hidden rois
%
    function [roinames1, datastruct1] = removeHiddenRoisFromStruct( roinames, datastruct)
        keepIndex = [];
        counter = 0;
        for roi = 1 : length(roinames)
            if not( contains( roinames{roi},'(hidden)' ) )
                counter = counter + 1;
                keepIndex(counter) = roi;
            end
        end
        
        % Keep
        
        datastruct1 = datastruct; % Start with copy of datastruct, then replace
        % Zero new struct for fields I will modify
        datastruct1.X=[];
        datastruct1.Y=[];
        datastruct1.Xmodel=[];
        datastruct1.Ymodel=[];
        datastruct1.residual=[];
        for i = 1 : length(keepIndex)
            try roinames1{i,1} = roinames{ keepIndex(i) }; catch end
            try datastruct1.X{1,i} = datastruct.X{ keepIndex(i) } ; catch end
            try datastruct1.Y{1,i} = datastruct.Y{ keepIndex(i) } ; catch end
            try datastruct1.Xmodel{1,i} = datastruct.Xmodel{ keepIndex(i) } ; catch end
            try datastruct1.Ymodel{1,i} = datastruct.Ymodel{ keepIndex(i) } ; catch end
            try datastruct1.residual{1,i} = datastruct.residual{ keepIndex(i) } ; catch end
        end
        
        % Remove rois for each parameter value 
        try
            for i = 1 : length( datastruct.pars)
                datastruct1.pars{i} = datastruct.pars{i}(keepIndex);
            end
        catch
        end
        
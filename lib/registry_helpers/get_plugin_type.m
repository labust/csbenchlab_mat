function [t, mcls] = get_plugin_type(class_name)
    t = 0;
    mcls = [];
    if exist(class_name, 'class')
        mcls = meta.class.fromName(class_name);
        if mcls.Abstract
            return
        end
        
        for k=1:length(mcls.SuperclassList)
            if strcmp(mcls.SuperclassList(k).Name, 'DynSystem')
                t = 1; 
                break;
            end
            if strcmp(mcls.SuperclassList(k).Name, 'Controller')
                t = 2;
                break;
            end
            if strcmp(mcls.SuperclassList(k).Name, 'Estimator')
                t = 3;
                break;
            end
            if strcmp(mcls.SuperclassList(k).Name, 'DisturbanceGenerator')
                t = 4;
                break;
            end
        end
    end
end


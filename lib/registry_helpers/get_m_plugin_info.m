function info = get_m_plugin_info(class_name)
    info = struct;
    info.T = 0;
    info.Name = class_name;
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
        
        props = arrayfun(@(x) strcmp(x.Name, 'param_description'), mcls.PropertyList);
        value = mcls.PropertyList(props);
        info.HasParameters = ~isempty(value); 
        info.T = t;
        
        info.Mcls = mcls;
    end
end


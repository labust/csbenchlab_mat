function p = get_plugin_info(component_path)

    splits = split(component_path, ':');
    component_path = splits{1};
    if length(splits) > 1
        rel_path = splits{2};
    end

    if startsWith(component_path, '.')
        component_path = fullfile(pwd, component_path);
    end
    

    [folder, name, ext] = fileparts(component_path);
    
    rm = 0;
    if strcmp(ext, '.m')
        try
            w_n = which(name);
            if ~strcmp(w_n, component_path)
                addpath(folder);
                rm = 1;
            end
            p = get_m_plugin_info(name);
            p.Type = "m";
        catch e
            if rm > 0
                rmpath(folder);
            end
            rethrow(e);
        end
    elseif strcmp(ext, '.slx')
        try
            w_n = which(name);

            if ~strcmp(w_n, component_path)
                addpath(folder);
                rm = 1;
            end
            p = get_slx_plugin_info(name, rel_path);
            p.Type = "slx";
        catch e
            if rm > 0
                rmpath(folder);
            end
            rethrow(e);
        end
    else
        p = struct;
        p.Type = 0;
    end

end

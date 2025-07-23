function p = get_plugin_info_from_file(component_path)

   
    [folder, name, ~] = fileparts(component_path);
    typ = ComponentRegister.get_plugin_type_from_file(component_path);
    r = ComponentRegister.get(typ);

    rm = 0;
    try
        w_n = which(name);
        % temporary add folder to path 
        if ~strcmp(w_n, component_path)
            addpath(folder);
            rm = 1;
        end
        p = r.get_plugin_info(name, component_path);
        p.Type = typ;
    catch e
        if rm > 0
            rmpath(folder);
        end
        rethrow(e);
    end
    p.ComponentPath = component_path;
end

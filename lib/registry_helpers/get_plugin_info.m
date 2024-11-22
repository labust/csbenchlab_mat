
function p = get_plugin_info(component_path)
    
    [~, name, ext] = fileparts(component_path);
    
    if strcmp(ext, '.m')
        p = get_m_plugin_info(name);
        p.Type = "m";
    else
        p = struct;
        p.Type = 0;
    end

end
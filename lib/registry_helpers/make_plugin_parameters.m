function params = make_plugin_parameters(plugin_type, plugin_name, lib)

    manifest = load_lib_manifest(lib);
    if plugin_type == 1
        comp = find_component(manifest.registry.sys, plugin_name);
    elseif plugin_type == 2
        comp = find_component(manifest.registry.ctl, plugin_name);
    elseif plugin_type == 3
        comp = find_component(manifest.registry.est, plugin_name);
    elseif plugin_type == 4
        comp = find_component(manifest.registry.dist, plugin_name);
    end
    
    params = [];
    if strcmp(comp.Type, "m")
        params = make_m_component_params(comp.Name);
    elseif strcmp(comp.Type, 'slx')
        params = make_slx_component_params(comp.Name, comp.T, lib);
    end

end


function s = find_component(comp_cell, name)
    for i=1:length(comp_cell)
        if strcmp(comp_cell{i}.Name, name)
            s = comp_cell{i};
            return
        end
    end
    s = [];
end


function p = detect_component(component_path)
    
    [~, name, ~] = fileparts(component_path);
    p = struct;

    [t, mcls] = get_plugin_type(name);
    p.t = t;
    if t == 0
        return
    end
    prop = arrayfun(@(x) strcmp(x.Name, 'registry_info'), mcls.PropertyList);
    p.info = mcls.PropertyList(prop).DefaultValue;
    p.mcls = mcls;

end
function unregister_component(comp_name, lib_name)
    ComponentRegister.unregister(comp_name, lib_name);
    remove_from_plugin_json(comp_name, lib_name);
end


function remove_from_plugin_json(comp_name, lib_name)

    path = get_library_path(lib_name);
    json_path = fullfile(path, 'plugins.json');
    s = readstruct(json_path);

    if isempty(s.plugins) 
        return
    end
    idx = strcmp([s.plugins.name], comp_name);
    s.plugins(idx) = [];
    writestruct(s, json_path);
end


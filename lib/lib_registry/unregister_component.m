function unregister_component(comp_name, lib_name)
    info = ComponentRegister.unregister(comp_name, lib_name);
    remove_from_lib_manifest(comp_name, info.T, lib_name);
    remove_from_plugin_json(comp_name, lib_name);
end


function remove_from_plugin_json(comp_name, lib_name)

    path = get_library_path(lib_name);
    json_path = fullfile(path, 'plugins.json');
    s = readstruct(json_path);

    if isempty(s.Plugins) 
        return
    end
    idx = strcmp([s.Plugins.Name], comp_name);
    s.Plugins(idx) = [];
    writestruct(s, json_path);
end


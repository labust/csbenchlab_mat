function add_to_lib_manifest(p, t, lib_name)
    lib_path = fullfile(CSPath.get_app_registry_path(), lib_name);
    load(fullfile(lib_path, 'autogen', 'manifest.mat'), 'registry');
    
    if t == 1
        registry.sys{end+1} = p;
    elseif t == 2
        registry.ctl{end+1} = p;
    elseif t == 3
        registry.est{end+1} = p;
    elseif t == 4
        registry.dist{end+1} = p;
    end
    save(fullfile(lib_path, 'autogen', 'manifest.mat'), 'registry');
    
end


function add_to_lib_manifest(p, t, lib_name)
    lib_path = fullfile(CSPath.get_app_registry_path(), lib_name);

    manifest = load_lib_manifest(lib_path);
    
    if t == 1
        manifest.registry.sys{end+1} = p;
    elseif t == 2
        manifest.registry.ctl{end+1} = p;
    elseif t == 3
        manifest.registry.est{end+1} = p;
    elseif t == 4
        manifest.registry.dist{end+1} = p;
    end
    writestruct(manifest, fullfile(lib_path, 'autogen', 'manifest.json'));
    
end


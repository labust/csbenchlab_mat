function remove_from_lib_manifest(name, t, lib_name)

    lib_path = fullfile(CSPath.get_app_registry_path(), lib_name);
    
    manifest = load_lib_manifest(lib_path);
    
    if t == 1
        manifest.registry.sys = remove_from_struct(manifest.registry.sys, name);
    elseif t == 2
        manifest.registry.ctl = remove_from_struct(manifest.registry.ctl, name);
    elseif t == 3
        manifest.registry.est = remove_from_struct(manifest.registry.est, name);
    elseif t == 4
        manifest.registry.dist = remove_from_struct(manifest.registry.dist, name);
    end

    writestruct(manifest, fullfile(lib_path, 'autogen', 'manifest.json'));
end



function cell = remove_from_struct(cell, name)
    indices = cellfun(@(x) ~strcmp(name, x.Name), cell);
    cell = cell(indices);
end
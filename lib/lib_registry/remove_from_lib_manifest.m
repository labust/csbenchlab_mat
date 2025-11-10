function remove_from_lib_manifest(name, t, lib_name)

    lib_path = fullfile(CSPath.get_app_registry_path(), lib_name);
    
    manifest = load_lib_manifest(lib_path);
    
    manifest.Registry.(t) = remove_from_struct(manifest.Registry.(t), name);
    writestruct(manifest, fullfile(lib_path, 'autogen', 'manifest.json'));
end



function cell = remove_from_struct(cell, name)
    indices = cellfun(@(x) ~strcmp(name, x.Name), cell);
    cell = cell(indices);
end
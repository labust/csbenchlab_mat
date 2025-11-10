function add_to_lib_manifest(p, t, lib_name)
    lib_path = get_library_path(lib_name);

    manifest = load_lib_manifest(lib_path);

    idx = cellfun(@(x) strcmp(x.Name, p.Name), manifest.Registry.(t));
    if any(idx)
        manifest.Registry.(t){idx} = p;
    else
        manifest.Registry.(t){end+1} = p;
    end
    writestruct(manifest, fullfile(lib_path, 'autogen', 'manifest.json'));
    
end


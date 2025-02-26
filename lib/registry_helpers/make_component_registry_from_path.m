function registry = make_component_registry_from_path(lib_paths, save_manifest_library)

    if ~exist('save_manifest_library', 'var')
        save_manifest_library = '';
    end
    registry.ctl = {};
    registry.sys = {};
    registry.est = {};
    registry.dist = {};
    for i = 1:length(lib_paths)
        registry = detect_components_from_path(lib_paths{i}, registry);
    end

    if ~strempty(save_manifest_library)
        path = get_app_root_path();
        version = '0.1';
        library = save_manifest_library;
        save(fullfile(path, 'registry', save_manifest_library, 'manifest.mat'), "registry", 'version', 'library');
    end
end


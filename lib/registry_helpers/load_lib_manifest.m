function manifest = load_lib_manifest(lib)
    path = fullfile(get_app_registry_path(), lib, 'manifest.mat');
    manifest = load(path);

end

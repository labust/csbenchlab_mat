function manifest = load_lib_manifest(lib)

    if isfolder(fullfile(CSPath.get_app_registry_path(), lib))
        lib_path = fullfile(CSPath.get_app_registry_path, lib);
    else
        s = readstruct(fullfile(CSPath.get_app_registry_path, strcat(lib, '.json')));
        lib_path = s.path;
    end
    manifest = load(fullfile(lib_path, 'autogen', 'manifest.mat'));

end

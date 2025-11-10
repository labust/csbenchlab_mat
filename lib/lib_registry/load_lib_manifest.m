function manifest = load_lib_manifest(lib)

    if is_valid_component_library(lib)
        lib_path = lib;
    else
        if isfolder(fullfile(CSPath.get_app_registry_path(), lib))
            lib_path = fullfile(CSPath.get_app_registry_path, lib);
        else
            s = readstruct(fullfile(CSPath.get_app_registry_path, strcat(lib, '.json')));
            lib_path = s.path;
        end
    end
    manifest = readstruct(fullfile(lib_path, 'autogen', 'manifest.json'));
    fns = fieldnames(manifest.Registry);
    for i=1:length(fns)
        if ~iscell(manifest.Registry.(fns{i}))
            manifest.Registry.(fns{i}) = num2cell(manifest.Registry.(fns{i}));
        end
    end
end

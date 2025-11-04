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
    fns = fieldnames(manifest.registry);
    for i=1:length(fns)
        if ~iscell(manifest.registry.(fns{i}))
            manifest.registry.(fns{i}) = num2cell(manifest.registry.(fns{i}));
        end
    end
end

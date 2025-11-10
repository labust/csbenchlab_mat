function registry = make_component_registry_from_plugin_description(plugins_path, lib_name, save_manifest_library_path)
    
    plugin_desc_path = fullfile(plugins_path, "plugins.json");
    if ~endsWith(plugin_desc_path, ".json")
        error(strcat("Error parsing json. ", plugin_desc_path, "is not a json file."));
    end
    try
        pd = readstruct(plugin_desc_path);
    catch ME
        disp("Error parsing library package.json");
        rethrow(ME)
    end

    plugin_package_path = fullfile(plugins_path, "package.json");
    if ~endsWith(plugin_package_path, ".json")
        error(strcat("Error parsing json. '", plugin_package_path, "' is not a json file."));
    end
    try
        pkg = readstruct(plugin_package_path);
    catch ME
        disp("Error parsing library package.json");
        rethrow(ME)
    end
    
    if ~exist('save_manifest_library_path', 'var')
        save_manifest_library_path = '';
    end
    
    lib_path = fileparts(plugin_desc_path);

    registry.ctl = {};
    registry.sys = {};
    registry.est = {};
    registry.dist = {};
    for i = 1:length(pd.Plugins)
        p = pd.Plugins(i);
        if strcmp(p.Type, 'folder_scan')
            scan_folder = fullfile(lib_path, p.Path);
            if ~isfolder(scan_folder)
                warning(strcat("Plugin folder '", scan_folder," does not exist. Skipping..."));
                continue
            end
            registry = detect_components_from_path(scan_folder, registry);
        elseif strcmp(p.Type, 'file')
            registry = detect_component(fullfile(lib_path, p.Path), registry);
        end
    end

    registry = append_lib_name_to_registry(registry, lib_name);

    if ~strempty(save_manifest_library_path)
        manifest.Registry = registry;
        manifest.Library = pkg.Library;
        manifest.Version = pkg.Version;
        writestruct(manifest, fullfile(save_manifest_library_path, 'manifest.json'));
    end


end


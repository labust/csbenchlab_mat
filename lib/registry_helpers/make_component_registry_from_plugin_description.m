function registry = make_component_registry_from_plugin_description(plugin_desc_path, save_manifest_library_path)
    if ~endsWith(plugin_desc_path, ".json")
        error(strcat("Error parsing json. ", plugin_desc_path, "is not a json file."));
    end

    try
        pd = readstruct(plugin_desc_path);
    catch ME
        disp("Error parsing plugin description json.");
        rethrow(ME)
    end
    
    if ~exist('save_manifest_library_path', 'var')
        save_manifest_library_path = '';
    end
    
    parent_dir = fileparts(plugin_desc_path);

    registry.ctl = {};
    registry.sys = {};
    registry.est = {};
    registry.dist = {};
    for i = 1:length(pd.plugins)
        p = pd.plugins(i);
        if strcmp(p.type, 'folder_scan')
            scan_folder = fullfile(parent_dir, p.path);
            if ~isfolder(scan_folder)
                warning(strcat("Plugin folder '", scan_folder," does not exist. Skipping..."));
                continue
            end
            registry = detect_components_from_path(scan_folder, registry);
        elseif strcmp(p.type, 'file')
            registry = detect_component(fullfile(parent_dir, p.path), registry);
        end
    end

    if ~strempty(save_manifest_library_path)
        save(fullfile(save_manifest_library_path, 'manifest.mat'), "registry");
    end


end


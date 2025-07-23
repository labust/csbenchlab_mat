
function registry = detect_components_from_path(path, registry)

    if ~exist('registry', 'var')
        registry.ctl = {};
        registry.sys = {};
        registry.est = {};
        registry.dist = {};
    end
    
    [~, atrs] = fileattrib(path);

    plugin_extensions = ComponentRegister.get_supported_plugin_file_extensions();
    for i=1:length(plugin_extensions)
        filelist = dir(fullfile(atrs.Name, strcat('*', plugin_extensions(i))));
        for j = 1:length(filelist)
            registry = detect_component(fullfile(path, filelist(j).name), registry);
        end
    end
end

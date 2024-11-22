function plugins = get_available_plugins(varargin)


    [~, atrs] = fileattrib(get_app_registry_path());
    lib_list = dir(atrs.Name);



    if isempty(varargin)
        plugin_type = 0;
        plugins = struct;
        ctl = ["", ""];
        sys = ["", ""];
        est = ["", ""];
        dist = ["", ""];
    else
        plugin_type = varargin{1};
        plugins = ["", ""];
    end
    
    for i=1:length(lib_list)
        d = lib_list(i);
        lib_path = fullfile(d.folder, d.name);
        if ~isfolder(lib_path) || strcmp(d.name, '.') || strcmp(d.name, '..')
            continue
        end

        try
            manifest = load(fullfile(lib_path, 'manifest.mat'));
            registry = manifest.registry;
        catch
            error(strcat("Manifest file not found for library '",  d.name));
        end
        
        if plugin_type == 0
            sys = add_plugin_to_table(sys, registry.sys, manifest);
            ctl = add_plugin_to_table(sys, registry.ctl, manifest);
            est = add_plugin_to_table(sys, registry.est, manifest);
            dist = add_plugin_to_table(sys, registry.dist, manifest);
        elseif plugin_type == 1
            plugins = add_plugin_to_table(plugins, registry.sys, manifest);
        elseif plugin_type == 2
            plugins = add_plugin_to_table(plugins, registry.ctl, manifest);
        elseif plugin_type == 3
            plugins = add_plugin_to_table(plugins, registry.est, manifest);
        elseif plugin_type == 4
            plugins = add_plugin_to_table(plugins, registry.dist, manifest);
        end
    end

    if plugin_type > 0
        plugins = plugins(2:end, :);
    else
        plugins.sys = sys(2:end, :);
        plugins.ctl = ctl(2:end, :);
        plugins.est = est(2:end, :);
        plugins.dist = dist(2:end, :);
    end

end

function table = add_plugin_to_table(table, registry, manifest)
    for i=1:length(registry)
        r = registry{i};
        table(end+1, :) = [r.Name, manifest.library];
    end
end


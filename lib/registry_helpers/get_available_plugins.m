function plugins = get_available_plugins(varargin)


    [~, atrs] = fileattrib(get_app_registry_path());
    lib_list = dir(atrs.Name);

    if isempty(varargin)
        plugin_type = 0;
        plugins = struct;
        ctl = empty_plugin_struct();
        sys = empty_plugin_struct();
        est = empty_plugin_struct();
        dist = empty_plugin_struct();
    else
        plugin_type = varargin{1};
        plugins = empty_plugin_struct();
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
            sys = add_plugin(sys, registry.sys, manifest);
            ctl = add_plugin(ctl, registry.ctl, manifest);
            est = add_plugin(est, registry.est, manifest);
            dist = add_plugin(dist, registry.dist, manifest);
        elseif plugin_type == 1
            plugins = add_plugin(plugins, registry.sys, manifest);
        elseif plugin_type == 2
            plugins = add_plugin(plugins, registry.ctl, manifest);
        elseif plugin_type == 3
            plugins = add_plugin(plugins, registry.est, manifest);
        elseif plugin_type == 4
            plugins = add_plugin(plugins, registry.dist, manifest);
        end
    end

    if plugin_type == 0
        plugins.sys = sys;
        plugins.ctl = ctl;
        plugins.est = est;
        plugins.dist = dist;
    end
end

function structs = add_plugin(structs, registry, manifest)
    for i=1:length(registry)
        r = registry{i};
        structs(end+1, :) = struct('Name', r.Name, 'Lib', manifest.library, 'LibVersion', manifest.version);
    end
end

function s = empty_plugin_struct()
    s = struct('Name', {}, 'Lib', {}, 'LibVersion', {});
end
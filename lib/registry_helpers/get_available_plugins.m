function plugins = get_available_plugins(varargin)


    lib_list = list_component_libraries();
    reg = get_app_registry_path();

    if isempty(varargin)
        plugin_type = 0;
    else
        plugin_type = varargin{1};
    end
    plugins = dictionary;

    
    for i=1:length(lib_list)
        n = lib_list(i);
        lib_path = fullfile(reg, n);

        try
            manifest = load(fullfile(lib_path, 'manifest.mat'));
            registry = manifest.registry;
        catch
            error(strcat("Manifest file not found for library '",  n.name));
        end
        
        if plugin_type == 0
            plugins{n} = empty_plugin_container();
            plugins{n}.sys = add_plugin(registry.sys, manifest);
            plugins{n}.ctl = add_plugin(registry.ctl, manifest);
            plugins{n}.est = add_plugin(registry.est, manifest);
            plugins{n}.dist = add_plugin(registry.dist, manifest);
        elseif plugin_type == 1
            plugins{n} = add_plugin(registry.sys, manifest);
        elseif plugin_type == 2
            plugins{n} = add_plugin(registry.ctl, manifest);
        elseif plugin_type == 3
            plugins{n} = add_plugin(registry.est, manifest);
        elseif plugin_type == 4
            plugins{n} = add_plugin(registry.dist, manifest);
        end
    end
end
    
function structs = add_plugin(registry, manifest)
    structs = struct('Name', {}, 'Type', {}, 'Lib', {}, 'LibVersion', {});
    for i=1:length(registry)
        r = registry{i};
        structs(end+1) = struct('Name', r.Name, 'Type', r.Type, 'Lib', manifest.library, 'LibVersion', manifest.version);
    end
end


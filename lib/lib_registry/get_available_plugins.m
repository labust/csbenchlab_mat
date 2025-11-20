function plugins = get_available_plugins(varargin)

    lib_list = list_component_libraries();

    if isempty(varargin)
        plugin_type = 0;
    else
        plugin_type = varargin{1};
    end
    plugins = dictionary;


    for i=1:length(lib_list)
        n = lib_list(i).Name;

        lib_path = lib_list(i).Path;

        if ~is_valid_component_library(lib_path)
            remove_component_library(lib_path);
        end

        try
            manifest = load_lib_manifest(lib_path);
            registry = manifest.Registry;
            package_meta = readstruct(fullfile(lib_path, 'package.json'));
        catch
            error(strcat("Manifest file not found for library '",  n));
        end
        if isempty(fieldnames(registry))
            continue
        end
        if plugin_type == 0
            plugins{n} = struct;
            plugins{n}.sys = add_plugin(registry.sys, package_meta);
            plugins{n}.ctl = add_plugin(registry.ctl, package_meta);
            plugins{n}.est = add_plugin(registry.est, package_meta);
            plugins{n}.dist = add_plugin(registry.dist, package_meta);
        elseif plugin_type == 1
            plugins{n} = add_plugin(registry.sys, package_meta);
        elseif plugin_type == 2
            plugins{n} = add_plugin(registry.ctl, package_meta);
        elseif plugin_type == 3
            plugins{n} = add_plugin(registry.est, package_meta);
        elseif plugin_type == 4
            plugins{n} = add_plugin(registry.dist, package_meta);
        end
    end
end

function structs = add_plugin(registry, package_meta)
    structs = struct('Name', {}, 'Type', {}, 'Lib', {}, 'LibVersion', {}, 'Path', {});
    for i=1:length(registry)
        r = registry{i};
        structs(end+1) = struct('Name', string(r.Name), 'Type', r.Type, 'Lib', package_meta.Library, 'LibVersion', package_meta.Version, 'Path', r.ComponentPath);
    end
end


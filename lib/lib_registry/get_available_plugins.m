function plugins = get_available_plugins(varargin)

    lib_list = list_component_libraries();

    if isempty(varargin)
        plugin_type = 'all';
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
        if plugin_type == "all"
            plugins{n} = struct;
            fns = fieldnames(registry);
            for j=1:length(fns)
                fn = fns{j};
                plugins{n}.(fn) = add_plugin(registry.(fn), package_meta);
            end
        else
            if isfield(registry, plugin_type)
                plugins{n} = add_plugin(registry.(plugin_type), package_meta);
            else
                plugins{n} = [];
            end
        end
    end
end

function structs = add_plugin(registry, package_meta)
    structs = struct('Name', {}, 'Type', {}, 'Lib', {}, 'LibVersion', {}, 'ComponentPath', {}, 'T', {});
    for i=1:length(registry)
        r = registry{i};
        structs(end+1) = struct('Name', string(r.Name), 'Type', r.Type, 'Lib', ...
            package_meta.Library, 'LibVersion', package_meta.Version, 'ComponentPath', r.ComponentPath, 'T', r.T);
    end
end


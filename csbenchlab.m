function csbenchlab()
    path = CSPath.get_appdata_path();
    init_app(path);
end

function init_app(path)
    init_f_name = fullfile(path, 'registry', 'init_f');
    % if ~exist(init_f_name, 'file')
        mkdir(fullfile(path, 'registry'));
        fclose(fopen(init_f_name, 'w'));
        register_common_components(path);
    % end
end

function register_common_components(path)
    root = CSPath.get_app_root_path();
    plugin_path = fullfile(root, "plugins");

    handle = get_or_create_component_library('csbenchlab');
    registry = make_component_registry_from_plugin_description(plugin_path, ...
        'csbenchlab', fullfile(path, 'registry', 'csbenchlab', 'autogen'));


    fnames = fieldnames(registry);
    types = get_supported_component_types();
    for i=1:length(fnames)
        fname = fnames{i};
        if ~any(arrayfun(@(x) strcmp(fname, x), types))
            warning(strcat("Found unknown component type '", fname, "'."));
            continue
        end

        plugin_list = registry.(fname);
        for j = 1:length(plugin_list)
            register_component(plugin_list{j}, handle.name, 1, 0);
        end
    end
end











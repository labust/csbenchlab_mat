function csbenchlab()
    
    path = get_app_root_path();

    init_app(path);
    run('csbenchlab_app.mlapp');
end

function init_app(path)
    init_f_name = fullfile(path, 'registry', 'init_f');
    if ~exist(init_f_name, 'file')
        mkdir(fullfile(path, 'autogen'));
        mkdir(fullfile(path, 'registry'));
        mkdir(fullfile(path, 'appdata'))
        addpath(fullfile(path, 'code_autogen'));
        fclose(fopen(init_f_name, 'w'));
        register_common_components(path);
    end
end

function register_common_components(path)
    plugin_desc_path = fullfile(path, "plugins", "plugins.json");

    get_or_create_component_library(fullfile(path, 'registry', 'local'), 1);
    handle = get_or_create_component_library(fullfile(path, 'registry', 'csbenchlab'));
    registry = make_component_registry_from_plugin_description(plugin_desc_path, ...
        'csbenchlab', fullfile(path, 'registry', 'csbenchlab', 'autogen'));


    fnames = fieldnames(registry);
    types = get_component_types();
    for i=1:length(fnames)
        fname = fnames{i};
        if ~any(arrayfun(@(x) strcmp(fname, x), types))
            warning(strcat("Found unknown component type '", fname, "'."));
            continue
        end

        plugin_list = registry.(fname);
        for j = 1:length(plugin_list)
            register_component(plugin_list{j}, parse_comp_type(fname), handle.name, handle.path);
        end
    end
end











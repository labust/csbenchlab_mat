function csbenchlab()
    
    path = get_app_root_path();

    init_app(path);
    run('csbenchlab_app.mlapp');
end

function init_app(path)
    init_f_name = fullfile(path, 'registry', 'init_f');
    %if ~exist(init_f_name, 'file')
        mkdir(fullfile(path, 'autogen'));
        mkdir(fullfile(path, 'code_autogen'));
        mkdir(fullfile(path, 'registry'));
        mkdir(fullfile(path, 'appdata'))
        addpath(fullfile(path, 'code_autogen'));
        fclose(fopen(init_f_name, 'w'));
        register_common_components(path);
    %end
end

function register_common_components(path)

    lib_paths = {   
        "plugins/Controllers", ...
        "plugins/Systems", ...
        "plugins/Estimators", ...
        "plugins/DisturbanceGenerators"
    };
    get_or_create_component_library(fullfile(path, 'registry'), 'local');

    handle = get_or_create_component_library(fullfile(path, 'registry'), 'csbenchlab');
    

    lib_paths = cellfun(@(x) fullfile(path, x), lib_paths);

    registry = make_component_registry_from_path(lib_paths, 'csbenchlab');

    for i = 1:length(registry.ctl)
        register_component(registry.ctl{i}, parse_comp_type('ctl'), handle.name);
    end
    generate_get_m_controller_log_function_handle(registry.ctl);
    for i = 1:length(registry.sys)
        register_component(registry.sys{i}, parse_comp_type('sys'), handle.name);
    end
    for i = 1:length(registry.est)
        register_component(registry.est{i}, parse_comp_type('est'), handle.name);
    end
    for i = 1:length(registry.dist)
        register_component(registry.dist{i}, parse_comp_type('dist'), handle.name);
    end
end











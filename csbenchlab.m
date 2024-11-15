function csbenchlab()
    
    path = get_app_root_path();

    init_app(path);
    run('csbenchlab_app.mlapp');
end

function init_app(path)
    init_f_name = fullfile(path, 'registry', 'init_f');
    if ~exist(init_f_name, 'file')
        mkdir(fullfile(path, 'autogen'));
        mkdir(fullfile(path, 'code_autogen'));
        mkdir(fullfile(path, 'registry'));
        mkdir(fullfile(path, 'appdata'))
        addpath(fullfile(path, 'code_autogen'));
        fclose(fopen(init_f_name, 'w'));
        register_common_components(path);
    end
end

function register_common_components(path)

    lib_paths = {   
        "plugins/Controllers", ...
        "plugins/Systems", ...
        "plugins/Estimators", ...
        "plugins/DisturbanceGenerators"
    };

    handle = get_or_create_component_library(fullfile(path, 'registry'), 'csbenchlab');

    registry.ctl = {};
    registry.sys = {};
    registry.est = {};
    registry.dist = {};
    for i = 1:length(lib_paths)
        registry = detect_components_from_path(fullfile(path, lib_paths{i}), registry);
    end

    for i = 1:length(registry.ctl)
        register_controller(registry.ctl{i}, handle.name);
    end
    generate_get_m_controller_log_function_handle(registry.ctl);
    for i = 1:length(registry.sys)
        register_system(registry.sys{i}, handle.name);
    end
    for i = 1:length(registry.est)
        register_estimator(registry.est{i}, handle.name);
    end
    for i = 1:length(registry.dist)
        register_disturbance_generator(registry.dist{i}, handle.name);
    end
    version = '0.1';
    library = 'csbenchlab';
    save(fullfile(path, 'registry', 'csbenchlab', 'manifest.mat'), "registry", 'version', 'library');

end











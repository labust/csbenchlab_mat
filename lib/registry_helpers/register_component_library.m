function register_component_library(path)
    if isfolder(path)
        reg = get_app_registry_path();
        [~, name, ~] = fileparts(path);

        if exist(fullfile(reg, name), 'dir')
            rmdir(fullfile(reg, name), 's');
        end

        copyfile(path, fullfile(reg, name));
        registry = make_component_registry_from_path(get_library_component_folders(fullfile(reg, name)), name);

        handle = get_or_create_component_library(fullfile(path, 'registry'), name);
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


        addpath(fullfile(reg, name));
    end
end


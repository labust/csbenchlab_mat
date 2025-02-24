function register_component_library(path)
    if isfolder(path)
        reg = get_app_registry_path();
        [~, name, ~] = fileparts(path);

        if exist(fullfile(reg, name), 'dir')
            rmdir(fullfile(reg, name), 's');
        end

        copyfile(path, fullfile(reg, name));
        addpath(fullfile(reg, name));
    end
end


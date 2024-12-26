function register_component_library(path)
    if isfolder(path)
        reg = get_app_registry_path();
        [~, name, ~] = fileparts(path);

        copyfile(path, fullfile(reg, name));
        addpath(fullfile(reg, name));
    end
end


function register_component_library(path)
    if isfolder(path)
        reg = get_app_registry_path();
        copyfile(path, reg);
        [~, name, ~] = fileparts(path);
        addpath(fullfile(reg, name));
    end
end


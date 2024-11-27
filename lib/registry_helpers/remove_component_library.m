function remove_component_library(lib_name)
    reg = get_app_registry_path();
    n = fullfile(reg, lib_name);
    rmpath(n);
    rmdir(n, 's');
    delete(fullfile(reg, lib_name));
end


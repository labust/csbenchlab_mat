function remove_component_library(lib_name)
    if strcmp(lib_name, 'csbenchlab')
        error("Cannot remove 'csbenchlab' library.");
    end
    if strcmp(lib_name, 'local')
        error("Cannot remove 'local' library.");
    end
    reg = CSPath.get_app_registry_path();
    n = fullfile(reg, lib_name);
    close_library(lib_name);
    if isfolder(n)
        rmpath(n);
        rmdir(n, 's');
    elseif isfile(strcat(n, '.json'))
        delete(strcat(n, '.json'));
    end
    
end


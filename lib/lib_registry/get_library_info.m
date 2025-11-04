function info = get_library_info(lib_name, only_registered)
    
    if ~exist("only_registered", 'var')
        only_registered = 1;
    else
        only_registered = 0;
    end
    
    if only_registered
        path = get_library_path(lib_name);
        info = readstruct(fullfile(path, 'package.json'));
    else
        if is_valid_component_library(lib_name)
             info = readstruct(fullfile(lib_name, 'package.json'));
        else
            error(strcat("Path '", lib_name, "' is not a valid library"));
        end

    end
end


function lib = get_component_library(n)
    
   
    reg = CSPath.get_app_registry_path();
    ff = fullfile(reg, n);
    if isfolder(ff)
        lib = struct('Name', n, "Type", 'install', 'Path', fullfile(reg, n));
    elseif isfile(strcat(ff, '.json'))
        s = readstruct(strcat(ff, '.json'));
        lib = struct('Name', n, "Type", 'link', 'Path', s.path);
    else
        error(strcat("Error loading library. Library '", n, " does not exist"));
    end

end


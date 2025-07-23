function lib = get_library_path(lib_name)
   
    reg = get_app_registry_path();
    fs = dir(reg);
    for i=1:length(fs)
        n = fs(i).name;
        if strcmp(n, '.') || strcmp(n, '..') || strcmp(n, 'slprj') ...
            || ~strcmp(n, lib_name)
            continue
        end

        if isfolder(fullfile(reg, n))
            lib = fullfile(reg, n);
            return
        elseif endsWith(n, '.json')
            s = readstruct(fullfile(fs(i).folder, fs(i).name));
            lib = s.path;
            return
        end
    end
    error(strcat("Library '", lib_name, "' not found"));
end

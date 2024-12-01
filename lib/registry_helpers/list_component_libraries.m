function libs = list_component_libraries(ignore_csbenchlab)
    
    if ~exist('ignore_csbenchlab', 'var')
        ignore_csbenchlab = 0;
    end
    reg = get_app_registry_path();
    fs = dir(reg);
    libs = strings(0, 1);
    for i=1:length(fs)
        n = fs(i).name;
        if strcmp(n, '.') || strcmp(n, '..')
            continue
        end

        if ignore_csbenchlab && strcmp(n, 'csbenchlab')
            continue
        end

        if isfolder(fullfile(reg, n))
            libs(end+1) = n;
        end
    end

end


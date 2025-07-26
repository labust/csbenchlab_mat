function libs = list_component_libraries(ignore_csbenchlab)
    
    if ~exist('ignore_csbenchlab', 'var')
        ignore_csbenchlab = 0;
    end
    reg = CSPath.get_app_registry_path();
    fs = dir(reg);
    libs = struct('Name', {}, 'Type', {}, 'Path', {}, 'Version', {});
    for i=1:length(fs)
        n = fs(i).name;
        if strcmp(n, '.') || strcmp(n, '..') || strcmp(n, 'slprj')
            continue
        end

        if ignore_csbenchlab && strcmp(n, 'csbenchlab')
            continue
        end


        if isfolder(fullfile(reg, n))
            meta = readstruct(fullfile(reg, n, 'package.json'));
            libs(end+1) = struct('Name', n, "Type", 'install', 'Path', fullfile(reg, n), 'Version', meta.version);
        elseif endsWith(n, '.json')
            [~, name, ~] = fileparts(n);
            s = readstruct(fullfile(fs(i).folder, fs(i).name));
            libs(end+1) = struct('Name', name, "Type", 'link', 'Path', s.path, 'Version', s.version);
        end
    end

end


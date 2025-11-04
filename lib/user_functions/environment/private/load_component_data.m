function c = load_component_data(env_path, rel_path, check_path)
    if ~exist('check_path', 'var')
        check_path = 1;
    end
    if check_path && ~is_env_path(env_path)
        [env_path, ~, ~] = fileparts(which(env_path));
    end
    f = fullfile(env_path, rel_path);
    if exist(f, 'file')
        c = readstruct(f, 'FileType', 'json');
        c = load_subcomponents(c, env_path, rel_path);
    else
        c = struct;
        return
    end
end



function c = load_subcomponents(c, env_path, rel_path)
    if ~is_valid_field(c, 'Subcomponents')
        return
    end

    rel_path = fileparts(rel_path);

    for i=1:length(c.Subcomponents)
        if is_valid_field(c, c.Subcomponents(i))
            v = c.(c.Subcomponents(i));
            
            for j=1:length(v)
                id = v.Id;
                dest_path = v.DestinationPath;
                name = strcat(c.Subcomponents(i), '.json');
                full_path = fullfile(rel_path, ...
                        'subcomponents', dest_path, id, name);
                data = load_component_data(env_path, full_path, 0);
                data.DestinationPath = dest_path; % for knowing where on path it is
                data.ParentComponentName = c.Name; % for identifying workspace parameters
                res(j) = data;
            end
            c.(c.Subcomponents(i)) = res;
            clear('res', 'var');
        end
    end

    
end
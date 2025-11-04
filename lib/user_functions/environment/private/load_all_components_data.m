function c = load_all_components_data(env_path, rel_path, comp_file_name, check_path)
    if ~exist('check_path', 'var')
        check_path = 1;
    end
    if check_path && ~is_env_path(env_path)
        [env_path, ~, ~] = fileparts(which(env_path));
    end
    folder = fullfile(env_path, 'parts', rel_path);

    content = dir(folder);
    k = 1;
    for i=1:length(content)
        f = content(i).name;
        % Skip . and .. folders and all files
        if ~content(i).isdir || content(i).isdir && (strcmp(f, '.') || strcmp(f, '..'))
            continue
        end

        try
            c(k) = load_component_data(env_path, fullfile('parts', rel_path, f, comp_file_name), 0);
            k = k + 1;
        catch
            warning("Could not load '%s' for component with id %s", comp_file_name, f);
        end
    end
    if ~exist('c', 'var')
        c = [];
    end
end
    
        
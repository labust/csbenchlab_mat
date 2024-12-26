function save_env_system(env_path, system, check_path)
    if ~exist('check_path', 'var')
        check_path = 1;
    end
    if check_path && ~is_env_path(env_path)
        [env_path, ~, ~] = fileparts(which(env_path));
    end
    f = fullfile(env_path, 'parts', 'system.json');

    system = save_component_params(system, env_path);
    writestruct(system, f, 'FileType', 'json');    
end
function save_env_disturbance(env_path, disturbance, check_path)
    if ~exist('check_path', 'var')
        check_path = 1;
    end
    if check_path && ~is_env_path(env_path)
        [env_path, ~, ~] = fileparts(which(env_path));
    end

    disturbance = save_component_params(disturbance, env_path);
    f = fullfile(env_path, 'parts', 'disturbance.json');
    writestruct(disturbance, f, 'FileType', 'json');
end
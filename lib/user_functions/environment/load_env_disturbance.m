function e = load_env_disturbance(env_path, check_path)
    if ~exist('check_path', 'var')
        check_path = 1;
    end
    if check_path && ~is_env_path(env_path)
        [env_path, ~, ~] = fileparts(which(env_path));
    end
    f = fullfile(env_path, 'parts', 'disturbance.json');
    if exist(f, "file")
        e = readstruct(f);
    else
        e = struct;
        return
    end
    e = load_component_params(e, env_path);
end
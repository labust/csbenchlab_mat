function save_env_estimator(env_path, estimator, check_path)
    if ~exist('check_path', 'var')
        check_path = 1;
    end
    if check_path && ~is_env_path(env_path)
        [env_path, ~, ~] = fileparts(which(env_path));
    end

    estimator = save_component_params(estimator, env_path);
    f = fullfile(env_path, 'parts', 'estimator.json');
    writestruct(estimator, f, 'FileType', 'json');
end
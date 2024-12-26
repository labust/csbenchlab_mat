function save_env_metrics(env_path, metrics, check_path)
    if ~exist('check_path', 'var')
        check_path = 1;
    end
    if check_path && ~is_env_path(env_path)
        [env_path, ~, ~] = fileparts(which(env_path));
    end

    for i=1:length(metrics)
        metrics(i) = save_component_params(metrics(i), env_path);
    end
    f = fullfile(env_path, 'parts', 'metrics.json');
    writestruct(metrics, f, 'FileType', 'json');
end
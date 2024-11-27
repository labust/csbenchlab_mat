function save_env_metrics(env_path, metrics)
    if ~is_env_path(env_path)
        [env_path, ~, ~] = fileparts(which(env_path));
    end
    f = fullfile(env_path, 'parts', 'metrics.json');
    writestruct(metrics, f, 'FileType', 'json');
end
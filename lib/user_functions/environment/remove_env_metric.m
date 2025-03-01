function remove_env_metric(env_path, name)
    metrics = load_env_metrics(env_path);
    idx = arrayfun(@(x)strcmp(x, name), [metrics.Name]);
    if any(idx)
        metrics(idx) = [];
    end
    save_env_metrics(env_path, metrics);
end
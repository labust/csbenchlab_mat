function save_env_metric(env_path, metric)
    metrics = load_env_metrics(env_path);
    if isempty(metrics)
        metrics = metric;
        save_env_metrics(env_path, metrics);
        return
    end
    idx = strcmp([metrics.Id], metric.Id);
    if any(idx)
        metrics(idx) = metric;
    else
        metrics(end+1) = metric;
    end
    save_env_metrics(env_path, metrics);  
end
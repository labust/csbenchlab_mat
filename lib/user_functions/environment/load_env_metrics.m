function m = load_env_metrics(env_path, check_path)
    m = load_all_components_data(env_path, 'metrics', 'metric.json', check_path);
end
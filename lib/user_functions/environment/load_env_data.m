function cfg = load_env_data(env_path)
    cfg.Metadata = load_env_metadata(env_path);
    cfg.Controllers = load_env_controllers(env_path);
    cfg.System = load_env_system(env_path);
    cfg.Metrics = load_env_metrics(env_path);
    cfg.Scenarios = load_env_scenarios(env_path);
end


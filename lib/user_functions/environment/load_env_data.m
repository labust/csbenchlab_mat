function cfg = load_env_data(env_path, check_path)

    if ~exist('check_path', 'var')
        check_path = 1;
    end

    cfg.Metadata = load_env_metadata(env_path, check_path);
    cfg.Controllers = load_env_controllers(env_path, check_path);
    cfg.System = load_env_system(env_path, check_path);
    cfg.Metrics = load_env_metrics(env_path, check_path);
    cfg.Scenarios = load_env_scenarios(env_path, check_path);
end

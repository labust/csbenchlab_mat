function save_env_data(env_path, data)

    save_env_metadata(env_path, data.Metadata);
    save_env_system(env_path, data.System);
    save_env_controllers(env_path, data.Controllers);
    save_env_scenarios(env_path, data.Scenarios);
    save_env_metrics(env_path, data.Metrics);
end


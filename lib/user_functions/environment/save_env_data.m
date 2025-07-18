function save_env_data(env_path, data, check_path)
    
    if ~exist('check_path', 'var')
        check_path = 1;
    end

    save_env_metadata(env_path, data.Metadata, check_path);
    save_env_system(env_path, data.System, check_path);
    save_env_controllers(env_path, data.Controllers, check_path);
    save_env_scenarios(env_path, data.Scenarios, check_path);
  
    save_env_metrics(env_path, data.Metrics, check_path);
end


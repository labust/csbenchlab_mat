function save_env_scenario(env_path, scenario, env_save)
    
    if ~exist('env_save', 'var')
        env_save = 1;
    end

    if ~env_save
        save_env_scenarios(env_path, scenario, 0);
        return
    end
    
    scenarios = load_env_scenarios(env_path);
    if isempty(scenarios)
        scenarios = scenario;
        save_env_scenarios(env_path, scenarios);
        return
    end
    idx = strcmp([scenarios.Id], scenario.Id);
    if any(idx)
        scenarios(idx) = scenario;
    else
        scenarios(end+1) = scenario;
    end
    save_env_scenarios(env_path, scenarios);
end
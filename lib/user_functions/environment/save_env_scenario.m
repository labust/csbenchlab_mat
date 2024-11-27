function save_env_scenario(env_path, scenario)
    scenarios = load_env_scenarios(env_path);
    if isempty(scenarios)
        scenarios = scenario;
        save_env_scenarios(env_path, scenarios);
        return
    end
    idx = strcmp(scenarios.Name, scenario.Name);
    if any(idx)
        scenarios(idx) = scenario;
    else
        scenarios(end+1) = scenario;
    end
    save_env_scenarios(env_path, scenarios);
end
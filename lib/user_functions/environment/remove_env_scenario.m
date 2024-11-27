function remove_env_scenario(env_path, name)
    scenarios = load_env_scenarios(env_path);
    idx = strcmp(scenarios.Name, name);
    if any(idx)
        scenarios(idx) = [];
    end
    save_env_scenarios(env_path, scenarios);
end
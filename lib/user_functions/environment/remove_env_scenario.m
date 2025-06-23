function remove_env_scenario(env_path, name)
    scenarios = load_env_scenarios(env_path);
    if isempty(scenarios)
        return
    end
    idx = arrayfun(@(x)strcmp(x, name), [scenarios.Name]);
    if any(idx)
        scenarios(idx) = [];
    end
    save_env_scenarios(env_path, scenarios);
end
function s = load_env_scenarios(env_path, check_path)
    s = load_all_components_data(env_path, 'scenarios', 'scenario.json', check_path);
end

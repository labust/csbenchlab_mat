function s = load_env_systems(env_path, check_path)
    s = load_all_components_data(env_path, 'systems', 'system.json', check_path);
end
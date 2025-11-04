function s = load_env_system(env_path, id, check_path)
    s = load_component_data(env_path, fullfile('parts', 'systems', id, 'system.json'), check_path);
end
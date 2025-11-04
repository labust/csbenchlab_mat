function c = load_env_controllers(env_path, check_path)

    c = load_all_components_data(env_path, 'controllers', 'controller.json', check_path);
end
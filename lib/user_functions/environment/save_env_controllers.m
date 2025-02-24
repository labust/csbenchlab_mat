function save_env_controllers(env_path, controllers, check_path)
    if ~exist('check_path', 'var')
        check_path = 1;
    end
    
    current_controllers = load_env_controllers(env_path, 0);
    if ~isempty(current_controllers)
        remove_env_controllers(env_path);
    end

    for i=1:length(controllers)
        save_env_controller(env_path, controllers(i), check_path);
    end
end
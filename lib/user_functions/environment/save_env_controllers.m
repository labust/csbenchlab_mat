function save_env_controllers(env_path, controllers, check_path)
    if ~exist('check_path', 'var')
        check_path = 1;
    end

    for i=1:length(controllers)
        save_env_controller(env_path, controllers(i), check_path);
    end
end
function remove_env_controllers(env_path)
    controllers_folder = fullfile(env_path, 'parts', 'controllers');
    if exist(controllers_folder, 'dir')
        rmdir(controllers_folder,"s");
        mkdir(controllers_folder);
    end
end
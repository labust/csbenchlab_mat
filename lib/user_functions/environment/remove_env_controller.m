function remove_env_controller(env_path, id)

    controllers = load_env_controllers(env_path);
    if isempty(controllers)
        return
    end
    idx = strcmp([controllers.Id], id);
    if any(idx)
        controllers(idx) = [];
    end
    save_env_controllers(env_path, controllers);

    f = fullfile(env_path, 'parts', 'controllers', strcat(id, '.json'));
    if exist(f, 'file')
        delete(f);
    end
end
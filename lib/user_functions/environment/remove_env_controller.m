function remove_env_controller(env_path, id)
    f = fullfile(env_path, 'parts', 'controllers', strcat(id, '.json'));
    if exist(f, 'file')
        delete(f);
    end
end
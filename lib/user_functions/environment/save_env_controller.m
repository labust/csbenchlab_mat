function save_env_controller(env_path, controller)
    if ~is_env_path(env_path)
        [env_path, ~, ~] = fileparts(which(env_path));
    end
    f = fullfile(env_path, 'parts', 'controllers', strcat(controller.Id, '.json'));
    writestruct(controller, f, 'FileType', 'json');  
end
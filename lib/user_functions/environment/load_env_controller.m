function c = load_env_controller(env_path, id)
    if ~is_env_path(env_path)
        [env_path, ~, ~] = fileparts(which(env_path));
    end
    controllers_folder = fullfile(env_path, 'parts', 'controllers');
    f = fullfile(controllers_folder, strcat(id, '.json'));
    if exist(f, 'file')
        c = readstruct(f);
    else
        c = struct;
    end
end
function rmsource_environment(env_name)
    env_path = fileparts(which(env_name));
    paths = get_env_folder_paths(env_path, env_name);
    rmpath(paths{:});
end


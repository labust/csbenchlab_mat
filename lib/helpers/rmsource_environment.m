function rmsource_environment(env_name_or_path)
    
    if is_env_path(env_name_or_path)
        env_name = get_env_name(env_name_or_path);
        env_path = env_name_or_path;
    else
        env_path = fileparts(which(env_name_or_path));
        env_name = env_name_or_path;
    end
    paths = get_env_folder_paths(env_path, env_name);
    rmpath(paths{:});
end


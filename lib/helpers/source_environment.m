function source_environment(env_path)
    if is_env_path(env_path)
        env_name = get_env_name(env_path);
    else
        error("Provided argument is not a valid environment path");
    end

    paths = get_env_folder_paths(env_path, env_name);
    addpath(paths{:});
end


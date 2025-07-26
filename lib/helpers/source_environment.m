function source_environment(env_path, env_name)
    paths = get_env_folder_paths(env_path, env_name);
    addpath(paths{:});
end


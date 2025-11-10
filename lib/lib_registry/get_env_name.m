function env_name = get_env_name(env_path)
    env_name = split(env_path, '/');
    env_name = env_name{end};
end

function env_path = get_env_path(env_name)
    if is_env_path(env_name)
        env_path = env_name;
    else
        [env_path, ~, ~] = fileparts(which(env_name));
    end
    if isempty(env_path)
        error(strcat("Environment '", env_name, "' does not exist on path"));
    end
end

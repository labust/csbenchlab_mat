function t = is_env(env_name)
    [env_path, name, ~] = fileparts(which(env_name));
    t = exist(fullfile(env_path, strcat(name, '.cse')), 'file');
end


function t = is_env_path(env_path)
    [~, name, ~] = fileparts(env_path);
    t = exist(fullfile(env_path, strcat(name, '.cse')), 'file');
end


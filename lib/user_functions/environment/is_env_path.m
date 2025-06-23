function t = is_env_path(env_path)

    file = java.io.File(env_path);

    if ~file.isAbsolute
        env_path = fullfile('.', env_path);
    end
    [~, name, ~] = fileparts(env_path);
    t = exist(fullfile(env_path, strcat(name, '.cse')), 'file');
end


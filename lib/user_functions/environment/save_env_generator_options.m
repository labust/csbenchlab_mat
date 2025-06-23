function save_env_generator_options(env_path, options, check_path)
    if ~exist('check_path', 'var')
        check_path = 1;
    end
    if check_path && ~is_env_path(env_path)
        [env_path, ~, ~] = fileparts(which(env_path));
    end
    f = fullfile(env_path, 'generator_options.json');
    writestruct(options, f, 'FileType', 'json');  
end
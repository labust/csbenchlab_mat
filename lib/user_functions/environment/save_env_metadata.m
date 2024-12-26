function save_env_metadata(env_path, metadata, check_path)
    if ~exist('check_path', 'var')
        check_path = 1;
    end
    if check_path && ~is_env_path(env_path)
        [env_path, ~, ~] = fileparts(which(env_path));
    end
    f = fullfile(env_path, 'config.json');
    writestruct(metadata, f, 'FileType', 'json');
end
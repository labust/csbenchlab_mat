function save_env_metadata(env_path, metadata)
    if ~is_env_path(env_path)
        [env_path, ~, ~] = fileparts(which(env_path));
    end
    f = fullfile(env_path, 'config.json');
    writestruct(metadata, f, 'FileType', 'json');
end
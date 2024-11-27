function m = load_env_metadata(env_path)
    if ~is_env_path(env_path)
        [env_path, ~, ~] = fileparts(which(env_path));
    end
    f = fullfile(env_path, 'config.json');
    if exist(f, "file")
        m = readstruct(f);
    else
        m = struct;
    end
end
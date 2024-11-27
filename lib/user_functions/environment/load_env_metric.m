function m = load_env_metric(env_path, name)
    if ~is_env_path(env_path)
        [env_path, ~, ~] = fileparts(which(env_path));
    end
    f = fullfile(env_path, 'parts', 'metrics.json');
    if exist(f, "file")
        m = readstruct(f);
        idx = strcmp(m.Name, name);
        m = m(idx);
    else
        m = [];
    end
end
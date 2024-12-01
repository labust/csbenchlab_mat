function m = load_env_metrics(env_path)
    if ~is_env_path(env_path)
        [env_path, ~, ~] = fileparts(which(env_path));
    end
    f = fullfile(env_path, 'parts', 'metrics.json');
    if exist(f, "file")
        m = readstruct(f);
    else
        m = [];
    end

    if isempty(m)
        return
    end

    for i=1:length(m)
        m(i) = load_component_params(m(i), env_path);
    end
end
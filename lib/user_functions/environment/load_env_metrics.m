function m = load_env_metrics(env_path, check_path)
    if ~exist('check_path', 'var')
        check_path = 1;
    end
    if check_path && ~is_env_path(env_path)
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
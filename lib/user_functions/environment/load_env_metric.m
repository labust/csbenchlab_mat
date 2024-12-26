function m = load_env_metric(env_path, name, varargin)
    m = load_env_metrics(env_path, varargin{:});
    if isempty(m)
        return
    end
    idx = strcmp(m.Name, name);
    m = m(idx);
end
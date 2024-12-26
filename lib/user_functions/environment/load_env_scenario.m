function s = load_env_scenario(env_path, name, varargin)
    s = load_env_scenarios(env_path, varargin{:});
    if isempty(s)
        return
    end
    idx = strcmp(s.Name, name);
    s = s(idx);
end
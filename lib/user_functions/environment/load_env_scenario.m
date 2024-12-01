function s = load_env_scenario(env_path, name)
    s = load_env_scenarios(env_path);
    if isempty(s)
        return
    end
    idx = strcmp(s.Name, name);
    s = s(idx);
end
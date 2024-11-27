function s = load_env_scenario(env_path, name)
    if ~is_env_path(env_path)
        [env_path, ~, ~] = fileparts(which(env_path));
    end
    f = fullfile(env_path, 'parts', 'scenarios.json');
    if exist(f, "file")
        s = readstruct(f);
        idx = strcmp(s.Name, name);
        s = s(idx);
    else
        s = [];
    end
end
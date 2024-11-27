function s = load_env_scenarios(env_path)
    if ~is_env_path(env_path)
        [env_path, ~, ~] = fileparts(which(env_path));
    end
    f = fullfile(env_path, 'parts', 'scenarios.json');
    if exist(f, "file")
        s = readstruct(f);
    else
        s = [];
    end
end
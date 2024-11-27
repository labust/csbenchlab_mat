function save_env_scenarios(env_path, scenarios)
    if ~is_env_path(env_path)
        [env_path, ~, ~] = fileparts(which(env_path));
    end
    f = fullfile(env_path, 'parts', 'scenarios.json');
    writestruct(scenarios, f, 'FileType', 'json');   
end
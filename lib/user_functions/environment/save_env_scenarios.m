function save_env_scenarios(env_path, scenarios)
    if ~is_env_path(env_path)
        [env_path, ~, ~] = fileparts(which(env_path));
    end
    f = fullfile(env_path, 'parts', 'scenarios.json');
    
    for i=1:length(scenarios)
        scenarios(i) = save_component_params(scenarios(i), env_path);
    end
    writestruct(scenarios, f, 'FileType', 'json');   
end


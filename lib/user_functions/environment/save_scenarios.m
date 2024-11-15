function save_scenarios(env_name, Scenarios, varargin)
    
    validate_scenarios(Scenarios);
    pa = @BlockHelpers.path_append;
    path = fileparts(which(env_name));
    scenarios_path = pa(path, 'autogen', strcat(env_name, '_scenarios.mat'));
    
    save(scenarios_path, 'Scenarios');
    
end
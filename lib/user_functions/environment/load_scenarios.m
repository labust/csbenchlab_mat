function s = load_scenarios(env_name, varargin)
    
    pa = @BlockHelpers.path_append;
    path = fileparts(which(env_name));
    plots_path = pa(path, 'autogen', strcat(env_name, '_scenarios.mat'));
    
    s = load(plots_path);
    s = s.Scenarios;
end
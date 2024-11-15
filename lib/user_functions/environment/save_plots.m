function save_plots(env_name, Plots, varargin)
    
    validate_scenarios(Plots);
    pa = @BlockHelpers.path_append;
    path = fileparts(which(env_name));
    plots_path = pa(path, 'autogen', strcat(env_name, '_plots.mat'));
    
    save(plots_path, 'Plots');
    
end
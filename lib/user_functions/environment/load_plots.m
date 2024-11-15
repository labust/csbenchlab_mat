function p = load_plots(env_name, varargin)
    
    pa = @BlockHelpers.path_append;
    path = fileparts(which(env_name));
    plots_path = pa(path, 'autogen', strcat(env_name, '_plots.mat'));
    
    p = load(plots_path);
    p = p.Plots;
end
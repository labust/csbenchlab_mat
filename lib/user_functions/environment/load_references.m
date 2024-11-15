function r = load_references(env_name, varargin)
    
    pa = @BlockHelpers.path_append;
    path = fileparts(which(env_name));
    plots_path = pa(path, 'autogen', strcat(env_name, '_refs.mat'));
    
    r = load(plots_path);
    r = r.References;
end
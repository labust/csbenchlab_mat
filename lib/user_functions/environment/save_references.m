function save_references(env_name, References, varargin)
    
    validate_references(References);
    pa = @BlockHelpers.path_append;
    path = fileparts(which(env_name));
    scenarios_path = pa(path, 'autogen', strcat(env_name, '_refs.mat'));
    
    save(scenarios_path, 'References');
    
end
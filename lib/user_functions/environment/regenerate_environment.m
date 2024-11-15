function regenerate_environment(env_name)

    pa = @BlockHelpers.path_append;

    env_path = which(env_name);
    if isempty(env_path)
        error(strcat('Environment "', env_path, '" cannot be found on path'));
    end

    folder = fileparts(env_path);
    
    cfg_file = pa(folder, 'config.json');
    cfg = readstruct(cfg_file);
    generate_control_environment(cfg, folder);

end
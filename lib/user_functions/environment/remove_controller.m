function remove_controller(env_name, controller_name, regenerate_env)
    
    env_path = which(env_name);
    pa = @BlockHelpers.path_append;
    if isempty(env_path)
        error(strcat('Environment "', env_name, '" cannot be found on path'));
    end

    folder = fileparts(env_path);
    
    cfg_file = pa(folder, 'config.json');
    cfg = readstruct(cfg_file);

    if ~isfield(cfg, 'Controllers')
        return
    end  

    for i=1:length(cfg.Controllers)      
        if strcmp(cfg.Controllers(i).Name, controller_name)
            cfg.Controllers = cfg.Controllers([1:i-1, i+1:end]);
            break
        end
    end


    writestruct(cfg, cfg_file, 'FileType','json');
    if ~exist('regenerate_env', 'var') || regenerate_env == 1
        generate_control_environment(cfg, folder);
    end
end
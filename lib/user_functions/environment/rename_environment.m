function new_path = rename_environment(env_name, new_name)
    
    env_path = which(env_name);
    if isempty(env_path)
        error(strcat('Environment "', env_path, '" cannot be found on path'));
    end

    folder = fileparts(env_path);
    
    cfg = load_env_metadata(folder);    
    cfg.Name = new_name;
    save_env_metadata(folder, cfg);

    % rename_env_file(folder, strcat(env_name, '.cse'), strcat(new_name, '.cse'));
    % rename_env_file(folder, strcat(env_name, '.slx'), strcat(new_name, '.slx'));
    % rename_env_file(fullfile(folder, 'autogen'), strcat(env_name, '.mat'), strcat(new_name, '.mat'));
    % rename_env_file(fullfile(folder, 'autogen'), strcat(env_name, '_bus_types.sldd'), strcat(new_name, '_bus_types.sldd'));
    par_folder = fileparts(folder);
    
    new_path = fullfile(par_folder, new_name);

    rmsource_environment(env_name);
    movefile(fullfile(folder, env_name), fullfile(folder, new_name));
    movefile(folder, fullfile(par_folder, new_name));
    source_environment(fullfile(par_folder, new_name))
end



function rename_env_file(folder, old_file, new_file)
    movefile(fullfile(folder, old_file), fullfile(folder, new_file));
end
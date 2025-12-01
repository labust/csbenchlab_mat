function load_environment(env_name, varargin)
  
    file_path = which(strcat(env_name, '.slx'));
    env_path = get_env_path(env_name);
    if ~exist(file_path, 'file')
        error("Environment not on path");
    end

    open_system(file_path);

    source_environment(env_path);

end
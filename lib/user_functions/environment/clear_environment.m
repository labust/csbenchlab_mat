function clear_environment(env_name, varargin)

    pa = @BlockHelpers.path_append;
    if nargin == 2 
        options = varargin{1};
    elseif nargin > 2
        options = ControllerOptions(varargin{:});
    else
        options.RegenerateEnv = 1;
    end

    env_path = which(env_name);
    if isempty(env_path)
        error(strcat('Environment "', env_path, '" cannot be found on path'));
    end

    folder = fileparts(env_path);
    
    cfg_file = pa(folder, 'config.json');
    cfg = readstruct(cfg_file);
    
    if isfield(cfg, 'Controllers')
        cfg = rmfield(cfg, 'Controllers');
    end

    writestruct(cfg, cfg_file, 'FileType','json');

    if options.RegenerateEnv == 1
        generate_control_environment(cfg, folder);
    end

end
function add_controller(env_name, varargin)
    
    if nargin == 2 
        options = varargin{1};
    elseif nargin > 2
        options = ControllerOptions(varargin{:});
    end

    env_path = which(env_name);
    if isempty(env_path)
        error(strcat('Environment "', env_path, '" cannot be found on path'));
    end
    folder = fileparts(env_path);
    cfg = load_env_cfg(folder);

    % turn off warning on next line
    
    opts = options_as_struct(options);
    if ~isfield(cfg, 'Controllers') || isempty(cfg.Controllers)
        cfg.Controllers = opts;
    else
        for i=1:length(cfg.Controllers)      
            if strcmp(cfg.Controllers(i).Id, opts.Id)
                cfg.Controllers(i) = opts;
                break
            end
            if i == length(cfg.Controllers)
                cfg.Controllers(end+1) = opts;
            end
        end
    end

    save_params_struct(folder, opts);

    save_env_cfg(folder, cfg);
    if options.RegenerateEnv == 1
        generate_control_environment(cfg, folder);
    end


end
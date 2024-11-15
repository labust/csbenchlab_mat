function add_controller(env_name, varargin)
    
    pa = @BlockHelpers.path_append;
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
    
    cfg_file = pa(folder, 'config.json');
    cfg = readstruct(cfg_file);

    % turn off warning on next line
    warning('off', 'MATLAB:structOnObject'); 
    opts = struct(options);
    warning('on', 'MATLAB:structOnObject');
    if ~isfield(cfg, 'Controllers') || isempty(cfg.Controllers)
        cfg.Controllers = opts;
    else
        for i=1:length(cfg.Controllers)      
            if strcmp(cfg.Controllers(i).Name, opts.Name)
                cfg.Controllers(i) = opts;
                break
            end
            if i == length(cfg.Controllers)
                cfg.Controllers(end+1) = opts;
            end
        end
    end


    writestruct(cfg, cfg_file, 'FileType','json');

    if options.RegenerateEnv == 1
        generate_control_environment(cfg, folder);
    end


end
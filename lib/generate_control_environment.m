function handle = generate_control_environment(folder_path, system_instance, ids)
    % Generates a new simulink environment for testing the controller
    % behavior

    %   An optional second argument can be used to specify the path where
    %   to generate the simulink model
    %   Make sure that Params structs defined bellow are defined in the
    %   workspace
    
%   env_info : struct
%        Name: string - Name of the environment (simulink model)
%        Ts: double - simulation sampling time
%        start_time: double
%        end_time (optional, set to reference duration): double
%        system_info: struct
%           system: struct
%               ClassName: class Name of the system to use
%               Name (defaults to ClassName): string
%               Params: struct - struct layout description is defined in
%                   class
%        controller_info: struct
%           controllers: array[struct]
%               IsComposable (optional): bool
%               Components (if IsComposable == 1): array[struct]
%                   ClassName: class Name of the controller component
%                   Name: string
%                   Path: string
%                   Params: struct layout description is defined in
%                       class
%                   Mux: struct
%                       Input: array[int]
%                       Output: array[int]
%               ClassName: class Name of the controller to use
%               Name: string
%               Path: string
%               Mux (if IsComposable == 0): struct
%                   Input: array[int]
%                   Output: array[int]
%               Params (if IsComposable == 0): struct - struct layout description is defined in
%                   class
%        refgen_info: struct
%            reference: timeseries, or matrix

    if ~exist('ids', 'var')
        ids = [];
    end

    if ~exist('system_instance', 'var')
        system_instance = -1;
    end
    
    % create path if given as optional argument
    env_info = load_env_data(folder_path, 1);
    if ischar(ids)
        ids = string(ids);
    end
    if ~isempty(ids)
        k = 1;
        for i=1:length(ids)
            idx = arrayfun(@(y) strcmp(ids(i), y.Id), env_info.Controllers);
            if ~any(idx)
                continue
            end
            idx = find(idx);
            ctls(k) = env_info.Controllers(idx);
            k = k + 1;
        end
        env_info.Controllers = ctls;
    end

    if isnumeric(system_instance) && system_instance <= 0 ...
        || strempty(system_instance)
        if length(env_info.System) > 1
            error("Cannot determine system instance.");
        else
            system_instance = env_info.System.Id;
        end
    end
    if isnumeric(system_instance)
        indices = system_instance;
    else
        indices = arrayfun(@(x) strcmp(x.Id, system_instance), env_info.System);
    end
    env_info.System = env_info.System(indices);

    if env_info.Metadata.Ts <= 0
        error('Environment step size should be positive');
    end
    name = env_info.Metadata.Name;
    env_params = load_env_param_struct(folder_path, env_info);
    assignin('base', matlab.lang.makeValidName(strcat(name, '_params')), env_params);
    
    % [t, msg] = validate_env_cfg(env_info);
    % if t > 0
    %     error(msg);
    % end

    try
        model_path = strcat(folder_path, '/', name, '.slx');
        exists = exist(model_path, 'file');
        if ~isempty(exists)
            close_system(name, 0);
            delete(model_path);
        end
    catch
    end
    

    handle = new_system(name);
    try
        if is_valid_field(env_info, 'Controllers')
    
            % Add blocks to model
            GeneratorHelpers.add_time_handler(name);
            blocks.refgen = GeneratorHelpers.add_reference_generator(name);
            blocks.systems = GeneratorHelpers.generate_systems(name, ...
                env_info.System, length(env_info.Controllers));
        
            blocks.controllers = GeneratorHelpers.generate_controllers(name, env_info.Controllers, blocks.systems.dims);
            GeneratorHelpers.bus_connect(name, blocks);

            blocks.cs_blocks = getfullname(get_model_blocks_with_tag(name, '__cs'));

            
            % configure model
            if ~exist(fullfile(folder_path, 'autogen'), 'dir')
                mkdir(fullfile(folder_path, 'autogen'));
            end

            save(fullfile(folder_path, 'autogen', strcat(name, '.mat')), 'env_info', 'blocks');
            set_param(handle, 'PostLoadFcn', 'on_model_load');
            set_param(handle, 'StartFcn', 'on_model_start');
            set_param(handle, 'PostSaveFcn', 'on_model_save');
            set_param(handle, 'StopFcn', 'on_simulation_done');
        end

        set_param(handle, 'FixedStep', num2str(env_info.Metadata.Ts), ...
            'SolverType', 'Fixed-step');
    
        save_system(name, strcat(folder_path, '/', name)); 
        close_system(name);
        addpath(strcat(folder_path));
        open_system(name);
    catch e
        save_system(name, strcat(folder_path, '/', name));
        close_system(name, 0);
        % new_system(name);
        % save_system(name, strcat(folder_path, '/', name)); 
        % close_system(name, 0);
        rethrow(e);
    end
end


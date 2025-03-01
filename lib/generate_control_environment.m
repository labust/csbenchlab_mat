function handle = generate_control_environment(env_info, folder_path)
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
   
    % create path if given as optional argument

    [t, msg] = validate_env_cfg(env_info);
    if t > 0
        error(msg);
    end
    
    name = env_info.Metadata.Name;
    try
        model_path = strcat(folder_path, '/', name, '.slx');
        exists = exist(model_path, 'file');
        if ~isempty(exists)
            close_system(name, 0);
            delete(model_path);
        end
    catch
    end
    if env_info.Metadata.Ts <= 0
        error('Environment step size should be positive');
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


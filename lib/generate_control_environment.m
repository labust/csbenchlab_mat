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

    try
        model_path = strcat(folder_path, '/', env_info.Name, '.slx');
        exists = exist(model_path, 'file');
        if ~isempty(exists)
            close_system(env_info.Name, 0);
            delete(model_path);
        end
    catch
    end
    handle = new_system(env_info.Name);
    % handle = gcbh;

    if is_valid_field(env_info, 'Controllers')

        % Add blocks to model
        GeneratorHelpers.add_time_handler(env_info.Name);
        blocks.refgen = GeneratorHelpers.add_reference_generator(env_info.Name, ...
            strcat(env_info.Name, '_refs.mat'));
        blocks.systems = GeneratorHelpers.generate_systems(env_info.Name, ...
            env_info.System, length(env_info.Controllers));
    
        blocks.controllers = GeneratorHelpers.generate_controllers(env_info.Name, env_info.Controllers, blocks.systems.dims);
        GeneratorHelpers.bus_connect(env_info.Name, blocks);
        
        % configure model
        save(strcat(folder_path, '/autogen/', env_info.Name, '.mat'), 'env_info', 'blocks');
        set_param(handle, 'PostLoadFcn', 'on_model_load');
        set_param(handle, 'PostSaveFcn', 'on_model_save');
        set_param(handle, 'StopFcn', 'on_simulation_done');
    end

    set_param(handle, 'FixedStep', num2str(env_info.Ts), ...
        'SolverType', 'Fixed-step');

    save_system(env_info.Name, strcat(folder_path, '/', env_info.Name)); 
    close_system(env_info.Name, 0);
    open_system(env_info.Name);
end


function setup_simulink_with_active_scenario(env_h, handle, active_scenario)
    hws = get_param(env_h, 'modelworkspace');
    name = get_param(handle, 'Name');
    env_name = get_param(env_h, 'Name');
    from_file_block = fullfile(env_name, name, 'ReferenceFile');
    set_param(from_file_block, 'FileName', active_scenario.Reference);

    blocks = hws.getVariable('gen_blocks');
    sys_params = get_component_params_from_block(blocks.systems.systems(1).Components.Path);

    % override system parameters with scenario params
    if ~isnumeric(sys_params) && ~isempty(fieldnames(sys_params))
        f_names = fieldnames(active_scenario.SystemParameterOverrides);
        sys_params_names = fieldnames(sys_params);
        if ~isempty(f_names)
            for i=1:length(f_names)
                name = f_names{i};
                has_name = sum(cellfun(@(x) strcmp(x, name), sys_params_names));
                if has_name
                    sys_params.(f_names{i}) = active_scenario.SystemParameterOverrides.(f_names{i});
                else
                    warning(strcat("Parameter ", name, " not defined for system."));
                end
            end
        end
    end
    active_scenario.SystemParams = sys_params;


    % set disturbances, if exist
    for i=1:length(blocks.systems.systems)
        full_file = fullfile(blocks.systems.systems(i).SignalSubsystem.Path, ...
            'CS Dist');
        h = get_param(full_file, 'Handle');
        if is_valid_field(active_scenario, 'Disturbance')
            info = active_scenario.Disturbance;
        else
            info = get_default_disturbance_info();
        end
        GeneratorHelpers.clear_component(h);
        dist = GeneratorHelpers.populate_disturbance(env_name, info, h);
        setup_simulink_component(dist.Components.Handle, env_name);
        set_component_params_map(env_name, info);
        setup_simulink_autogen_types_for_component(env_name, dist.Components.Handle);
        setup_extrinsic_functions_for_component(env_name, dist.Components.Handle);        
    end


    % set start time
    start_time = 0;
    if is_valid_field(active_scenario, 'StartTime')
        start_time = active_scenario.StartTime;
    end


    % set end time
    selected_reference = load(active_scenario.Reference);
    selected_reference = selected_reference.data;
    if is_valid_field(active_scenario, 'EndTime')
        end_time = active_scenario.EndTime;
    else
        end_time = selected_reference(1, end);
    end

    set_param(env_name, 'StartTime', num2str(start_time), ...
        'StopTime', num2str(end_time));


    % set global reference and active scenario
    global_reference = selected_reference(2:end, :);
    try
        hws.assignin('ActiveScenario', active_scenario);
        hws.assignin('GlobalReference', global_reference);
    catch e
    end
    setup_multiscenario(env_name, active_scenario, hws);

end

function info = get_default_disturbance_info()
    info.Lib = 'csbenchlab';
    info.PluginType = 'dist';
    info.Name = "nan";
    info.PluginName = 'ZeroNoise';
    info.Id = "-1";
end


function setup_multiscenario(env_name, active_scenario, hws)
    if is_valid_field(active_scenario, 'NumEvaluations')
        num_eval = active_scenario.NumEvaluations;
    end
    
    if num_eval <= 0
        num_eval = 1;
    end
    
    if num_eval > 1
        n_sim = simulink.multisim.Variable("n_sim", 1:1000);
        exhaustive = simulink.multisim.Exhaustive([n_sim]);
        d = simulink.multisim.DesignStudy(env_name, exhaustive);
        hws.assignin('simulation_description', d)
        % d.
    else
        hws.assignin('simulation_description', 0)
    end

    a = 5;
end
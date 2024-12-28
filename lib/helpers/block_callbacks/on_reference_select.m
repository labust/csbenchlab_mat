function on_reference_select
    pa = @BlockHelpers.path_append;
    handle = gcbh;

    env_name = gcs;
   

    % if no config, this is not an environment
    if ~is_env(env_name)
        return
    end

    env_h = get_param(env_name, 'Handle');
    hws = get_param(env_h, 'modelworkspace');
    mo = get_param(handle, 'MaskObject');
    name = get_param(handle, 'Name');
    
    selector_name = pa(env_name, name, 'Reference');

    scenarios = hws.getVariable('Scenarios');
    
    scenario_name = mo.Parameters(1).Value;
    active_scenario_idx = 0;
    for i=1:length(scenarios)
        if strcmp(scenario_name, scenarios(i).Name)
            active_scenario_idx = i;
            break
        end
    end
    if active_scenario_idx == 0 % if not found, set first one
        active_scenario_idx = 1;
    end
    active_scenario = scenarios(active_scenario_idx);

    set_param(selector_name, 'ActiveScenario', active_scenario.Reference);

    blocks = hws.getVariable('gen_blocks');
    sys_params = eval_component_params(blocks.systems.systems(1).Path);

    % override system parameters with scenario params
    f_names = fieldnames(active_scenario.Params);
    if ~isempty(f_names)
        for i=1:length(f_names)
            sys_params.(f_names(i)) = active_scenario.Params.(f_names(i));
        end
    end
    active_scenario.Params = sys_params;


    start_time = 0;
    if is_valid_field(active_scenario, 'StartTime')
        start_time = active_scenario.StartTime;
    end

    refs = load(pa(env_name, 'autogen', strcat(env_name, '_refs')));
    selected_reference = refs.(active_scenario.Reference);
    selected_reference = selected_reference{1};
    if is_valid_field(active_scenario, 'EndTime')
        end_time = active_scenario.EndTime;
    else
        end_time = selected_reference.Values.Time(end) * 1.02;
    end

  
    set_param(env_name, 'StartTime', num2str(start_time), ...
        'StopTime', num2str(end_time));


    try
        hws.assignin('ActiveScenario', active_scenario);
        hws.assignin('GlobalReference', selected_reference.Values.Data);
    catch e
    end

end
function on_scenario_select
    handle = gcbh;
    env_name = gcs;   

    % if no config, this is not an environment
    if ~is_env(env_name)
        return
    end

    env_h = get_param(env_name, 'Handle');
    hws = get_param(env_h, 'modelworkspace');
    mo = get_param(handle, 'MaskObject');
    

    scenarios = hws.getVariable('Scenarios');    
    blocks = hws.getVariable('gen_blocks');    
    env_info = hws.getVariable('env_info');


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
    setup_simulink_with_active_scenario(env_h, handle, active_scenario);

    setup_simulink_references(blocks, active_scenario);
    setup_simulink_reference_handlers(env_name, env_info.Controllers, blocks);
end

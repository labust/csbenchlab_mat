function setup_simulink_with_scenarios(env_name, blocks, info)
    
     selector_name = fullfile(blocks.refgen.Path, 'Reference');
     hws = get_param(env_name, 'modelworkspace');

     try
        scenario_name = get_param(selector_name, 'ActiveScenario');
        if ~isempty(scenario_name)
            return
        end
     catch
     end
    
    
    [~, sys_params] = get_component_params_from_env(env_name, info.System);
    
    env_data.system_params = sys_params;
    env_data.dt = info.Metadata.Ts;
    env_data.system_dims = blocks.systems.dims;
    env_path = fileparts(which(env_name));
    scenarios = eval_scenario_descriptions(env_path, env_data);
    assert(length(scenarios) == length(info.Scenarios), ...
        'Evaluated scenarios length is not consistent with environment scenarios');

    % merge scenario structs
    fns = fieldnames(scenarios);
    for i=1:length(info.Scenarios)
        for j=1:length(fns)
            info.Scenarios(i).(fns{j}) = scenarios(i).(fns{j});
        end
    end
    hws.assignin('Scenarios', info.Scenarios);   
    hws.assignin('env_info', info);   
end


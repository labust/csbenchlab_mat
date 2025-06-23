function active_scenario = setup_simulink_with_scenarios(env_name, blocks)
    
     selector_name = fullfile(blocks.refgen.Path, 'Reference');
     hws = get_param(env_name, 'modelworkspace');

     try
        hws.getVariable('Scenarios');
        scenario_name = get_param(selector_name, 'ActiveScenario');
        if ~isempty(scenario_name)
            return
        end
     catch
     end


    env_path = fileparts(which(env_name));
    scenarios = load_env_scenarios(env_path);

    active_scenario_idx = 1;
    active_scenario = scenarios(active_scenario_idx);

    hws.assignin('Scenarios', scenarios);
    hws.assignin('ActiveScenario', active_scenario);
   
end


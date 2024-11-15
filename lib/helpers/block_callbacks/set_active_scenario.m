function set_active_scenario(env_name, active_scenario)
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
        end_time = selected_reference.Time(end) * 1.02;
    end

  
    set_param(env_name, 'StartTime', num2str(start_time), ...
        'StopTime', num2str(end_time));


    try
        hws.assignin('active_scenario', active_scenario);
        hws.assignin('GlobalReference', selected_reference.Data);
    catch e
    end
end


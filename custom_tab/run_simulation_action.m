function run_simulation_action(cb_info)
    env_name = gcs; 

    hws = get_param(env_name, 'modelworkspace');   

    function trigger_tab_filters()
        hws.assignin('runsim_trigger', 1);
    end


    function on_stop(~, ~)
        hws.clear('runsim_trigger');
    end

    trigger_tab_filters();
    t = timer;
    t.StartDelay = 0.25;
    t.TimerFcn = @(~, ~) run_simulation(env_name);
    t.StopFcn = @on_stop;
    t.start();
end


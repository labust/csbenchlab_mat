function on_simulation_done_impl()
    env_name = gcs;
    runIds = Simulink.sdi.getAllRunIDs;
    runId = runIds(end);
    
    last_run = Simulink.sdi.getRun(runId);
    
    if ~strcmp(last_run.Model, env_name)
        % warning("Last run is not an environment.");
        return
    end

    try
        plot_params = evalin('base', 'plot_params');
    catch
        plot_params = struct;
    end
    
    on_simulation_successful(env_name, last_run, do_plot_data(plot_params, last_run));
end


function t = do_plot_data(plot_params, last_run)
    t = 0;
    if isfield(plot_params, 'plot')
        t = plot_params.plot;
        return;
    end
    if strcmp(last_run.Status, 'ReachedStopTime')
        t = 1;
    end
end
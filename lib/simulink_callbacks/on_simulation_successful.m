function result = on_simulation_successful(env_name, run_id, plot_data)

    handle = get_param(env_name, 'Handle');
    
    folder = fileparts(which(env_name));
    if ~exist(fullfile(folder, strcat(env_name, '.cse')), 'file')
        return
    end

    Ts = get_param(handle, 'FixedStep');
    loaded = load(fullfile(folder, 'autogen', strcat(env_name, '.mat')));

    ref = getSignalsByName(run_id, 'Reference').Values;
    
    out = struct;
    for i=1:length(loaded.blocks.controllers)
        c = loaded.blocks.controllers(i);
        try
            u_sig_name = strcat(c.Name, '_u');
            y_sig_name = strcat(c.Name, '_y');
            log_sig_name = strcat(c.Name, '_log');
            eval(strcat(u_sig_name, ' = getSignalsByName(run_id, "', ...
                u_sig_name, '").Values;'));
            eval(strcat(y_sig_name, ' = getSignalsByName(run_id, "', ...
                y_sig_name, '").Values;'));
            eval(strcat(log_sig_name, ' = getSignalsByName(run_id, "', ...
                log_sig_name, '").Values;'));
    
            eval(strcat('out.', c.Name, '.u = ', u_sig_name, ';'));
            eval(strcat('out.', c.Name, '.y = ', y_sig_name, ';'));
            eval(strcat('out.', c.Name, '.log = ', log_sig_name, ';'));
        catch
            warning(strcat("Simulation data not obtained for controller ", c.Name, "."));
        end
    end
    result.Ts = str2double(Ts);
    result.ref = ref;
    result.signals = out;

    result.metrics = calculate_result_metrics_simulink(result);
    
    save(fullfile(folder, 'results.mat'), 'result');
    assignin('base', 'sim_result', result);
    
    if plot_data
        eval_env_metrics(folder, result, fullfile(folder, 'results.mat'));
    end
    
end


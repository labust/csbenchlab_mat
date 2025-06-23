function on_simulation_successful(env_name, run_id, plot_data)

    handle = get_param(env_name, 'Handle');
    
    folder = fileparts(which(env_name));
    if ~exist(fullfile(folder, strcat(env_name, '.cse')), 'file')
        return
    end

    Ts = get_param(handle, 'FixedStep');
    loaded = load(fullfile(folder, 'autogen', strcat(env_name, '.mat')));

    ref = getSignalsByName(run_id, 'Reference').Values;
    out.ref = ref;

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
    
            eval(strcat('out.u.', c.Name, ' = ', u_sig_name, ';'));
            eval(strcat('out.y.', c.Name, ' = ', y_sig_name, ';'));
            eval(strcat('out.log.', c.Name, ' = ', log_sig_name, ';'));
        catch
            warning(strcat("Simulation data not obtained for controller ", c.Name, "."));
        end
    end
    out.Ts = str2double(Ts);
    
    out.metrics = calculate_result_metrics(out);
    
    save(fullfile(folder, 'results.mat'), 'out');
    assignin('base', 'sim_result', out);
    
    eval_fun = strcat(env_name, '_eval_metrics');
    if plot_data
        metrics = load_env_metrics(env_name);    
        close all;
        for i=1:length(metrics)
            
            if ~is_valid_field(metrics(i), 'Type') && ~is_valid_field(metrics(i), 'Callback')
                error(['Cannot create metric. Metric object should have "Type" or "Callback"' ...
                    'field specified.']);
            end

            f = figure;

            if is_valid_field(metrics(i), 'Type')
                path = which(metrics(i).Type);
        
                if ~exist(path, 'file')
                    error(strcat('Cannot create metric. Function with name "', ...
                        metrics(i).Type, '" does not exist'));
                end
    
                eval(strcat(eval_fun, '(', metrics(i).Type, ', out, metrics(i), f)'));
            end

            try
                if is_valid_field(metrics(i), 'Callback')
                    eval(strcat(eval_fun, '("', metrics(i).Callback, '", out, metrics(i), f)'));
                end
            catch e
                disp(strcat("Error in computing metric '", metrics(i).Name, "'."));
                disp(e);
            end
        end
    end
end


function on_simulation_successful(env_name, run_id, plot_data)


    pa = @BlockHelpers.path_append;
    handle = get_param(env_name, 'Handle');
    
    folder = fileparts(which(env_name));
    if ~exist(pa(folder, 'config.json'), 'file')
        return
    end

    Ts = get_param(handle, 'FixedStep');
    loaded = load(pa(folder, 'autogen', strcat(env_name, '.mat')));

    ref = getSignalsByName(run_id, 'Reference').Values;
    out.ref = ref;

    for i=1:length(loaded.blocks.controllers)
        c = loaded.blocks.controllers(i);

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
    end
    out.Ts = str2double(Ts);
    
    out.metrics = calculate_result_metrics(out);
    
    save(pa(folder, 'results.mat'), 'out');
    assignin('base', 'sim_result', out);

    if plot_data
        plots = load(pa(folder, 'autogen', strcat(env_name, '_plots.mat')));
        plots = plots.Plots;
    
        close all;
        for i=1:length(plots)
            
            if ~is_valid_field(plots(i), 'Type') && ~is_valid_field(plots(i), 'Callback')
                error(['Cannot create plot. Plot object should have "Type" or "Callback"' ...
                    'field specified.']);
            end

            f = figure;

            if is_valid_field(plots(i), 'Type')
                path = which(plots(i).Type);
        
                if ~exist(path, 'file')
                    error(strcat('Cannot create plot. Function with name "', ...
                        plots(i).Type, '" does not exist'));
                end
    
                eval(strcat(plots(i).Type, '(out, plots(i), f)'));
            end

            try
                if is_valid_field(plots(i), 'Callback')
                    eval(strcat(plots(i).Callback, '(out, plots(i), f)'));
                end
            catch e
                disp("Error in ploting data.");
                disp(e);
            end
            
            
        end
    end
end


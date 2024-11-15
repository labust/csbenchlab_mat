function ret = evaluate_predictive_controller(controller, model, y_ref, Ts, varargin)

    plot_values = 0;
        % Loop through the parameter names and not the values.
    for i = 1:2:length(varargin)

        if isstring(varargin{i})
            as_char = convertStringsToChars(varargin{i});
        else
            as_char = varargin{i};
        end
        
        value = varargin{i+1};
        switch as_char
            case 'D_y' 
                controller.params.D_y = value;
            case 'D_u'
                controller.params.D_u = value;
            case 'EndPoint'
                controller.params.end_point = value;
            case 'PlotValues'
                plot_values = 1;
            otherwise
                warning(['Unexpected parameter name "', as_char, '"']);
        end
    end

    controller = controller.configure();
    idx = controller.data.idx;
    result = simulate_controller(controller, model, y_ref, Ts);
       
    y_pred = result.optim(:, idx.y.r);
    
    % diffs(i) = sum(abs(y_act - yv))/length(y_act);
    diffs = max(abs(y_pred - result.hotizon_pred), [], 2);
    horizon_mse = sum((y_pred - result.hotizon_pred).^2, 2) / length(y_pred);
    
    ret.result = result;
    ret.horizon_max_diffs = diffs;
    ret.horizon_max_avg = sum(diffs) / length(diffs);
    ret.horizon_mse = horizon_mse;
    ret.horizon_mse_avg = sum(horizon_mse) / length(horizon_mse);

    
    abs_diff = abs(y_ref - result.y);

    ret.mse = sum((y_ref - result.y).^2) / length(result.y);
    ret.mse_n = ret.mse / (controller.params.y_max)^2;
    ret.mae = sum(abs_diff) / length(result.y);
    ret.mae_n = ret.mae / controller.params.y_max;
    ret.power = sum(result.u.^2) / length(result.u);
    ret.power_n = ret.power / controller.params.u_max^2;
    if max(y_ref) > 0
        ret.overshoot = max(max(result.y) - max(y_ref), 0);
    else
        ret.overshoot = max(min(result.y) - min(y_ref), 0);
    end

    ret.overshoot_n = ret.overshoot / max(abs(y_ref));
    
    
    t_1p_v = 1 - (abs_diff <= 0.01 * y_ref);
    t_5p_v = 1 - (abs_diff <= 0.05 * y_ref);
    rt_v = abs(result.y) <= 0.63 * abs(y_ref) ;

    ret.t_1p = sum(t_1p_v) * Ts;
    ret.t_5p = sum(t_5p_v) * Ts;
    ret.rise_t = sum(rt_v) * Ts;
    
    if plot_values > 0
        figure;
        plot(result.t, y_ref);
        hold on;
        plot(result.t, result.y);
        legend('y\_ref', 'y')
    end

end

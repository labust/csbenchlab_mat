function metrics = calculate_result_metrics(out)

    ns = fieldnames(out.y);
    metrics = struct;
    for i=1:length(ns)
        y = out.y.(ns{i}).Data;
        u = out.u.(ns{i}).Data;
        

        % diffs(i) = sum(abs(y_act - yv))/length(y_act);
        % diffs = max(abs(y_pred - result.hotizon_pred), [], 2);
        % horizon_mse = sum((y_pred - result.hotizon_pred).^2, 2) / length(y_pred);
        
        % ret.result = result;
        % ret.horizon_max_diffs = diffs;
        % ret.horizon_max_avg = sum(diffs) / length(diffs);
        % ret.horizon_mse = horizon_mse;
        % ret.horizon_mse_avg = sum(horizon_mse) / length(horizon_mse);
        
  

        y_ref = out.ref.Data;
        abs_diff = abs(y_ref - y);
    
        ret.mse = sum((y_ref - y).^2) / length(y);
        ret.mae = sum(abs_diff) / length(y);
        ret.power = sum(u.^2) / length(u);
        if max(y_ref, [], "all") > 0
            ret.overshoot = max(max(y) - max(y_ref), 0);
        else
            ret.overshoot = max(min(y) - min(y_ref), 0);
        end
    
        ret.overshoot_n = ret.overshoot ./ max(abs(y_ref));
        
        
        t_1p_v = 1 - (abs_diff <= 0.01 * y_ref);
        t_5p_v = 1 - (abs_diff <= 0.05 * y_ref);
        rt_v = abs(y) <= 0.63 * abs(y_ref) ;
    
        ret.t_1p = sum(t_1p_v) .* out.Ts;
        ret.t_5p = sum(t_5p_v) .* out.Ts;
        ret.rise_t = sum(rt_v) .* out.Ts;

        metrics.(ns{i}) = ret;

    end

end


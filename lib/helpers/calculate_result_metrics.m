function ret = calculate_result_metrics(y_ref, y, u, Ts)
   
    if ~isequal(size(y_ref), size(y))
        
        if isequal(size(y_ref), flip(size(y)))
            y = y';
        else
            error(strcat('Cannot calculate metrics. size(y_ref) = ', ...
                mat2str(size(y_ref))), ...
                ', size(y) = ', mat2str(size(y)));
        end
    end

    abs_diff = abs(y_ref - y);

    ret.mse = sum((y_ref - y).^2) / length(y);
    ret.mae = sum(abs_diff) / length(y);
    ret.power_avg = sum(u.^2) / length(u);
    ret.power = sum(u.^2);

    refs = any(y_ref);
    ref_dims = find(refs);

    ret.qi = containers.Map('KeyType', 'int32', 'ValueType', 'any');
    for j=1:length(ref_dims)
        idx = ref_dims(j);


        [is_steps, intervals] = identify_signal_steps(y_ref(:, idx), 5);

        if ~is_steps
            continue
        end
        
        step_metrics = struct;
        for k=1:height(intervals)
            interval = intervals(k, :);
            y_s = y(interval(1):interval(2), idx);
            yref_s = y_ref(interval(1):interval(2), idx);

            if max(yref_s, [], "all") > 0
                step_metrics(k).overshoot = max(max(y_s) - max(yref_s), 0);
            else
                step_metrics(k).overshoot = max(min(y_s) - min(yref_s), 0);
            end

            
            u_s  = u(interval(1):interval(2), :);
            step_metrics(k).overshoot_n = step_metrics(k).overshoot ./ max(abs(yref_s));
            
            abs_diff_s = abs(yref_s - y_s);
            step_metrics(k).mse = sum((yref_s - y_s).^2) / length(y_s);
            step_metrics(k).mae = sum(abs_diff_s) / length(y_s);
            step_metrics(k).power = sum(u_s.^2) / length(u_s);
            
            t_1p_v = (abs_diff_s <= 0.01 * yref_s);
            t_5p_v = (abs_diff_s <= 0.05 * yref_s);
            rt_v = abs(y_s) <= 0.63 * abs(yref_s) ;

            tol = ceil(length(yref_s) * 0.1); % max 5% samples are outside
        
            step_metrics(k).t_1p = calculate_time_with_sample_tollerance(t_1p_v, Ts, tol);
            step_metrics(k).t_5p = calculate_time_with_sample_tollerance(t_5p_v, Ts, tol);
            step_metrics(k).rise_t = sum(rt_v) .* Ts;
        end
        ret.qi(idx) = step_metrics;
    end
end

function t = calculate_time_with_sample_tollerance(time_v, Ts, tollerance)
    indices = find(time_v, tollerance);
    if isempty(indices)
        t = length(time_v) * Ts;
        return
    end
    errors = 0;
    first = indices(1);
    for i=length(time_v):-1:first
        if time_v(i) == 0
            errors = errors + 1;
        end
        if errors > tollerance
            subvec = time_v(i:end);
            if sum(subvec) > length(subvec) / 2
                t = i * Ts;
            else
                t = length(time_v) * Ts;
            end
            return
        end
    end
    t = first * Ts;
end



function [is_steps, intervals] = identify_signal_steps(signal, duration)
    is_steps = 1;
    d = diff(signal);

    if ~any(d)
        intervals = [1, length(signal)];
        return
    end

    f = [1; find(d)];
    intervals = zeros(0, 2);
    for i=2:length(f)
        if (f(i) - f(i-1) < duration)
            is_steps = 0;
            intervals = 0;
            break
        end
        
        if signal(int32((f(i-1) + f(i))/2)) ~= 0
            intervals(end+1, :) = [f(i-1), f(i)];
        end
    end
    
end
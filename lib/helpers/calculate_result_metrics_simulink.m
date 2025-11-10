function metrics = calculate_result_metrics_simulink(out)

    ns = fieldnames(out.y);
    metrics = struct;
    for i=1:length(ns)
        y = squeeze(out.y.(ns{i}).Data);
        u = out.u.(ns{i}).Data;

        y_ref = out.ref.Data;
       
        if ~isequal(size(y_ref), size(y))
            
            if isequal(size(y_ref), flip(size(y)))
                y = y';
            else
                error(strcat('Cannot calculate metrics. size(y_ref) = ', ...
                    mat2str(size(y_ref))), ...
                    ', size(y) = ', mat2str(size(y)));
            end
        end
        
       metrics.(ns{i}) = calculate_result_metrics(y_ref, y, u, out.Ts);

    end

end



function [is_steps, intervals] = identify_signal_steps(signal, duration)
    is_steps = 1;
    d = diff(signal);

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
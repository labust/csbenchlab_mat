function metrics = evaluate_predictive_controller(controller, model, y_ref, Ts, varargin)

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

    controller = controller.configure(0);
    result = simulate_controller(controller, model, y_ref, Ts);

    metrics = calculate_result_metrics(result.y_ref, result.y, result.u, Ts);

    if plot_values > 0
        figure(1);
        plot(result.t, y_ref);
        hold on;
        plot(result.t, result.y);
        legend('y\_ref', 'y')
    end

end

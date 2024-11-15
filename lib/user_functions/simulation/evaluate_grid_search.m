function result = evaluate_grid_search(experiment_params, optim_params)
    

    fields = fieldnames(optim_params);
    
    fields_arr = string(fields);
    
    v = cell(length(fields), 1);
    for i=1:length(fields)
        n = fields{i};
        v{i} = optim_params.(n).range;
    end

    
    grid = cell(1, length(fields));
    [grid{:}] = meshgrid(v{:});

    prod_dim = numel(grid{1});

    disp(strcat('Total evaluations: ', num2str(prod_dim)));

    controller = experiment_params.controller;

    model = experiment_params.model;
    y_ref = experiment_params.y_ref;
    Ts = experiment_params.Ts;
    
    metrics = ["MSE", "MAE", "T_1p", "T_5p", "T_rise", "Power_n", "Overshoot", "Mix"];
    experiment_details = ["Trial", "Status", "Progress", "Elapsed Time"];

    param_tab = table('Size', [1, length(fields_arr)], ...
        'VariableNames', fields_arr, ...
        'VariableTypes', repmat("double", [length(fields_arr), 1]));

    metrics_tab = table('Size', [1, length(metrics)], ...
        'VariableNames', metrics, ...
        'VariableTypes', repmat("double", [length(metrics), 1]));

    experiment_tab = table('Size', [1, length(experiment_details)], ...
        'VariableNames', experiment_details, ...
        'VariableTypes', repmat("double", [length(experiment_details), 1]));


    result = table( ...
        repmat(experiment_tab, [prod_dim, 1]), ...
        repmat(param_tab, [prod_dim, 1]), ...
        repmat(metrics_tab, [prod_dim, 1]), ...
        'VariableNames', ["Experiment Details", "Hyperparameters", "Metrics"]);


    for i=1:prod_dim
        
        controller = controller.reset();
        for j=1:length(fields)
            controller.params.(fields{j}) = grid{j}(i);
            result.Hyperparameters{i, j} = grid{j}(i);
        end
        tic;
        control_result = evaluate_predictive_controller(controller, model, y_ref, Ts, 0);
        exe_time = toc;
        
        result{i, "Experiment Details"}.("Elapsed Time") = exe_time;
        result{i, "Experiment Details"}.("Progress") = 100;
        result{i, "Experiment Details"}.("Trial") = i;
        result{i, "Experiment Details"}.("Status") = 1;
        


        result.Metrics.MSE(i) = control_result.mse;
        result.Metrics.MAE(i) = control_result.mae;
        result.Metrics.T_1p(i) = control_result.t_1p;
        result.Metrics.T_5p(i) = control_result.t_5p;
        result.Metrics.T_rise(i) = control_result.rise_t;
        result.Metrics.Power_n(i) = control_result.power_n;
        result.Metrics.Overshoot(i) = control_result.overshoot_n;
        result.Metrics.Mix(i) = control_result.t_1p - control_result.mse*10 - 50*control_result.overshoot_n;
        
        disp(strcat("Progress: ", num2str(i), "/", num2str(prod_dim)));
    end
end


function result = evaluate_grid_search(ctl, model, y_ref, Ts, optim_params, use_parallel)
    

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
   

    if use_parallel
        clear('iIncrementWaitbar');
        dq = parallel.pool.DataQueue;
        afterEach(dq, @(varargin) iIncrementWaitbar(prod_dim));
        parfor i=1:prod_dim
            result(i, :) = eval_one(ctl, model, y_ref, Ts, fields, i, grid, prod_dim, result(i, :));
            send(dq, i);
        end
    end

    for i=1:prod_dim
        result(i, :) = eval_one(ctl, model, y_ref, Ts, fields, i, grid, prod_dim, result(i, :));
        disp(strcat("Progress: ", num2str(i), "/", num2str(prod_dim)));

    end
end

function iIncrementWaitbar(end_num)
    persistent cnt
    if isempty(cnt)
        cnt = 0;
    end
    cnt = cnt + 1;
    disp(strcat("Progress: ", num2str(cnt), "/", num2str(end_num)));
end


function result = eval_one(controller, model, y_ref, Ts, fields, i, grid, prod_dim, result)
    controller = controller.reset();
    for j=1:length(fields)
        controller.params.(fields{j}) = grid{j}(i);
        result.Hyperparameters.(fields{j}) = grid{j}(i);
    end
    
    tic;
    control_result = evaluate_predictive_controller(controller, model, y_ref, Ts);
    exe_time = toc;
    
    result.("Experiment Details").("Elapsed Time") = exe_time;
    result.("Experiment Details").("Progress") = 100;
    result.("Experiment Details").("Trial") = i;
    result.("Experiment Details").("Status") = 1;


    result.Metrics.MSE = control_result.mse;
    result.Metrics.MAE = control_result.mae;
    result.Metrics.Power_n = control_result.power_avg;
    if ~isempty(control_result.qi)
        result.Metrics.T_1p = control_result.qi(1).t_1p;
        result.Metrics.T_5p = control_result.qi(1).t_5p;
        result.Metrics.T_rise = control_result.qi(1).rise_t;
        result.Metrics.Overshoot = control_result.qi(1).overshoot_n;
        result.Metrics.Mix = control_result.qi(1).t_1p - control_result.qi(1).mse *10 - 50*control_result.qi(1).overshoot_n;
    end
end

function eval_env_metrics(env_path, results, results_path)

    script_path = fullfile(CSPath.get_app_python_src_path(), 'm_scripts',...
        'eval_metrics.py');

    py_metrics = run_py_file(script_path, "result", '--results-path', results_path, '--env-path', env_path);
    py_metrics = jsondecode(char(py_metrics));
    if ~iscell(py_metrics)
        py_metrics = {py_metrics(:)};
    end
    for i=1:length(py_metrics)
        el = py_metrics{1};
        if is_valid_field(el, 'external_function__') && is_valid_field(el, 'backend') ...
                && strcmp(el.backend, 'm')
            try
                plot_cfg.Params = el.kwargs;
                eval(strcat(el.function, '(results, plot_cfg);'));
            catch
                warning(strcat("Cannot evaluate metric '", splits{2}, "'."));
                rethrow;
            end
        end
    end
end


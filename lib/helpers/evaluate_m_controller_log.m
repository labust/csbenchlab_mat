function log = evaluate_m_controller_log(class_name, lib_name, data)
    log_func = @function_handle;
    log_func = get_m_controller_log_function_handle(class_name, lib_name);
    log = log_func(data);
end


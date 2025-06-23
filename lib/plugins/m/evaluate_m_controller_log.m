function log = evaluate_m_controller_log(pid, iid, data)
    log_func = @function_handle;
    [class_name, lib_name] = decode_plugin_id(pid);
    log_func = get_m_controller_log_function_handle(class_name, lib_name);
    log = log_func(data);
end


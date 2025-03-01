function fh = get_m_controller_log_function_handle(class_name, lib_name)
    if strcmp(lib_name, "csbenchlab")
        fh = get_m_log_fh__csbenchlab(class_name);
    elseif strcmp(lib_name, "data_driven_lib")
        fh = get_m_log_fh__data_driven_lib(class_name);
    elseif strcmp(lib_name, "local")
        fh = get_m_log_fh__local(class_name);
    elseif strcmp(lib_name, "marine_lib")
        fh = get_m_log_fh__marine_lib(class_name);
    else
        error("Unknown library")
    end
end
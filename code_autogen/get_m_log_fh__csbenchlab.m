function fh = get_m_log_fh__csbenchlab(class_name)
    if strcmp(class_name, "Cascade PID")
        fh = @gen_create_logs__Cascade_PID;
    elseif strcmp(class_name, "MPC")
        fh = @gen_create_logs__MPC;
    elseif strcmp(class_name, "PID")
        fh = @gen_create_logs__PID;
    elseif strcmp(class_name, "PID_V")
        fh = @gen_create_logs__PID_V;
    else
        error("Unknown class type")
    end
end
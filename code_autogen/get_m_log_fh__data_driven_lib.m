function fh = get_m_log_fh__data_driven_lib(class_name)
    if strcmp(class_name, "ATDeePC")
        fh = @gen_create_logs__ATDeePC;
    elseif strcmp(class_name, "ATDeePC_tune")
        fh = @gen_create_logs__ATDeePC_tune;
    elseif strcmp(class_name, "DeePC")
        fh = @gen_create_logs__DeePC;
    elseif strcmp(class_name, "DeePCPI")
        fh = @gen_create_logs__DeePCPI;
    elseif strcmp(class_name, "ExplicitDeePC")
        fh = @gen_create_logs__ExplicitDeePC;
    elseif strcmp(class_name, "ATDeePC_wrap")
        fh = @gen_create_logs__ATDeePC_wrap;
    else
        error("Unknown class type")
    end
end
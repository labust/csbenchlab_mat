function on_model_save_impl()
    curr_model = gcs;
    
    if isempty(curr_model)
        return
    end
    
    setup_simulink_autogen_types(curr_model);
    a = 5;
end
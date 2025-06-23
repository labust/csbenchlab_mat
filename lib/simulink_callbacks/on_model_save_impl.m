function on_model_save_impl()
    curr_model = gcs;
    
    if isempty(curr_model)
        return
    end
    env_path = fileparts(which(curr_model));
    loaded = load(fullfile(env_path, 'autogen', strcat(curr_model, '.mat')));
    setup_simulink_autogen_types(curr_model);

    trigger_model_callback(loaded.env_info, 'OnEnvSave');
end
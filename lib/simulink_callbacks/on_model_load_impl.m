function on_model_load_impl()
    pa = @BlockHelpers.path_append;
    curr_model = gcs;


    folder_path = fileparts(which(curr_model));
    loaded = load(pa(folder_path, 'autogen', strcat(curr_model, '.mat')));

    info = loaded.env_info;
    blocks = loaded.blocks;

    setup_simulink_components(curr_model, blocks);
    setup_simulink_extrinsic_functions(curr_model, info, blocks);
    [scenarios, active_scenario] = setup_simulink_with_scenarios(curr_model, blocks);
    setup_simulink_references(curr_model, info, blocks, scenarios, active_scenario)
    
    setup_simulink_reference_handlers(curr_model, info.Controllers, blocks);
    open_system(strcat(curr_model, '/RefGenerator'));

    % MUST BE AFTER THE SYSTEM IS OPENED BECAUSE 
    % LIBRARY LINK WOULD OVERRIDE AUTOGEN TYPES
    setup_simulink_autogen_types(curr_model, blocks);

    trigger_model_callback(info, 'OnEnvLoad');

end


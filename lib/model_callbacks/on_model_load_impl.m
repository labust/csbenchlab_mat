function on_model_load_impl()
    pa = @BlockHelpers.path_append;
    curr_model = gcs;


    folder_path = fileparts(which(curr_model));
    loaded = load(pa(folder_path, 'autogen', strcat(curr_model, '.mat')));

    info = loaded.env_info;
    blocks = loaded.blocks;

    scenarios_path = pa(folder_path, 'autogen', strcat(curr_model, '_refs.mat'));
    sig_editor_h = getSimulinkBlockHandle(pa(blocks.refgen.Path, 'Reference'));
    set_param(sig_editor_h, 'FileName', scenarios_path);

    setup_simulink_components(curr_model, blocks);
    setup_simulink_with_scenarios(curr_model, blocks);
    setup_scenario_const_horizon_reference(curr_model, info.Controllers, blocks);

    open_system(strcat(curr_model, '/RefGenerator'));

    % MUST BE AFTER THE SYSTEM IS OPENED BECAUSE 
    % LIBRARY LINK WOULD OVERRIDE AUTOGEN TYPES
    setup_simulink_autogen_types(curr_model);

end


function on_setup_components_impl()
    curr_model = gcs;

    ctls = get_model_blocks_with_tag(curr_model, '__cs_m_ctl');

    blocks.controllers = struct;
    blocks.controllers.Components = [];
    blocks.systems.systems = [];
    blocks.cs_blocks = mat2cell(ctls, ones(length(ctls), 1), 1);

    setup_simulink_components(curr_model, blocks);

    % MUST BE AFTER THE SYSTEM IS OPENED BECAUSE 
    % LIBRARY LINK WOULD OVERRIDE AUTOGEN TYPES
    setup_simulink_autogen_types(curr_model, blocks);

    % trigger_model_callback(info, 'OnEnvLoad');

end


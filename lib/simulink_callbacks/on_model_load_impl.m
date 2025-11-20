function on_model_load_impl()
    pa = @BlockHelpers.path_append;
    curr_model = gcs;

    folder_path = fileparts(which(curr_model));
    loaded = load(pa(folder_path, 'autogen', strcat(curr_model, '.mat')));

    info = loaded.env_info;
    blocks = loaded.blocks;
    hws = get_param(curr_model, 'modelworkspace');
    hws.assignin('gen_blocks', blocks);
    hws.assignin('env_name', curr_model);
    hws.assignin('old_params', struct);
    hws.assignin('env_info', info);

    set_component_params_path_for_ids(curr_model, info, hws);
    setup_simulink_type_dict(curr_model);
    setup_simulink_extrinsic_functions(curr_model, info, blocks);
    setup_simulink_with_scenarios(curr_model, blocks, info);

    open_system(strcat(curr_model, '/RefGenerator'));

    % MUST BE AFTER THE SYSTEM IS OPENED BECAUSE
    % LIBRARY LINK WOULD OVERRIDE AUTOGEN TYPES
    setup_simulink_autogen_types(curr_model, blocks);

    setup_environment_callbacks(curr_model, folder_path);

    trigger_model_callback(curr_model, info, 'on_load');
    disp('Environment loaded successfully');
end



function set_component_params_path_for_ids(env_name, info, hws)
    c = environment_components_it(info);
    map = dictionary;
    for i=1:length(c)
        if ~is_valid_field(c{i}.n, 'PluginType')
            continue
        end
        map = set_component_params_map(env_name, c{i}.n, map);
    end
    hws.assignin('id_to_params_path_map', map);
end
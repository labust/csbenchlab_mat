function setup_simulink_components(model_name, blocks)

    hws = get_param(model_name, 'modelworkspace');
    dictObj = hws.getVariable('gen_data_dictionary');
    type_dict = dictObj.getSection("Design Data");

    cs_comps = blocks.cs_blocks;

    for i=1:length(blocks.controllers)
        for j=1:length(blocks.controllers(i).Components)
            setup_component_mask_parameters(blocks.controllers(i).Components(j));
        end
    end

    for i=1:length(blocks.systems.systems)
        setup_component_mask_parameters(blocks.systems.systems(i).Components);
    end


    for i=1:length(cs_comps)
        type_dict = setup_simulink_component(cs_comps{i}, model_name, type_dict);
    end
    saveChanges(dictObj)
end

function setup_component_mask_parameters(c)
    params = get_component_params_from_block(c.Path);
    evaluate_mask_parameters_on_load(params, c.Path);
end
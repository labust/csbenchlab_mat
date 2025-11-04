function setup_simulink_components(model_name, blocks)
    pa = @BlockHelpers.path_append;

    folder_path = fileparts(which(model_name));
    
    bus_types_name = strcat(model_name, '_bus_types.sldd');

    sldd_f = pa(folder_path, 'autogen', bus_types_name);
    addpath(pa(folder_path, 'autogen'));
    Simulink.data.dictionary.closeAll('-discard');
    if exist(sldd_f, 'file')
        delete(sldd_f)
    end

    hws = get_param(model_name, 'modelworkspace');
    

    dictObj = Simulink.data.dictionary.create(sldd_f);
    type_dict = dictObj.getSection("Design Data");
    hws.assignin('gen_data_dictionary', dictObj);
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

    set_param(model_name, 'DataDictionary', bus_types_name);
    saveChanges(dictObj)
end

function setup_component_mask_parameters(c)
    params = get_component_params_from_block(c.Path);
    evaluate_mask_parameters_on_load(params, c.Path);
end
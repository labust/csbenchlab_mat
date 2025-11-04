function type_dict = setup_simulink_component(c, model_name, type_dict)
    hws = get_param(model_name, 'modelworkspace');
    
    save_dict = 0;
    if ~exist('type_dict', 'var')
        dictObj = hws.getVariable('gen_data_dictionary');
        type_dict = getSection(dictObj, "Design Data");
        save_dict = 1;
    end
    c_path = getfullname(c);
    typ = get_block_component_implementation(c_path);
    type_dict = ComponentManager.get(typ).setup_component(c_path, type_dict, hws);
    if save_dict
        saveChanges(dictObj);
    end
    
end


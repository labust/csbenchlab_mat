function setup_simulink_type_dict(model_name)
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
    hws.assignin('gen_data_dictionary', dictObj);
    set_param(model_name, 'DataDictionary', bus_types_name);
    saveChanges(dictObj)
end

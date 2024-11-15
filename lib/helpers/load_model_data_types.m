function [dictObj] = load_model_data_types(c_info, dictObj)

    model_name = split(c_info.Path, "/");
    model_name = model_name(1);

    for i=1:length(loaded_types)
        if strcmp(loaded_types{i}, model_name)
            return
        end
    end



    full_path = which(model_name);
    
    if isempty(full_path)
        return
    end

    dd_name = get_param(model_name, 'DataDictionary');

    if isempty(dd_name)
        return
    end

    modeldictObj = Simulink.data.dictionary.open(dd_name);
    type_dict = modeldictObj.getSection("Design Data");
    
    entries = type_dict.find;
    for i=1:length(entries)
        entry = entries(i);
    end

    a = 5;
    

end


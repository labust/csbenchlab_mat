function data = py_parse_component_data_json(data_json, initial_data)
    data = jsondecode(data_json);
    fns = fieldnames(data);
    for i=1:fieldnames(data)
        data.(fns{i}) = reshape(data.(fns{i}), size(initial_data.(fns{i})));
    end
end
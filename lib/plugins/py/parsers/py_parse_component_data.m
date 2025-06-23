function parsed = py_parse_component_data(data)
        
    fns = fieldnames(data);
    parsed = struct;
    for i=1:length(fns)
        n = fns{i};
        if isa(data.(n), 'py.SimpleNamespace')
            parsed.(n) = py_parse_component_data(data.(n));
        else
            parsed.(n) = double(data.(n));
        end
    end
end
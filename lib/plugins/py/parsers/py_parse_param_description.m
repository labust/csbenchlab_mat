function params = py_parse_param_description(py_set)
    len = eval_python_func('len', py_set); 
    
    params = cell(double(len), 1);
    for i=1:double(len)
        params{i} = ParamDescriptor(string(py_set{i}.name), py_set{i}.default_value);
    end
end
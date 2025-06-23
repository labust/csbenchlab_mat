function params = py_parse_io_description(py_set)
    len = eval_python_func('len', py_set); 
    
    params = cell(double(len), 1);
    for i=1:double(len)
        params{i} = IOArgument(string(py_set{i}.name), py_set{i}.dim);
    end
end
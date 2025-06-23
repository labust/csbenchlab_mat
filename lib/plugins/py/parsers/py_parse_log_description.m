function params = py_parse_log_description(py_set)
    len = eval_python_func('len', py_set); 
    
    params = cell(double(len), 1);
    for i=1:double(len)
        params{i} = LogEntry(string(py_set{i}.name));
    end
end
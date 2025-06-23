function ret = eval_python_func(func_name, varargin)
    
    args = cell(length(varargin));
    input_args = cell(length(varargin));
    for i=1:length(varargin)
        n = strcat("test_var__", num2str(i));
        assignin('base', n, varargin{i});
        args{i} = char(n);
        input_args{i} = [args{i}, '=', args{i}];
    end

    ret = evalin('base', strcat("pyrun('ret = ", func_name, "(", strjoin(args, ','), ")'", ", 'ret', ", strjoin(input_args, ', '), ");"));
    
    evalin("base", strcat("clear ", strjoin(args, " ")));

end
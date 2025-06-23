function ret = run_py_file(path, out_var, varargin)
    
    % calling the python script with a CLI argument that contains *.py
    % string as input does not seem to work

    in_args = {};
    for i=1:length(varargin)
        if endsWith(varargin{i}, '.py')
            t = char(varargin{i});
            in_args{end+1} = t(1:end-3);
        else
            in_args{end+1} = char(varargin{i});
        end
    end

    args_str = string(" '" + strjoin(in_args, "' '") + "'");

    try
        ret = pyrunfile(strcat(path, args_str), out_var);
    catch e
        warning("Error running python file.")
        rethrow(e);
    end

end
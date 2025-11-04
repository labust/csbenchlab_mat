function varargout = eval_py_script_with_json_argument(script_path, arg_name, json_data, output_var, varargin)

    % save param_desc to temp file
    temp_file = strcat(tempname, '.json');
    f = fopen(temp_file, 'w');
    fwrite(f, jsonencode(json_data));
    fclose(f);

    try
        command = strcat(output_var, ' = run_py_file("', script_path, '", "', output_var, '", "', ...
           arg_name, '", temp_file, varargin{:});');
        eval(command);
        varargout{:} = eval(output_var);
        delete_file(temp_file);
    catch e
        delete_file(temp_file);
        rethrow(e);
    end
end


function delete_file(temp_file)
    if exist(temp_file, 'file')
        delete(temp_file);
    end
end
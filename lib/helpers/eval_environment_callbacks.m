function callbacks = eval_environment_callbacks(env_path)

    script_path = fullfile(CSPath.get_app_python_src_path(), 'm_scripts',...
        'eval_environment_callbacks.py');

    result = run_py_file(script_path, 'callbacks', '--env-path', env_path);
    callbacks = parse_callbacks(result);
end

function callbacks = parse_callbacks(result)
    callbacks = dictionary(result);
    if ~callbacks.isConfigured
        callbacks = [];
        return
    end
    keys = callbacks.keys;
    values = {};
    for i=1:length(keys)
       
        cb = callbacks(keys(i));
        if iscell(cb)
            cb = cb{1};
        end
        if isa(cb, 'py.function')
            values{end+1} = cb;
        else
            values{end+1} = jsondecode(cb);
        end
    end
    callbacks = dictionary(keys', values);
end
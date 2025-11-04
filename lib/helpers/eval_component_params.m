function params = eval_component_params(env_path, component)
    rel_path = component_relative_path(component);

    full_params_path = fullfile(env_path, rel_path, component.Id, 'params', strcat(component.Id, '.py'));

    script_path = fullfile(CSPath.get_app_python_src_path(), 'm_scripts', 'eval_plugin_parameters.py');
    param_desc = ComponentManager.get(component.PluginImplementation)...
        .get_component_params(component.PluginName, component.Lib);
    
    plugin_info = ComponentManager.get(component.PluginImplementation)...
        .get_plugin_info(component.PluginName, component.Lib);
    % save param_desc to temp file
    temp_file = strcat(tempname, '.json');
    f = fopen(temp_file, 'w');
    fwrite(f, jsonencode(jsonify_component_param_description(param_desc)));
    fclose(f);
    try
        params = run_py_file(script_path, 'params', ...
            '--param-file', full_params_path, ...
            '--plugin-desc-path', temp_file, ...
            '--plugin-path', plugin_info.ComponentPath);
        delete_temp_file(temp_file);
    catch e
        delete_temp_file(temp_file)
        rethrow(e);
    end

    if isa(params, 'py.types.SimpleNamespace')
        return
    end
    params = jsondecode(char(params));
    

    fns = fieldnames(params);

    load_from_file = isfield(params, 'csb_params_file__');
    if load_from_file
        path = params.csb_params_file__;
        splits = split(path, ':');
        assert(length(splits) == 2 || length(splits) == 3, "Wrong csb_params_file__ format");
        if length(splits) == 2
            params = load_params_from_file(fullfile(env_path, rel_path, component.Id, splits{2}));
        else
            params = load_params_from_file(fullfile(env_path, rel_path, component.Id, splits{2}), splits{3});
        end
        return
    end
    
    csb_eval_exp = 'csb_m_eval_exp:';
    csb_default_eval = 'csb_m_eval_default';
    csb_load_from_file_exp = 'csb_load_from_file:';
    for i=1:length(fns)
        n = fns{i};
        v = params.(n);
        if ischar(v) || isstring(v) && isscalar(v)
            if startsWith(v, csb_eval_exp)
                try
                    v = eval(v(length(csb_eval_exp)+1:end));
                catch
                    warning('Error evaluating expression for parameter %s: %s', n, v);
                end
            elseif strcmp(v, csb_default_eval)
                param_d = param_desc(cellfun(@(x) strcmp(x.Name, n), param_desc));
                if ~isempty(param_d)
                    v = param_d{1}.DefaultValue(params);
                end
            elseif startsWith(v, csb_load_from_file_exp)
                splits = split(v, ':');
                assert(length(splits) == 3, "Wrong csb_params_file__ format");
                v = load_params_from_file(fullfile(env_path, rel_path, component.Id, splits{2}), splits{3});
            end
        end
        if ischar(v) || isstring(v)
            v = uint8(char(v));
        end
        params.(n) = v;
    end
end

function delete_temp_file(temp_file)
    if exist(temp_file, 'file')
        delete(temp_file);
    end
end

function params = load_params_from_file(path, var_name)
    if ~endsWith(path, '.mat')
        error("Matlab backend can only load mat files");
    end
    if exist("var_name", 'var')
        params = load(path, var_name);
        params = params.(var_name);
    else
        params = load(path);
        fns = fieldnames(params);
        if length(fns) > 1
            error(strcat("Provided parameter file '", path, "' has more than one variable"));
        end
        params = params.(fns{1});
    end
end
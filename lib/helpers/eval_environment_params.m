function result_params = eval_environment_params(env_path, env_info)
    script_path = fullfile(CSPath.get_app_python_src_path(), 'm_scripts', 'eval_component_params.py');
  
    
    it = environment_components_it(env_info);
    param_descs = {};
    nonpython_param_descs = {};
    for i=1:length(it)
        comp = it{i}.n;
        if ~is_valid_field(comp, 'PluginType')
            continue
        end
        m = ComponentManager.get(comp.PluginImplementation);
        plugin_info = m.get_plugin_info(comp.PluginName, comp.Lib);
        p.Comp = comp;
        p.ComponentPath = plugin_info.ComponentPath;
        % python descriptions are infered by python and are not needed here
        if strcmp(comp.PluginImplementation, 'py')
            p.Desc = {0};
        else
            nonpython_param_desc = ComponentManager.get(comp.PluginImplementation)...
                .get_component_params(comp.PluginName, comp.Lib);  
            p.Desc = jsonify_component_param_description(nonpython_param_desc);
            nonpython_param_descs{end+1} = nonpython_param_desc;
        end
        param_descs{end+1} = p;
    end    

    temp_file = strcat(tempname, '.json');
    f = fopen(temp_file, 'w');
    fwrite(f, jsonencode(param_descs));
    fclose(f);
    try
        params = run_py_file(script_path, 'params', ...
                '--env-path', env_path, ...
                '--lib-path', CSPath.get_app_registry_path, ...
                '--component-info-path', temp_file, ...
                '--py-as-py' ...
        );
        delete_temp_file(temp_file);
    catch e
        delete_temp_file(temp_file)
        rethrow(e);
    end

    nonpy_params = jsondecode(char(params.get('json')));
    py_params = params.get('py');
    nonpy_cnt = 1;
    py_cnt = 1;
    result_params = dictionary;
    for i=1:length(param_descs)
        c = param_descs{i};
        if strcmp(c.Comp.PluginImplementation, 'py')
            % params = handle_component_params(c.Comp, env_path, py_params{py_cnt});
            result_params(c.Comp.Id) =  {py_params{py_cnt}{"Params"}};
            py_cnt = py_cnt + 1;
        else
            params = handle_component_params(c.Comp, env_path, ...
                nonpy_params(nonpy_cnt), nonpython_param_descs{nonpy_cnt});
            result_params(c.Comp.Id) = {params};
            nonpy_cnt = nonpy_cnt + 1;
        end
    end
end


function params = handle_component_params(c, env_path, params, param_desc)
    assert(strcmp(c.Id, params.Id), "Ids should be the same");
    params = params.Params;
    fns = fieldnames(params);
    load_from_file = isfield(params, 'csb_params_file__');
    if load_from_file
        path = params.csb_params_file__;
        splits = split(path, ':');
        rel_path = component_relative_path(c);
        assert(length(splits) == 2 || length(splits) == 3, "Wrong csb_params_file__ format");
        if length(splits) == 2
            params = load_params_from_file(fullfile(env_path, rel_path, c.Id, splits{2}));
        else
            params = load_params_from_file(fullfile(env_path, rel_path, c.Id, splits{2}), splits{3});
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
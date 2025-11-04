function load_slx_params(param_name, field_name)
    block_path = gcb;
    
    env_name = split(block_path, '/');
    env_name = env_name{1};
    if ~is_env(env_name)
        return
    end

    [params, params_struct_name] = get_component_params_from_block(block_path);
    if ~is_valid_field(params, param_name)
        error(strcat("Cannot load component params. Field '", param_name, "' does not" ...
            + " exist in params for '", block_path, "'"));
    end
    path = params.(param_name);
    ctx = get_component_context_path_from_block(env_name, block_path);
    
    p = load(fullfile(ctx, char(path)));

        
    fns = fieldnames(p);
    if length(fns) > 1
        if ~is_valid_field(p, field_name)
            error(strcat("Cannot find '", field_name, "' in param struct"));
        end
    else
        p = p.(fns{1});
    end
    params.(field_name) = p;

    splits = split(params_struct_name, '.');
    path = strjoin(splits(2:end), '.');
    p = evalin('base', splits{1});
    eval(strcat('p.', path, ' = params;'));
    assignin('base', splits{1}, p);
end


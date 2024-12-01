function c = load_env_controller(env_path, id)
    if ~is_env_path(env_path)
        [env_path, ~, ~] = fileparts(which(env_path));
    end
    controllers_folder = fullfile(env_path, 'parts', 'controllers');
    f = fullfile(controllers_folder, strcat(id, '.json'));
    if exist(f, 'file')
        c = readstruct(f, 'FileType', 'json');
    else
        c = struct;
        return
    end

    
    c = load_component_params(c, env_path);
    if c.IsComposable
        for i=1:length(c.Components)
            c.Components(i) = ...
                load_component_params(c.Components(i), env_path);
        end
    end
    if is_valid_field(c.Params, 'eval__')
        c.Params.eval__ = load_eval_vars(c.Params.eval__);
    end
    
end


function ns = load_eval_vars(s)

    function ns = load_eval_vars(s)
        names = fieldnames(s);
        ns = s;
        for i=1:length(names)
            name = names{i};
            if isa(s.(name), 'struct')
                ns.(name) = load_eval_vars(s.(name));
            else
                ns.(name) = EvalParam.from_string(s.(name));
            end
        end

    end
    ns = load_eval_vars(s);
end
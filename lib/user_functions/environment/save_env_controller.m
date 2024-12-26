function save_env_controller(env_path, controller, check_path)
    if ~exist('check_path', 'var')
        check_path = 1;
    end
    if check_path && ~is_env_path(env_path)
        [env_path, ~, ~] = fileparts(which(env_path));
    end
    f = fullfile(env_path, 'parts', 'controllers', strcat(controller.Id, '.json'));

    if is_valid_field(controller.Params, 'eval__')
        controller.Params.eval__ = ...
            replace_eval_vars(controller.Params.eval__);
    end

    controller = save_component_params(controller, env_path);
    if controller.IsComposable
        for i=1:length(controller.Components)
            controller.Components(i) = ...
                save_component_params(controller.Components(i), env_path);
        end
    end

    writestruct(controller, f, 'FileType', 'json');  
end

function ns = replace_eval_vars(s)

    function ns = replace_eval_vars_rec(s)
        names = fieldnames(s);
        ns = s;
        for i=1:length(names)
            name = names{i};
            if isa(s.(name), 'struct')
                ns.(name) = replace_eval_vars_rec(s.(name));
            elseif isa(s.(name), 'EvalParam')
                ns.(name) = formattedDisplayText(ns.(name));
            end
        end

    end

    
    ns = replace_eval_vars_rec(s);
end
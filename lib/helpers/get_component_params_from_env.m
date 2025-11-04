function varargout = get_component_params_from_env(env, comp)
    if strcmp(comp.Id, '-1')
        varargout{1} = "0";
        if nargout > 1
            varargout{2} = struct;
        end
        return
    end
    
    if ~(ischar(env) || isstring(env))
        error("Provided argument is not an environment name");
    end
    n = get_env_param_struct(env);

    if is_valid_field(comp, 'ParentComponentId')
        r = strcat(n, '.Subcomponents.', ...
            matlab.lang.makeValidName(comp.ParentComponentName), '.', ...
            matlab.lang.makeValidName(comp.Name));
    else
        r = strcat(n, '.', comp.PluginType, '.', ...
            matlab.lang.makeValidName(comp.Name));
    end
    varargout{1} = r;
    if nargout == 2
        params = evalin('base', r);
        varargout{2} = params;
    end
end


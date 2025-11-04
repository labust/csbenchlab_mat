function varargout = get_env_param_struct(env_name)
    r = strcat(matlab.lang.makeValidName(env_name), '_params');
    varargout{1} = r;
    if nargout > 1
        varargout{2} = evalin('base', r);
    end
end


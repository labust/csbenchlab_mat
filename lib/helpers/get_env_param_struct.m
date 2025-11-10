function varargout = get_env_param_struct(env_name)
    if ~exist('env_name', 'var')
        env_name = split(gcb, '/');
        env_name = env_name{1};
    end
    r = strcat(matlab.lang.makeValidName(env_name), '_params');
    varargout{1} = r;
    if nargout > 1
        varargout{2} = evalin('base', r);
    end
end


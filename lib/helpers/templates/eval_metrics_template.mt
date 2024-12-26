function {{function_name}}(name, varargin)
    eval(strcat(name, '(varargin{:})'));
end
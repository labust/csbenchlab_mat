function [t, msg] = validate_system(sys)
    [t, msg] = validate_var_name(sys.ParamsStructName, 'ParamsStructName');
    if t > 0
        msg = strcat("System: ", msg);
        return
    end

    [t, msg] = validate_type_lib(sys);
    if t > 0
        return
    end
end


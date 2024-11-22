function [t, msg] = validate_estimator(est)
    t = 0; msg = "";
    if isempty(est)
        return
    end
    [t, msg] = validate_var_name(est.ParamsStructName, 'ParamsStructName');
    if t > 0
        msg = strcat("Estimator: ", msg);
        return
    end
    [t, msg] = validate_type_lib(est);
end


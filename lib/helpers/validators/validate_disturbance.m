function [t, msg] = validate_disturbance(dist)
    t = 0; msg = "";
    if isempty(dist)
        return
    end
    [t, msg] = validate_var_name(dist.ParamsStructName, 'ParamsStructName');
    if t > 0
        msg = strcat("Disturbance ", msg);
        return
    end
    [t, msg] = validate_type_lib(dist);
end


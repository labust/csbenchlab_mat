function [t, msg] = validate_var_name(name, msg_info)
    t = isvarname(name) == 0; 
    msg = "";
    if t > 0
        msg = strcat(msg_info, " is not a valid var name.");
    end
end


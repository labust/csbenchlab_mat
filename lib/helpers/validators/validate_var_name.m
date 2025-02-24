function [t, msg] = validate_var_name(name, msg_info, empty_ok)
    t = 0;
    msg = "";
    if ~exist('empty_ok', 'var')
        empty_ok = 1;
    end

    if empty_ok && strempty(name)
        return
    end
    t = isvarname(name) == 0; 
    if  t > 0
        msg = strcat(msg_info, " is not a valid var name.");
    end
end


function [t, msg] = validate_env_cfg(env_cfg)
    t = 0;
    msg = "";

    
    [t, msg] = validate_system(env_cfg.System);
    if t > 0
        msg = strcat("Error in ", msg);
        return
    end
    
    for i=1:length(env_cfg.Controllers)
        [t, msg] = validate_controller(env_cfg.Controllers(i));
        if t > 0
            msg = strcat("Error in Controller(", num2str(i), "): ", msg);
            return
        end
    end


end


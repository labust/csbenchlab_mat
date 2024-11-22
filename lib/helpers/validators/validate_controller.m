function [t, msg] = validate_controller(ctl)
    msg = "";
    
    if ctl.IsComposable
        for i=1:length(ctl.Components)
            [t, msg] = validate_var_name(ctl.Components(i).ParamsStructName, 'ParamsStructName');
            if t > 0
                msg = strcat("Subcontroller(", num2str(i), "): ", msg);
                return
            end
            [t, msg] = validate_type_lib(ctl.Components(i));
            if t > 0
                return
            end
        end
        return
    end

    
    [t, msg] = validate_var_name(ctl.ParamsStructName, 'ParamsStructName');
    if t > 0
        msg = strcat("Controller: ", msg);
        return
    end

    [t, msg] = validate_type_lib(ctl);
    if t > 0
        return
    end

    if ~isempty(ctl.Components) && (length(ctl.Components) > 1 || ~strempty(ctl.Components(1).Name))
        msg = "Not composable controller cannot have components";
        return
    end

    [t, msg] = validate_estimator(ctl.Estimator);
    if t > 0
        return
    end

    [t, msg] = validate_disturbance(ctl.Disturbance);
    if t > 0
        return
    end




end


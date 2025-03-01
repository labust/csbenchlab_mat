function  trigger_model_callback(info, cb_name)

    trigger_cb(info.Metadata, cb_name);
    trigger_cb(info.System, cb_name);
    if is_valid_field(info.System, 'Disturbance')
        trigger_cb(info.System.Disturbance, cb_name);
    end
    
    for i=1:length(info.Controllers)
        ctl = info.Controllers(i);
        if ctl.IsComposable
            for j=1:length(info.Controllers(i).Components)
                comp = info.Controllers(i).Components(j);
                trigger_cb(comp, cb_name);
            end
        else
            trigger_cb(ctl, cb_name);
        end
        trigger_cb(ctl.Estimator, cb_name);
        trigger_cb(ctl.Disturbance, cb_name);
    end

end


function trigger_cb(comp, cb_name)

    if is_valid_field(comp, 'Callbacks')
        if is_valid_field(comp.Callbacks, cb_name)
            try
                run(comp.Callbacks.OnEnvLoad);
            catch ME
                disp(strcat("OnEnvLoad callback resulted in errors in '", comp.Name, "'."));
                rethrow(ME);
            end
        end
    end

end
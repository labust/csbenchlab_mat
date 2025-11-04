function c = environment_components_it(info)
    c = {};
    
    c{end+1} = info.System;
    if is_valid_field(info.System, 'Disturbance')
        c{end+1} = info.System.Disturbance;
    end
   
    for i=1:length(info.Controllers)
        ctl = info.Controllers(i);
        if ctl.IsComposable
            for j=1:length(info.Controllers(i).Components)
                c{end+1} = info.Controllers(i).Components(j);
            end
        else
            c{end+1} = ctl;
        end
        if is_valid_field(ctl, 'Estimator')
            c{end+1} = ctl.Estimator;
        end
        if is_valid_field(ctl, 'Disturbance')
            c{end+1} = ctl.Disturbance;
        end
    end
end


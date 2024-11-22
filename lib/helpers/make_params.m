function resolved = make_params(class_name, param_values)
    

    if ~exist('param_values', 'var')
        param_values = struct;
    end
    desc = eval(strcat(class_name, '.param_description'));

    resolved = struct;
    for i=1:length(desc.params)
        p = desc.params{i};
        
        exists = isfield(param_values, p.Name);
        if exists
            resolved.(p.Name) = param_values.(p.Name);
            continue
        end

        if ~exists
            if isa(p.DefaultValue, 'function_handle')
                resolved.(p.Name) = p.DefaultValue(resolved);
            else
                resolved.(p.Name) =  p.DefaultValue;
            end
        end
    end

end
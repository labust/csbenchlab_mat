function resolved = make_params(class_name, param_values)
    
    desc = eval([class_name, '.param_description']);

    resolved = struct;
    for i=1:length(desc.params)
        p = desc.params{i};
        
        exists = isfield(param_values, p.Name);
        if exists
            resolved.(p.Name) = param_values.(p.Name);
            continue
        end

        if ~exists && ~p.Required 
            if isa(p.DefaultValue, 'function_handle')
                resolved.(p.Name) = p.DefaultValue(resolved);
            else
                resolved.(p.Name) =  p.DefaultValue;
            end
            continue
        end
        error(['Parameter "', convertStringsToChars(p.Name), '" is not set.']);
    end

end
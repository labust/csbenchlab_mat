classdef ParamHelpers
    
    properties
        params = {};
    end
    
    methods (Static)
        

        function p = override_params(p, override_params)
            
            names = cellfun(@(x) x.Name, override_params);
            for i=1:length(p)
                for j=1:length(override_params)
                    if any(names(j) == p{i}.Name)
                        p(i) = override_params(j);
                        override_params{j} = [];
                    end
                end
            end
            for i=1:length(override_params)
                if ~isempty(override_params{i})
                    p{end+1} = override_params{i};
                end
            end

        end

        function out_params = construct_params(params, param_values)
            
            out_params = struct;
            for i=1:length(params)
                p = params{i};
                
                if isfield(param_values, p)
                    value = param_values.(p);             
                else

                    if isa(p.DefaultValue, 'function_handle')
                        value = p.DefaultValue(out_params);
                    else
                        value = p.DefaultValue;
                    end
                end

                if p.is_ok(value)
                    out_params.(p.Name) = value;
                end
            end
        end

    end
end
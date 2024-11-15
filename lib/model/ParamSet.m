classdef ParamSet
    
    properties
        params = {};
    end
    
    methods
        function this = ParamSet(varargin)
            this.params = varargin;
        end

        function this = override_params(this, override_params)
            
            names = cellfun(@(x) x.Name, override_params);
            for i=1:length(this.params)
                for j=1:length(override_params)
                    if any(names(j) == this.params{i}.Name)
                        this.params(i) = override_params(j);
                        override_params{j} = [];
                    end
                end
            end
            for i=1:length(override_params)
                if ~isempty(override_params{i})
                    this.params{end+1} = override_params{i};
                end
            end

        end

        function out_params = construct_params(this, param_values)
            
            out_params = struct;
            for i=1:length(this.params)
                p = this.params{i};
                
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
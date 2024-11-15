classdef ParamDescriptor
    %PARAMETER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Name
        DefaultValue
        Required
    end
    
    methods
        function this = ParamDescriptor(name, required, varargin)

            if (~required)
                if nargin < 1
                    error('Optional parameter must have default value');
                end
            end
            
            this.Name = name;
            this.Required = required;

            if ~required
                this.DefaultValue = varargin{1};
            else
                this.DefaultValue = 0;
            end
        end

        function ok = is_ok(this, param_value)
            ok = 1;
        end


    end
end


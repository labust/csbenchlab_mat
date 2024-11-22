classdef ParamDescriptor
    %PARAMETER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Name
        DefaultValue
        IsValid
    end
    
    methods
        function this = ParamDescriptor(name, default_value, varargin)
            
            this.Name = name;
            this.DefaultValue = default_value;

            if ~isempty(varargin)
                this.IsValid  = varargin{1};
            end
        end

    end
end


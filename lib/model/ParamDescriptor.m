classdef ParamDescriptor
    %PARAMETER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Name
        DefaultValue
        IsValid
        Serialize
    end
    
    methods
        function this = ParamDescriptor(name, default_value, varargin)
            
            this.Name = name;
            this.DefaultValue = default_value;
            
            if ~isempty(varargin)
                this = parse_name_value_varargin(varargin, ["Serialize", "IsValid"], this);
            end
        end

    end
end


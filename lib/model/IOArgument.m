classdef IOArgument
    %PARAMETER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Name
        Dim
    end
    
    methods
        function this = IOArgument(name, varargin)
            this.Name = name;
            this.Dim = varargin{1};
        end
    end
end


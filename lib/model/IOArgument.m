classdef IOArgument
    %PARAMETER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Name
        Type
        Dim
    end
    
    methods
        function this = IOArgument(type, name, varargin)

            if ~strcmp(type, 'input') && ~strcmp(type, 'output')
                error(strcat('Cannot create IO argument. Unsuported type "', name, '"'));
            end

            this.Type = type;
            this.Name = name;
            this.Dim = varargin{1};
        end
    end
end


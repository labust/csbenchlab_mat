classdef RegistryInfo
    %REGISTRYINFO Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Name
        Visible
    end
    
    methods
        function this = RegistryInfo(name, visible)
            %REGISTRYINFO Construct an instance of this class
            %   Detailed explanation goes here
            this.Name = name;
            this.Visible = visible;
        end
    end

end


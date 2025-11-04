classdef LoadFromFile
    %FILEPATH Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Path
        VarName
    end
    
    methods
        function obj = FilePath(path, var_name)
            if ~exist('var_name', 'var')
                var_name = "";
            end
            obj.Path = path;
            obj.VarName = var_name;
        end

        function str = as_string(obj)
            str = strcat(obj.Path, ":", obj.VarName);
        end
        
    end
end


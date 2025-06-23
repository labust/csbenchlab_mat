classdef ComponentOptions
    %CONTROLLEROPTIONS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Id
        Name
        Params
        ParamsStructName
        Type
        Lib
        LibVersion
        Callbacks
    end
    
    methods
        function obj = ComponentOptions(varargin)

            begin_idx = 1;
            if nargin > 0 && isa(varargin{1}, 'ComponentOptions')
                obj = varargin{1};
                begin_idx = 2;
            else
                obj.Id = new_uuid;
                obj.Name = '';
                obj.Params = [];
                obj.ParamsStructName = '';
                obj.Type = '';
                obj.Lib = '';
                obj.LibVersion = '0.0';
                obj.Callbacks = init_env_callbacks;
            end
            
            if length(varargin) >= begin_idx
                obj = parse_name_value_varargin(varargin(begin_idx:end), ...
                        properties('ComponentOptions'), obj);
            end
        end        
    end
end


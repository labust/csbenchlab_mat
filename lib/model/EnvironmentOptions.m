classdef EnvironmentOptions
    %ENVIRONMENTOPTIONS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Id
        Path
        Ts
        SystemParams
        SystemParamsStructName
        SystemName
        SystemType
        SystemLib
        SystemLibVersion
        Controllers
        Scenarios
        References
        Extrinsic
        Plots
        Callbacks
        Override
    end
    
    methods
        function obj = EnvironmentOptions(varargin)
            
            begin_idx = 1;
            if nargin > 0 && isa(varargin{1}, 'EnvironmentOptions')
                obj = varargin{1};
                begin_idx = 2;
            else
                obj.Id = new_uuid;
                obj.Path = '';
                obj.Ts = 0;
                obj.SystemParams = [];
                obj.SystemParamsStructName = '';
                obj.SystemName = '';
                obj.SystemType = '';
                obj.SystemLib = '';
                obj.SystemLibVersion = '';
                obj.Extrinsic = 0;
                obj.Controllers = [];
                obj.Scenarios = [];
                obj.Plots = [];
                obj.References = '';
                obj.Override = 0;
                obj.Callbacks = init_env_callbacks;
            end
            if length(varargin) >= begin_idx
                obj = parse_name_value_varargin(varargin{begin_idx:end}, ...
                        properties('EnvironmentOptions'), obj);
            end
        end
    end
end

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
                obj.Id = java.util.UUID.randomUUID.toString;
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
               % Loop through the parameter names and not the values.
            for i = begin_idx:2:length(varargin)

                if isstring(varargin{i})
                    as_char = convertStringsToChars(varargin{i});
                else
                    as_char = varargin{i};
                end
                
                value = varargin{i+1};
                switch as_char
                    case 'Path' 
                        obj.Path = value;
                    case 'SystemParams'
                        obj.SystemParams = value;
                    case 'SystemParamsStructName'
                        obj.SystemParamsStructName = value;
                    case 'SystemType'
                        obj.SystemType = value;
                    case 'SystemName'
                        obj.SystemName = value;
                    case 'SystemLib'
                        obj.SystemLib = value;
                    case 'SystemLibVersion'
                        obj.SystemLibVersion = value;
                    case 'Controllers'
                        obj.Controllers = value;
                    case 'Scenarios'
                        obj.Scenarios = value;
                    case 'References'
                        obj.References = value;
                    cas 'Extrinsic'
                        obj.Extrinsic = value;
                    case 'Plots'
                        obj.Plots = value;
                    case 'Ts'
                        obj.Ts = value;
                    case 'Callbacks'
                        obj.Callbacks = value;
                    case 'Override'
                        obj.Override = value;
                    otherwise
                        warning(['Unexpected parameter name "', as_char, '"']);
                end
            end
        end
    end
end

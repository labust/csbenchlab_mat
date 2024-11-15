classdef EnvironmentOptions
    %ENVIRONMENTOPTIONS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Path
        Ts
        SystemParams
        SystemPath
        Controllers
        Scenarios
        References
        Plots
        Override
    end
    
    methods
        function obj = EnvironmentOptions(varargin)
            
            begin_idx = 1;
            if isa(varargin{1}, 'EnvironmentOptions')
                obj = varargin{1};
                begin_idx = 2;
            else
                obj.Path = '';
                obj.Ts = 0;
                obj.SystemParams = '';
                obj.SystemPath = '';
                obj.Controllers = [];
                obj.Scenarios = [];
                obj.Plots = [];
                obj.References = '';
                obj.Override = 0;
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
                    case 'SystemPath'
                        obj.SystemPath = value;
                    case 'Controllers'
                        obj.Controllers = value;
                    case 'Scenarios'
                        obj.Scenarios = value;
                    case 'References'
                        obj.References = value;
                    case 'Plots'
                        obj.Plots = value;
                    case 'Ts'
                        obj.Ts = value;
                    case 'Override'
                        obj.Override = value;
                    otherwise
                        warning(['Unexpected parameter name "', as_char, '"']);
                end
            end
        end
    end
end

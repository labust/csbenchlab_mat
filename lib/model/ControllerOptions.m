classdef ControllerOptions < ComponentOptions
    %CONTROLLEROPTIONS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        IsComposable
        Components
        Estimator
        Disturbance
        Mux
        RefHorizon
        RegenerateEnv
    end
    
    methods
        function obj = ControllerOptions(varargin)
            obj = obj@ComponentOptions(varargin{:});

            begin_idx = 1;
            if nargin > 0 && isa(varargin{1}, 'ControllerOptions')
                obj = varargin{1};
                begin_idx = 2;
            else
                obj.IsComposable = 0;
                obj.Components = {};
                obj.Estimator = [];
                obj.Disturbance = [];
                obj.Mux.Inputs = [];
                obj.Mux.Outputs = [];
                obj.RegenerateEnv = 0;
                obj.RefHorizon = 1;
            end
            if length(varargin) >= begin_idx
                obj = parse_name_value_varargin(varargin{begin_idx:end}, ...
                        properties('ControllerOptions'), obj);
            end
        end

        
    end
end


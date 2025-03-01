classdef ControllerComponent < ComponentOptions
    %CONTROLLEROPTIONS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Mux
        RefHorizon
        RegenerateEnv
    end
    
    methods
        function obj = ControllerComponent(varargin)
            obj = obj@ComponentOptions(varargin{:});
            begin_idx = 1;
            if nargin > 0 && isa(varargin{1}, 'ControllerComponent')
                obj = varargin{1};
                begin_idx = 2;
            else
                obj.Mux.Inputs = [];
                obj.Mux.Outputs = [];
                obj.RegenerateEnv = 0;
                obj.RefHorizon = 1;
            end
    
            if length(varargin) >= begin_idx
                obj = parse_name_value_varargin(varargin{begin_idx:end}, ...
                        properties('ControllerComponent'), obj);
             end


        end

        
    end
end


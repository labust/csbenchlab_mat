classdef SystemOptions < ComponentOptions
    %CONTROLLEROPTIONS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Disturbance
        Dims
    end
    
    methods
        function obj = SystemOptions(varargin)
            obj = obj@ComponentOptions(varargin{:});

            begin_idx = 1;
            if nargin > 0 && isa(varargin{1}, 'SystemOptions')
                obj = varargin{1};
                begin_idx = 2;
            else
                obj.Disturbance = {};
                obj.Dims.Inputs = -1;
                obj.Dims.Outputs = -1;
            end
            
            if length(varargin) >= begin_idx
                obj = parse_name_value_varargin(varargin(begin_idx:end), ...
                        properties('SystemOptions'), obj);
            end
        end

        
    end
end


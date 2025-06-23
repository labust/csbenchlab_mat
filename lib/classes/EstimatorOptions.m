classdef EstimatorOptions < ComponentOptions
    %CONTROLLEROPTIONS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties

    end
    
    methods
        function obj = EstimatorOptions(varargin)
            obj = obj@ComponentOptions(varargin{:});
            if nargin > 0 && isa(varargin{1}, 'EstimatorOptions')
                obj = varargin{1};
            end
            

        end

    end
end


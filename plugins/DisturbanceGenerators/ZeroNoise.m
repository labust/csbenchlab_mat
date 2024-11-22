classdef ZeroNoise < DisturbanceGenerator
    %PROPAGATESTATE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant)
        param_description = ParamSet();
    end
    
    methods
        function this = ZeroNoise(varargin)
            this@DisturbanceGenerator(varargin);  
        end


        function this = on_configure(this)
        end

        function [this, y_n] = on_step(this, y, dt)
            y_n = y;
        end


        function this = on_reset(this)
        end
    end
end


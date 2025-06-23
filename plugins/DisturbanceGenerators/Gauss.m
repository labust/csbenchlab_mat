classdef Gauss < DisturbanceGenerator
    %PROPAGATESTATE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant)
        param_description = {
            ParamDescriptor("mu", 0), ...
            ParamDescriptor("sigma", 1) ...
        };
    end
    
    methods
        function this = Gauss(varargin)
            this@DisturbanceGenerator(varargin);  
        end


        function this = on_configure(this)
        end

        function [this, y_n] = on_step(this, y, dt)
            n = this.params.sigma * randn(size(y)) + this.params.mu;
            y_n = y + n;
        end


        function this = on_reset(this)
        end
    end
end


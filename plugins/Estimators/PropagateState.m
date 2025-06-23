classdef PropagateState < Estimator
    %PROPAGATESTATE Summary of this class goes here
    %   Detailed explanation goes here
    properties(Constant)
        param_description = {};
    end


    methods
        function this = PropagateState(varargin)
            this@Estimator(varargin);  
        end


        function this = on_configure(this)
        end

        function [this, y] = on_step(this, y_meas, dt)
            y = y_meas;
        end


        function this = on_reset(this)
        end
    end
end


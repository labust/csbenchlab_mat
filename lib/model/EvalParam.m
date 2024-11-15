classdef EvalParam
    %PARAMETER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        EvalFn
        EvalArgs
    end
    
    methods
        function this = EvalParam(fn, varargin)
            this.EvalFn = fn;
            this.EvalArgs = varargin;
        end
    end
end


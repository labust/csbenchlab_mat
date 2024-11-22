classdef LinearSystem < DynSystem
    %DEEPC Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant)
        param_description = ParamSet( ...
            ParamDescriptor("A", 1), ...
            ParamDescriptor("B", 1), ... 
            ParamDescriptor("C", 1), ... 
            ParamDescriptor("dims", @LinearSystem.dims_from_params), ...
            ParamDescriptor("D", @(params) zeros(params.dims.output, params.dims.input)), ... 
            ParamDescriptor("sat_min", @(params) -inf * ones(params.dims.output, 1)), ... 
            ParamDescriptor("sat_max", @(params) inf * ones(params.dims.output, 1)), ... 
            ParamDescriptor("noise", struct) ... 
        );
        registry_info = RegistryInfo("LinearSystem", true);
    end

    properties
        xk_1
    end
    
    methods
        function this = LinearSystem(varargin)
            this@DynSystem(varargin);  
        end

        function this = on_configure(this)
            this.xk_1 = this.ic;
        end

        function [this, yk] = on_step(this, u, t, dt)
            saturate = @Utils.saturate;

            xk = this.params.A * this.xk_1 + this.params.B * u;
            yk = this.params.C * xk + this.params.D * u;
            
            yk = saturate(yk, this.params.sat_min, this.params.sat_max);

            this.xk_1 = xk;
        end

        function this = on_reset(this)
            this.xk_1 = this.ic;
        end

    end

    methods (Static)

        function dims = dims_from_params(params)
            dims.input = size(params.B, 2);
            dims.output = size(params.C, 1);
        end
    end
end


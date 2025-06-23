classdef LinearSystem < DynSystem
    %DEEPC Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant)
        param_description = {
            ParamDescriptor("A", 1), ...
            ParamDescriptor("B", 1), ... 
            ParamDescriptor("C", 1), ... 
            ParamDescriptor("D", @(params) zeros(params.dims.Outputs, params.dims.Inputs)), ... 
            ParamDescriptor("sat_min", @(params) -inf * ones(params.dims.output, 1)), ... 
            ParamDescriptor("sat_max", @(params) inf * ones(params.dims.output, 1)) ...
        };
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
            yk = this.params.C * xk + this.data.D * u;
            
            yk = saturate(yk, this.params.sat_min, this.params.sat_max);

            this.xk_1 = xk;
        end

        function this = on_reset(this)
            this.xk_1 = this.ic;
        end

    end

    methods (Static)
        function dims = get_dims_from_params(params)
            dims.Inputs = size(params.B, 2);
            dims.Outputs = size(params.C, 1);
        end

        function data = create_data_model(params)
            dims = LinearSystem.get_dims_from_params(params);
            sz = size(params.D);
            if (isequal(sz, [1, 1]) && params.D == 0)
                data.D = zeros(dims.Outputs, dims.Inputs);
            else
                data.D = params.D;
            end
        end
    end
end


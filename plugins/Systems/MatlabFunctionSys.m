classdef MatlabFunctionSys < DynSystem
    %DEEPC Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant)
        param_description = { ...
            ParamDescriptor("fun", 0), ...
            ParamDescriptor("dims", 0), ...
            ParamDescriptor("a1", 0), ...
            ParamDescriptor("a2", 0), ...
            ParamDescriptor("a3", 0), ...
            ParamDescriptor("a4", 0), ...
            ParamDescriptor("a5", 0), ...
            ParamDescriptor("a6", 0), ...
            ParamDescriptor("a7", 0), ...
            ParamDescriptor("a8", 0), ...
            ParamDescriptor("differential", 0) ...
        };

        registry_info = RegistryInfo("MatlabFunctionSys", true);
    end

    properties (Hidden)
        xk_1
        num_args
    end
    
    methods
        function this = MatlabFunctionSys(varargin)
            this@DynSystem(varargin{:});

            if ~exist(this.params.fun, 'file')
                error(strcat("Function ", this.params.fun, " does not exist"));
            end
            this.num_args = nargin(this.params.fun);
        end

        function this = on_configure(this)
            this.xk_1 = this.ic;
        end


        function [this, r] = on_step(this, u, t, dt)
            if this.params.differential > 0
                dx = this.call_fun(u, t, dt);
                this.xk_1  = this.xk_1 + dx;
            else
                this.xk_1  = this.call_fun(u, t, dt);
            end
            r = this.xk_1(this.params.dims.outputs);
        end

        function this = on_reset(this)
        end


        function x = call_fun(this, u, t, dt)
            fh = str2func(this.params.fun);
            rest_args = {};
            switch this.num_args
                case 0
                    [x, rest_args{:}] = fh();
                case 1
                    [x, rest_args{:}] = fh(this.arg_value(this.params.a1, u, t, dt));
                case 2
                    [x, rest_args{:}] = fh(this.arg_value(this.params.a1, u, t, dt), ...
                        this.arg_value(this.params.a2, u, t, dt));
                case 3
                    [x, rest_args{:}] = fh(this.arg_value(this.params.a1, u, t, dt), ...
                        this.arg_value(this.params.a2, u, t, dt), ...
                        this.arg_value(this.params.a3, u, t, dt));
                case 4
                    [x, rest_args{:}] = fh(this.arg_value(this.params.a1, u, t, dt), ...
                        this.arg_value(this.params.a2, u, t, dt), ...
                        this.arg_value(this.params.a3, u, t, dt), ...
                        this.arg_value(this.params.a4, u, t, dt));
                case 5
                    [x, rest_args{:}] = fh(this.arg_value(this.params.a1, u, t, dt), ...
                        this.arg_value(this.params.a2, u, t, dt), ...
                        this.arg_value(this.params.a3, u, t, dt), ...
                        this.arg_value(this.params.a4, u, t, dt), ...
                        this.arg_value(this.params.a5, u, t, dt));
                case 6
                    [x, rest_args{:}] = fh(this.arg_value(this.params.a1, u, t, dt), ...
                        this.arg_value(this.params.a2, u, t, dt), ...
                        this.arg_value(this.params.a3, u, t, dt), ...
                        this.arg_value(this.params.a4, u, t, dt), ...
                        this.arg_value(this.params.a5, u, t, dt), ...
                        this.arg_value(this.params.a6, u, t, dt));
                case 7
                    [x, rest_args{:}] = fh(this.arg_value(this.params.a1, u ,t), ...
                        this.arg_value(this.params.a2, u, t, dt), ...
                        this.arg_value(this.params.a3, u, t, dt), ...
                        this.arg_value(this.params.a4, u, t, dt), ...
                        this.arg_value(this.params.a5, u, t, dt), ...
                        this.arg_value(this.params.a6, u, t, dt), ...
                        this.arg_value(this.params.a7, u, t, dt));
                case 8
                    [x, rest_args{:}] = fh(this.arg_value(this.params.a1, u, t, dt), ...
                        this.arg_value(this.params.a2, u, t, dt), ...
                        this.arg_value(this.params.a3, u, t, dt), ...
                        this.arg_value(this.params.a4, u, t, dt), ...
                        this.arg_value(this.params.a5, u, t, dt), ...
                        this.arg_value(this.params.a6, u, t, dt), ...
                        this.arg_value(this.params.a7, u, t, dt), ...
                        this.arg_value(this.params.a8, u, t, dt));
                otherwise
                    error("Unsupported number of arguments");
                    
            end
        end


        function v = arg_value(this, arg, u, t, dt)
            
            if isa(arg, 'str') || isa(arg, 'char')
                if strcmp(arg, 'x')
                    v = this.xk_1;
                    return
                end
                if strcmp(arg, 'u')
                    v = u;
                    return
                end
                if strcmp(arg, 't')
                    v = t;
                    return
                end
                if strcmp(arg, 'dt')
                    v = dt;
                    return
                end
            end
            
            if isa(arg, 'timeseries')
                v = getsampleusingtime(arg, t).Data;
                return
            end

            v = arg;
            
        end
       
    end

end


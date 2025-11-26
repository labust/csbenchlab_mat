classdef (Abstract) DynSystem
    %DYNSYSTEM Base class for all dynamical systems

    properties (Abstract, Constant)
       param_description
    end

    properties
        params
        data
        name
        noise_stream
        noise_params
        has_noise
        ic
        pid
        iid
    end

    methods (Abstract)
       % called right after parameters and sizes have been set to configure
       % the class 
       on_configure(this)
       % called every step to produce propagate the system state
       on_step(this, u, t, dt, update)
       % called to reset the system behavior
       on_reset(this);
    end

    methods (Abstract, Static)
        get_dims_from_params(params);
    end

    methods
        function this = DynSystem(args)
            begin_idx = 1;
            pid = 0; iid = 0;
            params = struct;
            data = 0;
            noise_params = struct;
            has_noise = 0;
            for i = begin_idx:2:length(args)

                if isstring(args{i})
                    as_char = convertStringsToChars(args{i});
                else
                    as_char = args{i};
                end
                
                value = args{i+1};
                switch as_char
                    case 'Params'
                        params = value;
                    case 'Data'
                        data = value;
                    case 'Noise'
                        noise_params = value;
                        has_noise = 1;
                    case 'pid'
                        pid = value;
                    case 'iid'
                        iid = value;
                    otherwise
                        warning(['Unexpected parameter name "', as_char, '"']);
                end
            end
            
            this.has_noise = has_noise;
            this.noise_params = noise_params;
            this.params = params;
            this.data = data;
            this.pid = pid;
            this.iid = iid;
        end
        
        function this = configure(this, ic)
            this.ic = ic;
            this = on_configure(this);
            if this.has_noise > 0
                this.noise_stream = RandStream("mlfg6331_64", "Seed", this.noise_params.seed);
            end
        end

        function [this, y] = step(this, u, t, dt)
            [this, y] = on_step(this, u, t, dt);
            % if this.has_noise > 0
            %     y = y + this.noise_params.bias ...
            %         + randn(this.noise_stream, size(y)) * this.noise_params.std;
            % end
        end

        function step_response(this, t, dt, scale)
            if ~exist('scale', 'var')
                scale = 1;
            end
            n = round(t/dt);
            u = scale * ones(n, 1);
            this = this.reset();
            y = this.sim(u, 0, dt);
            plot(y);
        end

        function [this, y] = step_no_noise(this, u, t, dt)
            [this, y] = on_step(this, u, t, dt);
        end

        function this = reset(this)
            this = on_reset(this);
            
        end

        function varargout = sim(this, varargin)
            varargout = cell(2, 1);
            if this.has_noise > 0
                this.noise_stream.Substream = 2;
            end
            [~, varargout{:}] = sim_update(this, varargin{:});
        end

        function [this, varargout] = sim_update(this, u, t, dt, ic)
            if exist('ic', 'var')
                this = this.configure(ic);
            end
            [this, y1] = step_no_noise(this, u(1, :)', t, dt);
            y = zeros(size(u, 1), size(y1, 1));
            y(1, :) = y1;
            for i=2:size(u, 1)
                [this, y(i, :)] = step_no_noise(this, u(i, :)', t, dt);
            end

            if this.has_noise > 0
                varargout{1} = y + this.noise_params.bias ...
                    + randn(this.noise_stream, size(y)) * this.noise_params.std;
            else
                varargout{1} = y;
            end
            varargout{2} = y;
            
        end

    end
end


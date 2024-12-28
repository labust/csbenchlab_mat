classdef (Abstract) DynSystem
    %DYNSYSTEM Base class for all dynamical systems

    properties (Abstract, Constant)
       param_description
    end

    properties
        params
        data
        noise_stream
        noise_params
        has_noise
        ic
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
            if ~isempty(args)
                this.params = args{1};
            end

            begin_idx = 2;
            for i = begin_idx:2:length(args)

                if isstring(args{i})
                    as_char = convertStringsToChars(args{i});
                else
                    as_char = args{i};
                end
                
                value = args{i+1};
                switch as_char
                    case 'Data'
                        data = value;
                    otherwise
                        warning(['Unexpected parameter name "', as_char, '"']);
                end
            end

            if isempty(data)
                error("Data not set");
            end

            this.data = data;

            % if length(args) > 1
            %     this.noise_params = args{2};
            %     this.noise_stream = RandStream("mlfg6331_64", "Seed", this.noise_params.seed);
            %     this.has_noise = 1;
            % else
            %     this.has_noise = 0;
            % end
        end
        
        function this = configure(this, ic)
            this.ic = ic;
            this = on_configure(this);
        end

        function [this, y] = step(this, u, t, dt)
            [this, y] = on_step(this, u, t, dt);
            % if this.has_noise > 0
            %     y = y + this.noise_params.bias ...
            %         + randn(this.noise_stream, size(y)) * this.noise_params.std;
            % end
        end

        function [this, y] = step_no_noise(this, u, t, dt)
            [this, y] = on_step(this, u, t, dt);
        end

        function this = reset(this)
            this = on_reset(this);
            if this.has_noise > 0
                this.noise_stream = RandStream("mlfg6331_64", "Seed", this.noise_params.seed);
            end
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
            [this, y1] = step_no_noise(this, u(1, :), t, dt);
            y = zeros(size(u, 1), size(y1, 1));
            y(1, :) = y1;
            for i=2:size(u, 1)
                [this, y(i, :)] = step_no_noise(this, u(i, :), t, dt);
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


classdef (Abstract) Controller
    %CONTROLLER Base class for all controllers
    
    properties (Abstract, Constant)
       param_description
    end

    properties
        params
        input_size
        output_size
        data
        library_name
    end

    methods (Abstract)
       % called right after parameters and sizes have been set to configure
       % the class 
       on_configure(this); 
       % called every step to produce new output for the system
       on_step(this, y_ref, y, dt, varargin);

       % called to reset the controller behavior
       on_reset(this);
    end

    methods
        function this = Controller(args)
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
                    case 'Dims'
                        validate_dims_struct(value);
                        data = this.create_data_model(this.params, value);
                    case 'Data'
                        data = value;
                    case 'library'
                        library_name = value;
                    otherwise
                        warning(['Unexpected parameter name "', as_char, '"']);
                end
            end
            if isempty(data)
                error("Data not set");
            end
            this.data = data;
            this.library_name = library_name;

        end
        
        function this = configure(this, varargin)
            is_simulink = 0;
            if nargin > 1
                is_simulink = varargin{1};
            end

            simulink_in_size = 0;
            if nargin > 2
                simulink_in_size = varargin{2};
            end

            if nargin > 3
                ref_size = varargin{3};
                if ref_size(end) ~= simulink_in_size(1)
                    error('Dimensions of y and y_ref not consistent..');
                end
            end

            this = on_configure(this);
        end

        function [this, u, log] = step(this, y_ref, y, dt, varargin)

            [this, u] = on_step(this, y_ref, y, dt, varargin{:});

            log = evaluate_m_controller_log(class(this), this.library_name, this.data);
        end

        function this = reset(this)
            this = on_reset(this);
        end

    end
end


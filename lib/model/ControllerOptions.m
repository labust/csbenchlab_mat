classdef ControllerOptions
    %CONTROLLEROPTIONS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Name
        IsComposable
        Components
        Params
        Path
        Mux
        RefHorizon
        RegenerateEnv
    end
    
    methods
        function obj = ControllerOptions(varargin)

            begin_idx = 1;
            if nargin > 0 && isa(varargin{1}, 'ControllerOptions')
                obj = varargin{1};
                begin_idx = 2;
            else
                obj.Name = '';
                obj.IsComposable = 0;
                obj.Components = {};
                obj.Params = '';
                obj.Path = {};
                obj.Mux.Inputs = [];
                obj.Mux.Outputs = [];
                obj.RegenerateEnv = 1;
                obj.RefHorizon = 1;
            end

               % Loop through the parameter names and not the values.
            for i = begin_idx:2:length(varargin)

                if isstring(varargin{i})
                    as_char = convertStringsToChars(varargin{i});
                else
                    as_char = varargin{i};
                end
                value = varargin{i+1};

                if strcmp(as_char, 'Components')
                    if ~isempty(value)
                        obj.IsComposable = 1;
                            
                        for j=1:length(value)
                            fs = fieldnames(value{j});
                            comp = struct;
                            for k = 1:length(fs)
                                f = fs{k};
                                comp = set_value(comp, f, value{j}.(f));
                            end
                            obj.Components{j} = comp;
                        end
                    end
                else
                    obj = set_value(obj, as_char, value);
                end

            end

        end

        function obj = set_value(obj, name, value)
            switch name
                case 'Name' 
                    obj.Name = value;
                case 'Path'
                    obj.Path = value;  
                case 'Params'
                    obj.Params = value;  
                case 'Mux'
                    obj.Mux = value;
                case 'RefHorizon'
                    obj.RefHorizon = value;
                case 'RegenerateEnv'
                    obj.RegenerateEnv = value;
                otherwise
                    warning(['Unexpected parameter name "', name, '"']);
            end
        end

        
    end
end


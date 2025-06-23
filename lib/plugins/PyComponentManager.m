classdef PyComponentManager < ComponentManager
    %PYSETUPCOMPONENT Summary of this class goes here
    %   Detailed explanation goes here
    
   
    methods (Static)
        function data = create_component_data_model(class_name, lib_name, params, mux)
            m = get_python_module(class_name, lib_name);
            py_data = m.(class_name).create_data_model(m.(class_name), params, mux);
            data = py_parse_component_data(py_data);
        end

        function res = instantiate_component(class_name, lib_name, varargin)
            m = get_python_module(class_name, lib_name);
            cls = m.(class_name);
            res = cls(varargin{:});
        end


        function resolved = make_component_params(name, lib_name, param_values)
            if ~exist('param_values', 'var')
                param_values = struct;
            end
            desc = get_py_component_params(name, lib_name);
        
        
            resolved = struct;
            for i=1:length(desc)
                p = desc{i};
                
                exists = isfield(param_values, p.Name);
                if exists
                    resolved.(p.Name) = param_values.(p.Name);
                    continue
                end
        
                if ~exists
                    if isa(p.DefaultValue, 'py.function')
                        resolved.(p.Name) = double(p.DefaultValue(resolved));
                    else
                        try
                            resolved.(p.Name) =  double(p.DefaultValue);
                        catch
                            error(strcat("Error making python params. Cannot parse parameter " + ...
                                p.Name, "' as double."));
                        end
                    end
                end
            end
        end

        function params = get_component_params(comp_name, lib_name)
            info = get_plugin_info_from_lib(comp_name, lib_name);
            params = PyComponentRegister.get_component_params_from_file(info.ComponentPath);
        end


        function logs = get_component_log_description(comp_name, lib_name)
            info = get_plugin_info_from_lib(comp_name, lib_name);
            logs = PyComponentRegister.get_component_log_description_from_file(info.ComponentPath);
        end

        function inputs = get_component_inputs(comp_name, lib_name)
            info = get_plugin_info_from_lib(comp_name, lib_name);
            inputs = PyComponentRegister.get_component_input_description_from_file(info.ComponentPath);
        end

        function outputs = get_component_outputs(comp_name, lib_name)
           info = get_plugin_info_from_lib(comp_name, lib_name);
           outputs = PyComponentRegister.get_component_output_description_from_file(info.ComponentPath);
        end
        
      
    end
end


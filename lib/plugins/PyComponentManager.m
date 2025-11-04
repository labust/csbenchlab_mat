classdef PyComponentManager < ComponentManager
    %PYSETUPCOMPONENT Summary of this class goes here
    %   Detailed explanation goes here
    
   
    methods (Static)

        function data = create_component_data_model(class_name, lib_name, params, mux)
            m = get_python_module(class_name, lib_name);
            py_data = m.(class_name).create_data_model(params, mux);
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
            desc = PyComponentManager.get_component_params(name, lib_name);
        
        
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

        function type_dict = setup_component(block_path, type_dict, hws)
            l_info = libinfo(block_path);
            c_path = getfullname(block_path);
            m = PyComponentManager;
        
            class_name = get_component_class_name(l_info(1).ReferenceBlock);    
            lib_name = get_component_script_parameter_ref(l_info(1).ReferenceBlock, '__lib_name');
            log_desc = m.get_component_log_description(class_name, lib_name);
            io_args = m.get_component_inputs(class_name, lib_name);
            is_controller = is_block_component_of_type(block_path, 'ctl');

            params = get_component_params_from_block(c_path);
            mux = struct;
            if is_controller
                try
                    mux = get_controller_mux_struct(c_path);
                catch
                    mux = evalin('base', 'mux');
                end
            end
            name =  make_class_name(c_path);
            if length(name) > namelengthmax
                error(strcat("Name '", name, "' is larger than max. Consider renaming components."));
            end     

            data = m.create_component_data_model(class_name, lib_name, params, mux);
               
            data_name = strcat(name, '_data');
            hws.assignin(data_name, data);
            type_dict = m.generate_busses(name, 0, data, log_desc, io_args, type_dict);

        end
        
      
    end
end


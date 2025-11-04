classdef MatComponentManager  < ComponentManager
    

    methods (Static)

        function data = create_component_data_model(class_name, ~, params, mux)
    
            add_mux_arg_str = "";
            if ~isempty(mux)
                add_mux_arg_str = ", mux";
            end

            try
                data = eval(strcat(class_name, '.create_data_model(params', add_mux_arg_str, ');'));
            catch ME
                if strcmp(ME.identifier,  'MATLAB:subscripting:classHasNoPropertyOrMethod')
                    data = 0;
                    % error(['Class ', class_name, ' must implement static method create_data_model']);
                else
                    warning(strcat('Error calling "', class_name, '.create_data_model'));
                    rethrow(ME);
                end
            end

        end

        function params = get_component_params(class_name, ~)
            params = {};
            try
                eval(strcat("params = ", class_name, ".param_description;"));
            catch ME
            end
        end


        function logs = get_component_log_description(class_name, ~)
            logs = {};
            try
                eval(strcat("logs = ", class_name, ".log_description;"));
            catch ME
            end
        end

        function inputs = get_component_inputs(class_name, ~)
            inputs = {};
            try
                eval(strcat("inputs = ", class_name, ".input_description;"));
            catch ME
            end
        end

        function inputs = get_component_outputs(class_name, ~)
            inputs = {};
            try
                eval(strcat("outputs = ", class_name, ".output_description;"));
            catch ME
            end
        end

        function resolved = make_component_params(class_name, ~, param_values)
    
            if ~exist('param_values', 'var')
                param_values = struct;
            end
            desc = eval(strcat(class_name, '.param_description'));
        
            resolved = struct;
            for i=1:length(desc)
                p = desc{i};
                
                exists = isfield(param_values, p.Name);
                if exists
                    resolved.(p.Name) = param_values.(p.Name);
                    continue
                end
        
                if ~exists
                    if isa(p.DefaultValue, 'function_handle')
                        resolved.(p.Name) = p.DefaultValue(resolved);
                    else
                        resolved.(p.Name) =  p.DefaultValue;
                    end
                end
            end
        
        end

        function type_dict = setup_component(block_path, type_dict, hws)
            l_info = libinfo(block_path);
            c_path = getfullname(block_path);
            is_controller = is_block_component_of_type(block_path, 'ctl');
        
        
            class_name = get_component_class_name(l_info(1).ReferenceBlock);    
            lib_name = get_component_script_parameter_ref(l_info(1).ReferenceBlock, '__lib_name');
            m = MatComponentManager;
        
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

            params = get_component_params_from_block(c_path);
            data = m.create_component_data_model(class_name, lib_name, params, mux);
            io_args = m.get_component_inputs(class_name, lib_name);
            log_desc = m.get_component_log_description(class_name, lib_name);
            
            data_name = strcat(name, '_data');
            hws.assignin(data_name, m.replace_indexers_(data));
            
            type_dict = m.generate_busses(name, params, data, log_desc, io_args, type_dict);
            
        end

        % function set_function_input_type_(handle, input_port_idx, type_name)
        % 
        %     lhs = get_param(handle, 'LineHandles');
        %     src = get_param(lhs.Inport(input_port_idx), 'SrcBlockHandle');
        %     name = get_param(handle, 'Name');
        %     fname = getfullname(handle);
        %     parname = strrep(fname, name, '');
        %     parname = parname(1:end-1);
        % 
        %     ok = 1;
        %     while 1
        %         if slreportgen.utils.isMATLABFunction(src)
        %             break
        %         end
        %         % TODO: Recursive search through subsystems
        %         ok = 0;
        %         break
        %     end
        % 
        %     if ok == 0
        %         error(['Complex input parameters require MATLAB Function block ' ...
        %             'as inputs']);
        %     end
        % 
        %     f_lhs = get_param(src, 'LineHandles');
        %     for i=1:length(f_lhs.Outport)
        %         if get_param(f_lhs.Outport(i), 'DstBlockHandle') == handle
        %             break
        %         end
        %     end
        % 
        %     fun_block = get_function_block(parname, get_param(src, 'Name'));
        % 
        %     fun_block.Outputs(i).DataType = type_name;
        % 
        % end
        
        
        
    end
end


classdef PyComponentRegister < ComponentRegister
    %SLXCOMPONENTREGISTER Summary of this class goes here
    %   Detailed explanation goes here

    
    methods (Static)
        function info = get_plugin_info(~, plugin_path)
            info = struct;
        
            f = fullfile(get_app_python_src_path(), 'registry', 'get_plugin_info.py');
            plugin_info = run_py_file(f, "plugin_info", '--plugin_path', plugin_path);
        
            info.T = int32(plugin_info{"T"});
            info.Name = string(plugin_info{"Name"});
            % info.Info = plugin_info;
            info.HasParameters = int32(plugin_info{"HasParameters"});   
        end

        function instance = instantiate_plugin(plugin_path)        
            f = fullfile(get_app_python_src_path(), 'registry', 'instantiate_plugin.py');
            instance = run_py_file(f, "instance", '--plugin_path', plugin_path);
        end


        function register(info, t, lib_name)
            if t == 1
                register_py_component(info, 'sys', lib_name, { '__cs_slx_sys' });
            elseif t == 2
                PyComponentRegister.register_controller_(info, lib_name);
            elseif t == 3
                register_py_component(info, 'est', lib_name, { '__cs_slx_est' });
            elseif t == 4
                register_py_component(info, 'dist', lib_name, { '__cs_slx_dist' });
            end
        end

        function params = get_component_params_from_file(file_path)
            try
                params = cell(py_parse_param_description( ...
                    eval_python_class_field(file_path, 'param_description')));
            catch ME
                warning('Error getting python parameters.')
                rethrow(ME);
            end
        end

        function logs = get_component_log_description_from_file(file_path)
            try
                logs = cell(py_parse_log_description( ...
                    eval_python_class_field(file_path, 'log_description')));
            catch ME
                warning('Error getting python parameters.')
                rethrow(ME);
            end
        end


        function inputs = get_component_input_description_from_file(file_path)
            try
                inputs = cell(py_parse_io_description( ...
                    eval_python_class_field(file_path, 'input_description')));
            catch ME
                warning('Error getting component inputs.')
                rethrow(ME);
            end
            
        end

        function outputs = get_component_output_description_from_file(file_path)
            try
                outputs = cell(py_parse_io_description( ...
                    eval_python_class_field(file_path, 'output_description')));
            catch ME
                warning('Error getting component outputs.')
                rethrow(ME);
            end
        end

        function register_controller_(info, lib_name)
            default_inputs = { 'y_ref', 'y', 'dt' };
            default_outputs = {'u'};
            input_args = cellfun(@(x) string(x.Name), ...
                PyComponentRegister.get_component_input_description_from_file(info.ComponentPath));
            output_args = cellfun(@(x) string(x.Name), ...
                PyComponentRegister.get_component_output_description_from_file(info.ComponentPath));
            
            input_args_desc = create_argument_description([default_inputs, input_args, 'u_ic', 'params', 'data']);
            output_args_desc = create_argument_description([default_outputs, output_args]);
        
            % params
            input_args_desc(end-2).DataType = 'double';
            input_args_desc(end-2).Scope = 'Parameter';
            input_args_desc(end-2).Tunable = 0;
            input_args_desc(end-1).DataType = 'ParamsType';
            input_args_desc(end-1).Scope = 'Parameter';
            input_args_desc(end).DataType = 'DataType';
            input_args_desc(end).Scope = 'Parameter';
        
            % set io types type names
            for j=length(default_inputs)+1:length(default_inputs)+length(input_args)
                input_args_desc(j).DataType = ...
                    strcat(input_args_desc(j).Name, "_T");
            end
            for j=length(default_outputs)+1:length(default_outputs)+length(output_args)
                output_args_desc(j).DataType = ...
                    strcat(output_args_desc(j), "_T");
            end
           
            % set mask parameters
            if info.HasParameters
                params_visible = 'on';
            else
                params_visible = 'off';
            end
        
            mask_parameters = struct('Name', 'params', 'Prompt', 'Parameter struct:', ...
                'Value', '{block_name}_params', 'Visible', params_visible, 'Evaluate', 'on');
            mask_parameters(end+1) = struct('Name', 'data', ...
                'Value', '{block_name}_data', 'Visible', 'off', 'Prompt', '', 'Evaluate', 'on');
            mask_parameters(end+1) = struct('Name', 'ParamsType', ...
                'Value', '{block_name}_PT', 'Visible', 'off', 'Prompt', '', 'Evaluate', 'on');
            mask_parameters(end+1) = struct('Name', 'DataType', ...
                'Value', '{block_name}_DT', 'Visible', 'off', 'Prompt', '', 'Evaluate', 'on');
            mask_parameters(end+1) = struct('Name', 'u_ic', ...
                'Value', '0', 'Visible', 'off', 'Prompt', '', 'Evaluate', 'on');

            for j=1:length(input_args)
                n = strcat(input_args{j}, '_T');
                v = strcat(info.Name, "_", input_args{j}, "_T");
                mask_parameters(end+1) = struct('Name', n, 'Value', v, 'Visible', 'off', 'Prompt', '', 'Evaluate', 'on');
            end
            for j=1:length(output_args)
                n = strcat(output_args{j}, '_T');
                v = strcat(info.Name, "_", output_args{j}, "_T");
                mask_parameters(end+1) = struct('Name', n, 'Value', v, 'Visible', 'off', 'Prompt', '', 'Evaluate', 'on');
            end
            icon = 'controller_icon';
            add_logging = 1;
            extrinsic_init = "u = u_ic;" + newline + "data_n = data;" + newline;
            create_component_simulink(info, lib_name, 'ctl', ...
                {"__cs_py_ctl"}, 'py_component_simulink_template', input_args_desc, output_args_desc, ...
                {"'Params'", "params", "'Data'", "data"}, ...
                {'u_ic', 'size(y)', 'size(y_ref)'}, [{'y_ref', 'y', 'dt'}, input_args], ...
                add_logging, mask_parameters, extrinsic_init, icon, [120, 40]);
        
        end


    end
end


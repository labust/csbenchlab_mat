classdef MatComponentRegister < ComponentRegister
    %SLXCOMPONENTREGISTER Summary of this class goes here
    %   Detailed explanation goes here

    
    methods (Static)
        function info = get_plugin_info(class_name, ~)
            info = struct;
            info.T = 0;
            info.Name = class_name;
            if exist(class_name, 'class')
                mcls = meta.class.fromName(class_name);
                if mcls.Abstract
                    return
                end
                
                for k=1:length(mcls.SuperclassList)
                    if strcmp(mcls.SuperclassList(k).Name, 'DynSystem')
                        t = 1; 
                        break;
                    end
                    if strcmp(mcls.SuperclassList(k).Name, 'Controller')
                        t = 2;
                        break;
                    end
                    if strcmp(mcls.SuperclassList(k).Name, 'Estimator')
                        t = 3;
                        break;
                    end
                    if strcmp(mcls.SuperclassList(k).Name, 'DisturbanceGenerator')
                        t = 4;
                        break;
                    end
                end
                
                props = arrayfun(@(x) strcmp(x.Name, 'param_description'), mcls.PropertyList);
                value = mcls.PropertyList(props);
                info.HasParameters = ~isempty(value); 
                info.T = t;
                
                info.Mcls = mcls;
            end
        end
        
        function register(info, t, lib_name)
           if t == 1
               MatComponentRegister.register_system_(info, lib_name);
           elseif t == 2
               MatComponentRegister.register_controller_(info, lib_name);
           elseif t == 3
               MatComponentRegister.register_estimator_(info, lib_name);
           elseif t == 4
               MatComponentRegister.register_disturbance_generator_(info, lib_name);
            end
        end

        function register_system_(info, lib_name)
    
            default_inputs = {'u', 't', 'dt', 'ic'};
            default_outputs = {'y'};
            cm = MatComponentManager;
            input_args = cellfun(@(x) string(x.Name), cm.get_component_inputs(info.Name));
            output_args = cellfun(@(x) string(x.Name), cm.get_component_outputs(info.Name));
            
            input_args_desc = create_argument_description([default_inputs, input_args, 'params_merged', 'data']);
            output_args_desc = create_argument_description([default_outputs, output_args]);
        
            % params
            input_args_desc(end-1).DataType = 'ParamsType';
            input_args_desc(end-1).Scope = 'Parameter';
            input_args_desc(end).DataType = 'DataType';
            input_args_desc(end).Scope = 'Parameter';
        
            % set io types types
            for j=length(default_inputs):length(default_inputs)+length(input_args)-1
                input_args_desc(j).DataType = ...
                    strcat(input_args_desc(j).Name, "_T");
            end
            for j=length(default_outputs):length(default_outputs)+length(output_args)-1
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
            mask_parameters(end+1) = struct('Name', 'params_merged', 'Value', ...
                '{block_name}_params_merged', 'Visible', 'off', 'Prompt', '', 'Evaluate', 'on');
            mask_parameters(end+1) = struct('Name', 'data', ...
                'Value', '{block_name}_data', 'Visible', 'off', 'Prompt', '', 'Evaluate', 'on');
            mask_parameters(end+1) = struct('Name', 'ParamsType', ...
                'Value', '{block_name}_PT', 'Visible', 'off', 'Prompt', '', 'Evaluate', 'on');
            mask_parameters(end+1) = struct('Name', 'DataType', ...
                'Value', '{block_name}_DT', 'Visible', 'off', 'Prompt', '', 'Evaluate', 'on');
        
        
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
            
            icon = 'system_icon';
            extrinsic_init = "y = zeros(size(ic))";
            create_component_simulink(info, lib_name, 'sys', ...
                {"__cs_m_sys"}, 'm_component_simulink_template', input_args_desc, output_args_desc, ...
                {"'Params'", 'params_merged', "'Data'", 'data'}, ...
                { 'ic' }, [{'u', 't', 'dt'}, input_args], ...
                mask_parameters, extrinsic_init, icon, [100, 40]);
        end

        function register_controller_(info, lib_name)
    
            default_inputs = { 'y_ref', 'y', 'dt' };
            default_outputs = {'u'};
            cm = MatComponentManager;
            input_args = cellfun(@(x) string(x.Name), cm.get_component_inputs(info.Name));
            output_args = cellfun(@(x) string(x.Name), cm.get_component_outputs(info.Name));
            
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
            extrinsic_init = "u = u_ic;";
            create_component_simulink(info, lib_name, 'ctl', ...
                {"__cs_m_ctl"}, 'm_component_simulink_template', input_args_desc, output_args_desc, ...
                {"'Params'", "params", "'Data'", "data"}, ...
                {'u_ic', 'size(y)', 'size(y_ref)'}, [{'y_ref', 'y', 'dt'}, input_args], ...
                mask_parameters, extrinsic_init, icon, [120, 40]);
        
        end

        function register_estimator_(info, lib_name)
    
            default_inputs = {'y', 'dt', 'ic'};
            default_outputs = {'y_hat'};
            cm = MatComponentManager;
            input_args = cellfun(@(x) string(x.Name), cm.get_component_inputs(info.Name));
            output_args = cellfun(@(x) string(x.Name), cm.get_component_outputs(info.Name));
            
            input_args_desc = create_argument_description([default_inputs, input_args, 'params', 'data']);
            output_args_desc = create_argument_description([default_outputs, output_args]);
        
            % params
            input_args_desc(end-1).DataType = 'ParamsType';
            input_args_desc(end-1).Scope = 'Parameter';
            input_args_desc(end).DataType = 'DataType';
            input_args_desc(end).Scope = 'Parameter';
        
            % set io types types
            for j=length(default_inputs):length(default_inputs)+length(input_args)-1
                input_args_desc(j).DataType = ...
                    strcat(input_args_desc(j).Name, "_T");
            end
            for j=length(default_outputs):length(default_outputs)+length(output_args)-1
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
        
            % for some reason, disabling of rotation 
            % programatiaclly does not work!
            icon = 'estimator_icon_mirror';
            extrinsic_init = "y_hat = zeros(size(ic))";
            create_component_simulink(info, lib_name, 'est', ...
                {"__cs_m_est"}, 'm_component_simulink_template', input_args_desc, output_args_desc, ...
                {"'Params'", 'params', "'Data'", 'data'}, ...
                { 'ic' }, [{'y', 'dt'}, input_args], ...
                mask_parameters, extrinsic_init, icon, [60, 40]);
        end

        function register_disturbance_generator_(info, lib_name)

            default_inputs = {'y', 'dt'};
            default_outputs = {'y_n'};
            cm = MatComponentManager;

            input_args = cellfun(@(x) string(x.Name), cm.get_component_inputs(info.Name));
            output_args = cellfun(@(x) string(x.Name), cm.get_component_outputs(info.Name));
            
            input_args_desc = create_argument_description([default_inputs, input_args, 'params', 'data']);
            output_args_desc = create_argument_description([default_outputs, output_args]);
        
            % params
            input_args_desc(end-1).DataType = 'ParamsType';
            input_args_desc(end-1).Scope = 'Parameter';
            input_args_desc(end).DataType = 'DataType';
            input_args_desc(end).Scope = 'Parameter';
        
            % set io types types
            for j=length(default_inputs):length(default_inputs)+length(input_args)-1
                input_args_desc(j).DataType = ...
                    strcat(input_args_desc(j).Name, "_T");
            end
            for j=length(default_outputs):length(default_outputs)+length(output_args)-1
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
            icon = 'disturbance_icon';
            extrinsic_init = "y_n = zeros(size(y))";
            create_component_simulink(info, lib_name, 'dist', ...
                {"__cs_m_dist"}, 'm_component_simulink_template', input_args_desc, output_args_desc, ...
                {"'Params'", 'params', "'Data'", 'data'}, ...
                { }, [{'y', 'dt'}, input_args'], ...
                mask_parameters, extrinsic_init, icon, [60, 40]);
        end
    end
end


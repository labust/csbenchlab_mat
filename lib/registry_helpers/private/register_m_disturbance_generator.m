function register_m_disturbance_generator(info, lib_name)

    default_inputs = {'y', 'dt'};
    default_outputs = {'y_n'};
    input_args = cellfun(@(x) string(x.Name), get_m_component_inputs(info.Name));
    output_args = cellfun(@(x) string(x.Name), get_m_component_outputs(info.Name));
    
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
    mask_parameters(end+1) = struct('Name', 'iid__', ...
        'Value', '[0]', 'Visible', 'off', 'Prompt', '', 'Evaluate', 'on');
    v = mat2str(uint8(encode_plugin_id(info.Name, lib_name)));
    mask_parameters(end+1) = struct('Name', 'pid__', ...
        'Value', v, 'Visible', 'off', 'Prompt', '', 'Evaluate', 'on');


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

    create_m_component_simulink(info, lib_name, 'dist', ...
        {"__cs_m_dist"}, input_args_desc, output_args_desc, ...
        {'params', "'Data'", 'data'}, ...
        { }, [{'y', 'dt'}, input_args'], ...
        mask_parameters, extrinsic_init, icon, [60, 40]);
end

function mask_parameters = get_component_default_mask_params(info, lib_name, add_logging)
    
    % default component parameters
    
    mask_parameters = struct('Name', 'iid__', ...
        'Value', '[0]', 'Visible', 'off', 'Prompt', '', 'Evaluate', 'on');
    v = mat2str(uint8(encode_plugin_id(info.Name, lib_name)));
    mask_parameters(end+1) = struct('Name', 'pid__', ...
        'Value', v, 'Visible', 'off', 'Prompt', '', 'Evaluate', 'on');
    mask_parameters(end+1)  = struct('Name', 'context_path', ...
                    'Value', '', 'Visible', 'off', 'Prompt', '', 'Evaluate', 'off');
    mask_parameters(end+1)  = struct('Name', 'params', ...
                    'Value', '', 'Visible', 'off', 'Prompt', '', 'Evaluate', 'on');
    
    if add_logging
        mask_parameters(end+1) = struct('Name', 'LogEntryType', ...
            'Value', '{block_name}_LT', 'Visible', 'off', 'Prompt', '', 'Evaluate', 'on');
    end

end
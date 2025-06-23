function set_block_mask_parameters(handle, block_name, mask_parameters, info, lib_name, add_logging)
    
    % default component parameters
    mask_parameters(end+1) = struct('Name', 'LogEntryType', ...
        'Value', '{block_name}_LT', 'Visible', 'off', 'Prompt', '', 'Evaluate', 'on');
    mask_parameters(end+1) = struct('Name', 'iid__', ...
        'Value', '[0]', 'Visible', 'off', 'Prompt', '', 'Evaluate', 'on');
    v = mat2str(uint8(encode_plugin_id(info.Name, lib_name)));
    mask_parameters(end+1) = struct('Name', 'pid__', ...
        'Value', v, 'Visible', 'off', 'Prompt', '', 'Evaluate', 'on');

    mo = get_param(handle, 'MaskObject');
    if isempty(mo)
        mo = Simulink.Mask.create(handle);
    end

    for i=1:length(mask_parameters)
        mo.addParameter('Name', mask_parameters(i).Name, ...
            'Value', replace(mask_parameters(i).Value, '{block_name}', block_name), ...
            'Visible', mask_parameters(i).Visible, ...
            'Prompt', mask_parameters(i).Prompt, ...
            'Evaluate', mask_parameters(i).Evaluate);
    end
    
    set_param(handle, 'MaskObject', mo);

end
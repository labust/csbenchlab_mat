function set_block_mask_parameters(handle, block_name, mask_parameters)
    
    
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
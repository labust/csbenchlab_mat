function setup_simulink_component_instance_id(comp)
    v = mat2str(uint8(convertStringsToChars(new_uuid)));
    set_mask_values(comp, 'iid__', v);
end


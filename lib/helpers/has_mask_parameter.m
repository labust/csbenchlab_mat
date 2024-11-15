function t = has_mask_parameter(handle, name)
    
    t = 0;
    mo = get_param(handle, 'MaskObject');
    for j=1:length(mo.Parameters)
        mo_p = mo.Parameters(j);
        if strcmp(name, mo_p.Name)
            t = 1;
            break
        end
    end
end


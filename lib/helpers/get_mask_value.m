function v = get_mask_value(handle, name)

    mo = get_param(handle, 'MaskObject');
    for j=1:length(mo.Parameters)
        mo_p = mo.Parameters(j);
        if strcmp(name, mo_p.Name)
            v = mo_p.Value;
            return
        end
    end

    error(strcat("Mask parameter '", name, "' does not exist"));

end


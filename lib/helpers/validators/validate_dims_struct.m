function t = validate_dims_struct(dims)
    
    t = 1;
    if is_valid_field(dims, 'Input') == 0 || ...
         is_valid_field(dims, 'Output') == 0
        t = 0;
    end

end


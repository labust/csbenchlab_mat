function t = get_model_blocks_with_tag(model, tag)
    
    if isa(model, "char") || isa(model, "string")
        model_h = get_param(model, 'Handle');
    else
        model_h = model;
    end

    if block_has_tag(model_h, tag)
        t = model_h;
        return
    end
    
    blocks = recurse_blocks(model_h);

    indices = [];
    for i=1:length(blocks)
        if block_has_tag(blocks(i), tag)
            indices(end+1) = i;
        end
    end
    t = blocks(indices);
end


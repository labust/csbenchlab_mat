function t = is_block_component_of_type(handle, typ)
    t = strcmp(get_block_component_type(handle), typ);
end



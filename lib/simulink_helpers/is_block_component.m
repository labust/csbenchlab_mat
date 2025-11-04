function t = is_block_component(handle, typ, impl)
    t = strcmp(get_block_component_type(handle), typ) ...
        && strcmp(get_block_component_implementation(handle), impl);
end



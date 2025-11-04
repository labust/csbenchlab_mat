function context_path = get_component_context_path_from_block(env_name, block_path)
    iid_str = char(eval(get_mask_value(block_path, 'iid__')));
    [~, params] = get_env_param_struct(env_name);
    context_path = params.ComponentContext(iid_str);
end


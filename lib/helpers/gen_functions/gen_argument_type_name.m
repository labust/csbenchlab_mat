function type_name = gen_argument_type_name(block_path, path, arg_name)
    
    p = strcat(block_path, "/", path);
    type_name = get_argument_type_name(p, arg_name);
end


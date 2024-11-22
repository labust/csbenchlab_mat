function o = get_function_block(block_path, fun_block_name)
    o = find(get_param(block_path, "Object"), ...
        "-isa", "Stateflow.EMChart", "Name", fun_block_name);
end


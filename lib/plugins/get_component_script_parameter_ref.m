function n = get_component_script_parameter_ref(lib_path, param_name)
    
    if ~iscell(param_name)
        param_name = {param_name};
    end

    b_h = getSimulinkBlockHandle(lib_path);

    d1_blocks = find_system(b_h, 'SearchDepth', 1, ...
        'FollowLinks', 'on', 'LookUnderMasks', 'all');
    
    found = 0;
    n = string({});
    for i=1:length(d1_blocks)
        % there should be single matlab function block
        if slreportgen.utils.isMATLABFunction(d1_blocks(i))
            if found == 1
                error('Multiple function blocks found in controller.');
            end
            found = 1;
            fun_block_name = get_param(d1_blocks(i), 'Name');
            fun_block = get_function_block(lib_path, fun_block_name);
            
            if isempty(fun_block)
                error(strcat("Function block '", fun_block_name, "' does not exist."));
            end
            for j=1:length(param_name)
                n(j) = get_script_parameter(fun_block.Script, param_name{j});
            end
            break
        end
    end
end


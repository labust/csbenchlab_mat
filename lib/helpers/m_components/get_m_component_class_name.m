function n = get_m_component_class_name(lib_path)
    
    b_h = getSimulinkBlockHandle(lib_path);

    d1_blocks = find_system(b_h, 'SearchDepth', 1, ...
        'FollowLinks', 'on', 'LookUnderMasks', 'all');
    
    found = 0;
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
                error(strcat('Function block ', fun_block_name, ' does not exist.'));
            end
            n = get_script_parameter(fun_block.Script, '__classname');

        end
    end
end


function setup_simulink_extrinsic_functions(curr_model, info, blocks)
    ext_value = 0;
    if isfield(info.Metadata, 'Extrinsic')
        ext_value = info.Metadata.Extrinsic;
    end
    mws = get_param(curr_model, 'modelworkspace');
    mws.assignin('extrinsic', ext_value);

    for i=1:length(blocks.cs_blocks)
        b = blocks.cs_blocks{i};

        if model_has_tag(b, '__cs_m')
            setup_m_extrinsics(b, curr_model);
        elseif model_has_tag(b, '__cs_py')
            setup_py_extrinsics(b, curr_model);  
        end
    end
end


function setup_m_extrinsics(b, curr_model)
    linfo = libinfo(b);

    block_path = linfo.ReferenceBlock;
    block_name = split(block_path, '/');
    block_name = block_name{end};
    fun_block_name = [block_name, '_fun'];

    fun_block = get_function_block(block_path, fun_block_name);

    classname = get_script_parameter(fun_block.Script, '__classname');
    fnname = get_script_parameter(fun_block.Script, '__fnname');
    input_args = get_script_parameter(fun_block.Script, '__input_args');
    output_args = get_script_parameter(fun_block.Script, '__output_args');
    ctor_args = get_script_parameter(fun_block.Script, '__ctor_args');
    cfg_args = get_script_parameter(fun_block.Script, '__cfg_args');
    step_args = get_script_parameter(fun_block.Script, '__step_args');

    if isscalar(split(output_args, ','))
        out_args_bracketed = output_args;
    else
        out_args_bracketed = strcat('[', output_args, ']');
    end


    ext_fun_script = fileread(fullfile(get_app_template_path(), 'eval_extrinsic_m_component_template.mt'));
    
    new_name = strcat(fnname, '_ext');
    ext_fun_script_new = replace(ext_fun_script, '{{function_name}}', new_name);
    ext_fun_script_new = replace(ext_fun_script_new, '{{class_name}}', classname);
    ext_fun_script_new = replace(ext_fun_script_new, '{{input_args}}', input_args);
    ext_fun_script_new = replace(ext_fun_script_new, '{{ctor_args}}', ctor_args);
    ext_fun_script_new = replace(ext_fun_script_new, '{{cfg_args}}', cfg_args);
    ext_fun_script_new = replace(ext_fun_script_new, '{{step_args}}', step_args);
    ext_fun_script_new = replace(ext_fun_script_new, '{{comp_outputs}}', output_args);
    ext_fun_script_new = replace(ext_fun_script_new, '{{output_args_bracketed}}', out_args_bracketed);

    [env_path, ~] = fileparts(which(curr_model));
    ext_file = fullfile(env_path, 'autogen', strcat(new_name, '.m'));
    if ~exist(ext_file, 'file')
        f = fopen(ext_file, "w");
        fprintf(f, ext_fun_script_new);
        fclose(f);
    end
end


function setup_py_extrinsics(b, curr_model)
    linfo = libinfo(b);

    block_path = linfo.ReferenceBlock;
    block_name = split(block_path, '/');
    block_name = block_name{end};
    fun_block_name = [block_name, '_fun'];

    fun_block = get_function_block(block_path, fun_block_name);

    classname = get_script_parameter(fun_block.Script, '__classname');
    fnname = get_script_parameter(fun_block.Script, '__fnname');
    input_args = get_script_parameter(fun_block.Script, '__input_args');
    output_args = get_script_parameter(fun_block.Script, '__output_args');
    ctor_args = get_script_parameter(fun_block.Script, '__ctor_args');
    cfg_args = get_script_parameter(fun_block.Script, '__cfg_args');
    step_args = get_script_parameter(fun_block.Script, '__step_args');
    lib_name = get_script_parameter(fun_block.Script, '__lib_name');

    output_args = "data_n, " + output_args;
    if isscalar(split(output_args, ','))
        out_args_bracketed = output_args;
    else
        out_args_bracketed = strcat('[', output_args, ']');
    end

    parse_outputs = "u = double(result)';";
    ext_fun_script = fileread(fullfile(get_app_template_path(), 'eval_extrinsic_py_component_template.mt'));
    
    new_name = strcat(fnname, '_ext');
    ext_fun_script_new = replace(ext_fun_script, '{{function_name}}', new_name);
    ext_fun_script_new = replace(ext_fun_script_new, '{{class_name}}', classname);
    ext_fun_script_new = replace(ext_fun_script_new, '{{lib_name}}', lib_name);
    ext_fun_script_new = replace(ext_fun_script_new, '{{input_args}}', input_args);
    ext_fun_script_new = replace(ext_fun_script_new, '{{ctor_args}}', ctor_args);
    ext_fun_script_new = replace(ext_fun_script_new, '{{cfg_args}}', cfg_args);
    ext_fun_script_new = replace(ext_fun_script_new, '{{step_args}}', step_args);
    ext_fun_script_new = replace(ext_fun_script_new, '{{output_args}}', output_args);
    ext_fun_script_new = replace(ext_fun_script_new, '{{output_args_bracketed}}', out_args_bracketed);
    ext_fun_script_new = replace(ext_fun_script_new, '{{parse_outputs}}', parse_outputs);

    [env_path, ~] = fileparts(which(curr_model));
    ext_file = fullfile(env_path, 'autogen', strcat(new_name, '.m'));
    if ~exist(ext_file, 'file')
        f = fopen(ext_file, "w");
        fprintf(f, ext_fun_script_new);
        fclose(f);
    end
end
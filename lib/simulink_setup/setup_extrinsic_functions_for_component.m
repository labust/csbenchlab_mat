function setup_extrinsic_functions_for_component(curr_model, handle, ext_value)
    if ~exist('ext_value', 'var')
        hws = get_param(curr_model, 'modelworkspace');
        ext_value = hws.getVariable('extrinsic');
    end
    if ext_value == 0
        return
    end
    if is_block_component_implementation(handle, 'mat')
        setup_m_extrinsics(handle, curr_model);
    elseif is_block_component_implementation(handle, 'py')
        setup_py_extrinsics(handle, curr_model);  
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
    fn_output_args = get_script_parameter(fun_block.Script, '__fn_output_args');
    ctor_args = get_script_parameter(fun_block.Script, '__ctor_args');
    cfg_args = get_script_parameter(fun_block.Script, '__cfg_args');
    step_args = get_script_parameter(fun_block.Script, '__step_args');

    if length(strsplit(fn_output_args, ',')) > 1
        output_args_fn = strcat('[', fn_output_args, ']');
    else
        output_args_fn = fn_output_args;
    end
    ext_fun_script = fileread(fullfile(CSPath.get_app_template_path(), 'eval_extrinsic_m_component_template.mt'));
    
    eval_log_fn_src = get_eval_log_fn_src(fun_block.Script);
    new_name = strcat(fnname, '_ext');
    ext_fun_script_new = replace(ext_fun_script, '{{function_name}}', new_name);
    ext_fun_script_new = replace(ext_fun_script_new, '{{class_name}}', classname);
    ext_fun_script_new = replace(ext_fun_script_new, '{{input_args}}', input_args);
    ext_fun_script_new = replace(ext_fun_script_new, '{{ctor_args}}', ctor_args);
    ext_fun_script_new = replace(ext_fun_script_new, '{{cfg_args}}', cfg_args);
    ext_fun_script_new = replace(ext_fun_script_new, '{{step_args}}', step_args);
    ext_fun_script_new = replace(ext_fun_script_new, '{{comp_outputs}}', output_args);
    ext_fun_script_new = replace(ext_fun_script_new, '{{output_args_fn}}', output_args_fn);
    ext_fun_script_new = replace(ext_fun_script_new, '{{eval_log_fn}}', eval_log_fn_src);
    ext_fun_script_new = replace(ext_fun_script_new, '{{env_name}}', curr_model);
    ext_fun_script_new = replace(ext_fun_script_new, '{{block_path}}', getfullname(b));

    [env_path, ~] = fileparts(which(curr_model));
    ext_file = fullfile(env_path, 'autogen', strcat(new_name, '.m'));
    if exist(ext_file, 'file')
        delete(ext_file);
    end
    f = fopen(ext_file, "w");
    fprintf(f, ext_fun_script_new);
    fclose(f);
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

    output_args = "log, " + output_args;
    if isscalar(split(output_args, ','))
        out_args_bracketed = output_args;
    else
        out_args_bracketed = strcat('[', output_args, ']');
    end

    parse_outputs = "u = double(result)';";
    ext_fun_script = fileread(fullfile(CSPath.get_app_template_path(), 'eval_extrinsic_py_component_template.mt'));
    eval_log_fn_src = get_eval_log_fn_src(fun_block.Script);

    new_name = strcat(fnname, '_ext');
    ext_fun_script_new = replace(ext_fun_script, '{{function_name}}', new_name);
    ext_fun_script_new = replace(ext_fun_script_new, '{{class_name}}', classname);
    ext_fun_script_new = replace(ext_fun_script_new, '{{lib_name}}', lib_name);
    ext_fun_script_new = replace(ext_fun_script_new, '{{input_args}}', input_args);
    ext_fun_script_new = replace(ext_fun_script_new, '{{ctor_args}}', ctor_args);
    ext_fun_script_new = replace(ext_fun_script_new, '{{cfg_args}}', cfg_args);
    ext_fun_script_new = replace(ext_fun_script_new, '{{eval_log_fn}}', eval_log_fn_src);
    ext_fun_script_new = replace(ext_fun_script_new, '{{step_args}}', step_args);
    ext_fun_script_new = replace(ext_fun_script_new, '{{output_args}}', output_args);
    ext_fun_script_new = replace(ext_fun_script_new, '{{output_args_bracketed}}', out_args_bracketed);
    ext_fun_script_new = replace(ext_fun_script_new, '{{parse_outputs}}', parse_outputs);
    ext_fun_script_new = replace(ext_fun_script_new, '{{env_name}}', curr_model);
    ext_fun_script_new = replace(ext_fun_script_new, '{{block_path}}', getfullname(b));

    [env_path, ~] = fileparts(which(curr_model));
    ext_file = fullfile(env_path, 'autogen', strcat(new_name, '.m'));
    if ~exist(ext_file, 'file')
        f = fopen(ext_file, "w");
        fprintf(f, ext_fun_script_new);
        fclose(f);
    end
end


function src = get_eval_log_fn_src(script)
    f = strfind(script, 'eval_log');
    start_idx = f(end) - 16;
    src = script(start_idx:end);

end
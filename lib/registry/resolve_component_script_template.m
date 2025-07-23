function fun_script_new = resolve_component_script_template(info, lib_name, ...
    template_name, function_name, classname, ...
    input_args, output_args, ctor_args, ...
    cfg_args, step_args, extrinsic_init, add_logging)

    if ~endsWith(template_name, '.mt')
        template_name = strcat(template_name, '.mt');
    end

    if add_logging
        output_args_fn = bracket_outputs(output_args + ", log");
        logging_define = generate_logging_function(info, lib_name);
    end
    
    comp_fun_script = fileread(fullfile(get_app_template_path(), template_name));
    
    ext_fun_script_new = replace(comp_fun_script, '{{function_name}}', function_name);
    ext_fun_script_new = replace(ext_fun_script_new, '{{class_name}}', classname);
    ext_fun_script_new = replace(ext_fun_script_new, '{{input_args}}', input_args);
    ext_fun_script_new = replace(ext_fun_script_new, '{{ctor_args}}', ctor_args);
    ext_fun_script_new = replace(ext_fun_script_new, '{{cfg_args}}', cfg_args);
    ext_fun_script_new = replace(ext_fun_script_new, '{{step_args}}', step_args);
    ext_fun_script_new = replace(ext_fun_script_new, '{{output_args_fn}}', output_args_fn);
    ext_fun_script_new = replace(ext_fun_script_new, '{{output_args_comp}}', output_args);
    ext_fun_script_new = replace(ext_fun_script_new, '{{extrinsic_init}}', extrinsic_init);
    fun_script_new = replace(ext_fun_script_new, '{{logging_define}}', logging_define);
end


function o = bracket_outputs(o)
   splits = strsplit(o, ',');
   if length(splits) > 1
       o = strcat('[', enlist_args(o), ']');
   end   
end


function src = generate_logging_function(info, lib_name)
    m = ComponentManager.get(info.Type);
    log_desc = m.get_component_log_description(info.Name, lib_name);
    src = "";
    if ~isempty(log_desc) 
        for i=1:length(log_desc)
            d = log_desc{i};
            src = src + "    " + strcat('log.', d.Name, ' = data.', d.Name, ';') + newline;
        end
    else
        src = src + "    " + strcat('log = 0;') + newline;
    end
end
function fun_script_new = resolve_component_script_template(info, ...
    template_name, function_name, classname, ...
    input_args, output_args, ctor_args, ...
    cfg_args, step_args, extrinsic_init)

    if ~endsWith(template_name, '.mt')
        template_name = strcat(template_name, '.mt');
    end

    

    [has_log, logging_define] = generate_logging_function(info);
    if has_log
        output_args_fn = bracket_outputs(output_args + ", log");
    else
        output_args_fn = bracket_outputs(output_args);
    end
    
    comp_fun_script = fileread(fullfile(CSPath.get_app_template_path(), template_name));
    
    ext_fun_script_new = replace(comp_fun_script, '{{function_name}}', function_name);
    ext_fun_script_new = replace(ext_fun_script_new, '{{class_name}}', classname);
    ext_fun_script_new = replace(ext_fun_script_new, '{{input_args}}', input_args);
    ext_fun_script_new = replace(ext_fun_script_new, '{{ctor_args}}', ctor_args);
    ext_fun_script_new = replace(ext_fun_script_new, '{{cfg_args}}', cfg_args);
    ext_fun_script_new = replace(ext_fun_script_new, '{{step_args}}', step_args);
    ext_fun_script_new = replace(ext_fun_script_new, '{{output_args}}', output_args);
    ext_fun_script_new = replace(ext_fun_script_new, '{{output_args_fn}}', output_args_fn);
    ext_fun_script_new = replace(ext_fun_script_new, '{{extrinsic_init}}', extrinsic_init);
    fun_script_new = replace(ext_fun_script_new, '{{logging_define}}', logging_define);
end


function o = bracket_outputs(o)
   splits = strsplit(o, ',');
   if length(splits) > 1
       o = strcat('[', enlist_args(o), ']');
   end   
end


function [has_log, src] = generate_logging_function(info)
    r = ComponentRegister.get(info.Type);
    log_desc = r.get_component_log_description_from_file(info.ComponentPath);
    src = "";
    if ~isempty(log_desc) 
        has_log = 1;
        for i=1:length(log_desc)
            d = log_desc{i};
            src = src + "    " + strcat('log.', d.Name, ' = data.', d.Name, ';') + newline;
        end
    else
        has_log = 0;
        src = src + "    " + strcat('log = 0;') + newline;
    end
end
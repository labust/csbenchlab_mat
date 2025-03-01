function generate_get_m_controller_log_function_handle(controller_registry, lib_name)

    
    f_name = strcat('get_m_log_fh__', lib_name);
    path = get_app_code_autogen_path();
    f_path = fullfile(path, strcat(f_name, '.m'));
    if exist(f_path, 'file')
        delete(f_path);
    end
    
    src = "function fh = " + f_name + "(class_name)" + newline;
    for i=1:length(controller_registry)
        info = controller_registry{i};
        fn_name = strcat('gen_create_logs__', replace(info.Name, ' ', '_'));
        if i == 1
            src = src + "    " + strcat('if strcmp(class_name, "', info.Name, '")') + newline;
        else
            src = src + "    " + strcat('elseif strcmp(class_name, "', info.Name, '")') + newline;
        end
        src = src + "        " + strcat('fh = @', fn_name, ';') + newline;
    end
    src = src + '    else' + newline;
    src = src + '        error("Unknown class type")' + newline;

    src = src + '    end' + newline;
    
    src = src + 'end';
    fid = fopen(f_path, 'wt');
    fprintf(fid, src);
    fclose(fid);

    update_get_m_controller_log_function_handle();
end


function update_get_m_controller_log_function_handle()
    list = list_component_libraries();

    f_name = strcat('get_m_controller_log_function_handle');
    path = get_app_code_autogen_path();
    f_path = fullfile(path, strcat(f_name, '.m'));
    if exist(f_path, 'file')
        delete(f_path);
    end
    
    src = "function fh = " + f_name + "(class_name, lib_name)" + newline;
    for i=1:length(list)
        lib = list(i);
        fn_name = strcat('get_m_log_fh__', replace(lib.Name, ' ', '_'));
        if i == 1
            src = src + "    " + strcat('if strcmp(lib_name, "', lib.Name, '")') + newline;
        else
            src = src + "    " + strcat('elseif strcmp(lib_name, "', lib.Name, '")') + newline;
        end
        src = src + "        " + strcat("fh = ", fn_name, "(class_name);") + newline;
    end
    src = src + '    else' + newline;
    src = src + '        error("Unknown library")' + newline;

    src = src + '    end' + newline;
    
    src = src + 'end';
    fid = fopen(f_path, 'wt');
    fprintf(fid, src);
    fclose(fid);

    
end
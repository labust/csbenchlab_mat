function setup_simulink_explicit_functions(curr_model, info, blocks)
    ext_value = 0;
    if isfield(info.Metadata, 'Extrinsic')
        ext_value = info.Metadata.Extrinsic;
    end
    mws = get_param(curr_model, 'modelworkspace');
    mws.assignin('extrinsic', ext_value);

    for i=1:length(blocks.cs_blocks)
        b = blocks.cs_blocks{i};
        
        if ~model_has_tag(b, '__cs_m')
            continue
        end
        linfo = libinfo(b);


        block_path = linfo.ReferenceBlock;
        block_name = split(block_path, '/');
        block_name = block_name{end};
        fun_block_name = [block_name, '_fun'];
    
        fun_block = get_function_block(block_path, fun_block_name);

        split_lines = splitlines(fun_block.Script);


        % HARDCODE
        if model_has_tag(b, '__cs_m_ctl')
            BEGIN_LINE = 13;
        else
            BEGIN_LINE = 11;
        end

        ext_fun_script = strjoin(split_lines(BEGIN_LINE:end), newline);

        first_bra = strfind(ext_fun_script, '(');
        first_bra = first_bra(1);
        last_space = strfind(ext_fun_script(1:first_bra), ' ');
        last_space = last_space(end);
         
        function_name = ext_fun_script(last_space+1:first_bra-1);
        new_name = strcat(function_name, '_ext');

        ext_fun_script_new = replace(ext_fun_script, function_name, new_name);
        
        [env_path, ~] = fileparts(which(curr_model));
        ext_file = fullfile(env_path, 'autogen', strcat(new_name, '.m'));
        if ~exist(ext_file, 'file')
            f = fopen(ext_file, "w");
            fprintf(f, ext_fun_script_new);
            fclose(f);
        end
    end
end


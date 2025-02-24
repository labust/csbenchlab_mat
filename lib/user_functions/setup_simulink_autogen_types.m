function setup_simulink_autogen_types(curr_model)
    
    env_path = fileparts(which(curr_model));
    loaded = load(fullfile(env_path, 'autogen', strcat(curr_model, '.mat')));
    blocks = loaded.blocks;
    hws = get_param(curr_model, 'modelworkspace');


    for i=1:length(blocks.cs_blocks)
        path = blocks.cs_blocks{i};
        if model_has_tag(path, '__cs_m')
            b_h = getSimulinkBlockHandle(path);
            c = libinfo(path);

            is_m_controller = model_has_tag(path, '__cs_m_ctl');

            class_name = get_m_component_class_name(c.ReferenceBlock);

            name = make_class_name(path);
            
               
            io_args = get_m_component_inputs(class_name);
            params = eval_component_params(path);

            if is_m_controller
                 mux = get_controller_mux_struct(path);
                 set_mask_values(b_h, 'u_ic', mat2str(zeros(length(mux.Outputs), 1)));
            end
            
            for l=1:length(io_args)
                a = io_args{l};
                if isa(a.Dim, 'function_handle')
                    if is_m_controller
                        dim = a.Dim(params, mux);
                    else
                        dim = a.Dim(params);
                    end
                else
                    dim = a.Dim;
                end
            
                if isa(dim, 'struct')
                    type_name = strcat(name, '_', io_args{l}.Name, "_T");
                else
                    type_name = 'double';
                end
                set_mask_values(b_h, strcat(a.Name, '_T'), type_name);
            end

            data_name = strcat(name, '_data');
            data_type_name = strcat(name, '_DT');
            try
                data = hws.getVariable(data_name);
                if isnumeric(data)
                    data_type_name = '"double"';
                end
            catch
            end
            set_mask_values(b_h, 'data', data_name);
            set_mask_values(b_h, 'DataType', data_type_name);

 
            if isnumeric(params) && isequal(params, 0)
                params_type_name = '"double"';
            else
                params_type_name = strcat(name, '_PT');
            end
            set_mask_values(b_h, 'ParamsType', params_type_name);

            log_bus_name = strcat(name, '_LT');
            set_mask_values(b_h, 'LogEntryType', log_bus_name);
        end
    end
end
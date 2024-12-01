function setup_simulink_autogen_types(curr_model)
    
    env_path = fileparts(which(curr_model));
    loaded = load(fullfile(env_path, 'autogen', strcat(curr_model, '.mat')));
    info = loaded.env_info;
    blocks = loaded.blocks;
    
    for i=1:length(info.Controllers)
        c_info = info.Controllers(i);
        b = blocks.controllers(i);
    
        if c_info.IsComposable
            components = c_info.Components;
        else
            components = c_info;
        end
    
        for j=1:length(components)
            comp = components(j);
            b_comp = b.Components(j);
    
    
            if ~is_valid_field(b_comp, 'MControllers')
                continue
            end

            for k=1:length(b_comp.MControllers)
                b_c = b_comp.MControllers(k);
                b_h = getSimulinkBlockHandle(b_c.Path);

                class_name = get_m_component_class_name(b_c.ReferenceBlock);
    
                name =  make_class_name(b_c.Path); % strcat(b_comp.Name, '_', comp.ClassName);
                
                   
                io_args = get_m_component_inputs(class_name);
                params = eval_controller_params(b_c.Path);
                
                % generate bus data types for inputs
                for l=1:length(io_args)
                    a = io_args{l};
                    if isa(a.Dim, 'function_handle')
                        dim = a.Dim(params, comp.Mux);
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
                set_mask_values(b_h, 'data', data_name);
                data_type_name = strcat(name, '_DB');
                set_mask_values(b_h, 'DataType', data_type_name);
                params_type_name = strcat(name, '_PB');
                set_mask_values(b_h, 'ParamsType', params_type_name);
                log_bus_name = strcat(name, '_LB');
                set_mask_values(b_h, 'LogEntryType', log_bus_name);
            end
        end
    end
end
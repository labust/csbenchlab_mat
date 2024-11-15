function on_model_save_impl()
    
    curr_model = gcs;
    pa = @BlockHelpers.path_append;
    handle = getSimulinkBlockHandle(curr_model);
    
    if isempty(curr_model)
        return
    end
    
    folder_path = fileparts(which(curr_model));
    
    loaded = load(pa(folder_path, 'autogen', strcat(curr_model, '.mat')));
    info = loaded.env_info;
    blocks = loaded.blocks;
    
    
    for i=1:length(info.Controllers)
        c_info = info.Controllers(i);
        b = blocks.controllers(i);
        na = @GeneratorHelpers.name_append;
    
        if is_valid_field(c_info, 'Components')
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
    
                class_name = get_m_controller_class_name(b_c.ReferenceBlock);
               
                
                % generate bus data types for controller data
                name =  make_class_name(b_c.Path); % strcat(b_comp.Name, '_', comp.ClassName);
                log_bus_name = strcat(name, '_LB');
                set_mask_values(b_h, 'LogEntryType', log_bus_name);
                   
                io_args = get_m_controller_inputs(class_name);
                params = eval_controller_params(comp, b_comp, b_c);

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
            end
        end
    
    end
end
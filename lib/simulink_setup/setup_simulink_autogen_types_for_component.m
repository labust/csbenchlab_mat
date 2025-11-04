function setup_simulink_autogen_types_for_component(curr_model, path_or_h, hws)
    
    if is_block_component_implementation(path_or_h, 'slx')
        return
    end
    
    if ~exist('hws', 'var')
        hws = get_param(curr_model, 'modelworkspace');
    end

    if isa(path_or_h, 'double') % if it is a handle
        b_h = path_or_h;
        path = getfullname(path_or_h);
    else
        path = path_or_h;
        b_h = getSimulinkBlockHandle(path);
    end

    
    c = libinfo(path);

    is_controller = is_block_component_of_type(path_or_h, 'ctl');

    class_name = get_component_class_name(c(1).ReferenceBlock);
    typ = get_component_script_parameter_ref(c(1).ReferenceBlock, '__plugin_type');
    lib_name = get_component_script_parameter_ref(c(1).ReferenceBlock, '__lib_name');
    m = ComponentManager.get(typ);

    name = make_class_name(path);
    
    io_args = m.get_component_inputs(class_name, lib_name);
    params = get_component_params_from_block(path);

    if is_controller
         mux = get_controller_mux_struct(path);
         set_mask_values(b_h, 'u_ic', mat2str(zeros(length(mux.Outputs), 1)));
    end
    
    for l=1:length(io_args)
        a = io_args{l};
        if isa(a.Dim, 'function_handle')
            if is_controller
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
        if has_mask_parameter(b_h, strcat(a.Name, '_T'))
            set_mask_values(b_h, strcat(a.Name, '_T'), type_name);
        end
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
    if has_mask_parameter(b_h, 'data')
        set_mask_values(b_h, 'data', data_name);
    end
    if has_mask_parameter(b_h, 'DataType')
        set_mask_values(b_h, 'DataType', data_type_name);
    end

    if isnumeric(params) && isequal(params, 0)
        params_type_name = '"double"';
    else
        params_type_name = strcat(name, '_PT');
    end
    if has_mask_parameter(b_h, 'ParamsType')
        set_mask_values(b_h, 'ParamsType', params_type_name);
    end

    log_bus_name = strcat(name, '_LT');
    log_desc = m.get_component_log_description(class_name, lib_name);
    if ~isempty(log_desc)
        set_mask_values(b_h, 'LogEntryType', log_bus_name);
    else
        set_mask_values(b_h, 'LogEntryType', '"double"');
    end
end
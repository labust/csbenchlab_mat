function setup_simulink_components(model_name, info, blocks)
    pa = @BlockHelpers.path_append;

    folder_path = fileparts(which(model_name));
    
    bus_types_name = strcat(model_name, '_bus_types.sldd');
    mws = get_param(model_name, 'modelworkspace');

    mws.assignin('gen_blocks', blocks);


    sldd_f = pa(folder_path, 'autogen', bus_types_name);
    addpath(pa(folder_path, 'autogen'));
    Simulink.data.dictionary.closeAll('-discard');
    if exist(sldd_f, 'file')
        delete(sldd_f)
    end

    dictObj = Simulink.data.dictionary.create(sldd_f);
    type_dict = dictObj.getSection("Design Data");

    for i=1:length(blocks.controllers)
        for j=1:length(blocks.controllers(i).Components)
            setup_component_mask_parameters(blocks.controllers(i).Components(j));
        end
    end

    for i=1:length(blocks.systems.systems)
        setup_component_mask_parameters(blocks.systems.systems(i));
    end

    cs_comps = blocks.cs_blocks;

    for i=1:length(cs_comps)
        if model_has_tag(cs_comps{i}, '__cs_m')
            type_dict = setup_simulink_m_component(cs_comps{i}, model_name, folder_path, type_dict);
        elseif model_has_tag(cs_comps{i}, '__cs_slx')
        elseif model_has_tag(cs_comps{i}, '__cs_py')
        end
    end
    set_param(model_name, 'DataDictionary', bus_types_name);
    saveChanges(dictObj)

end

function set_function_input_type(handle, input_port_idx, type_name)
   
    lhs = get_param(handle, 'LineHandles');
    src = get_param(lhs.Inport(input_port_idx), 'SrcBlockHandle');
    name = get_param(handle, 'Name');
    fname = getfullname(handle);
    parname = strrep(fname, name, '');
    parname = parname(1:end-1);
    
    ok = 1;
    while 1
        if slreportgen.utils.isMATLABFunction(src)
            break
        end
        % TODO: Recursive search through subsystems
        ok = 0;
        break
    end

    if ok == 0
        error(['Complex input parameters require MATLAB Function block ' ...
            'as inputs']);
    end

    f_lhs = get_param(src, 'LineHandles');
    for i=1:length(f_lhs.Outport)
        if get_param(f_lhs.Outport(i), 'DstBlockHandle') == handle
            break
        end
    end

    fun_block = get_function_block(parname, get_param(src, 'Name'));

    fun_block.Outputs(i).DataType = type_name;
    a  = 5;

end


function busses = generate_input_bus(block_name, data, busses)
    fields = fieldnames(data);
    new_data_bus = Simulink.Bus;
    for j=1:length(fields)
        name = fields(j);
        name = name{1};
        value = data.(name);

        el = Simulink.BusElement;
        el.Name = name;
        el.DimensionsMode = "Fixed";
        

        if isa(value, 'struct')
            el.Dimensions = size(value);
            busses = generate_bus_types(strcat(block_name, '_', name), value, busses);
            el.DataType = strcat(block_name, '_', name);
        else
            el.Dimensions = value;
        end
        new_data_bus.Elements(end+1) = el; 
    end
    new_data_bus_s.Name = block_name;
    new_data_bus_s.Bus = new_data_bus;
    busses{end+1} = new_data_bus_s;
end

function replaced = replace_indexers(data)
    
    if isnumeric(data)
        replaced = data;
        return
    end

    fields = fieldnames(data);
    replaced = struct;
    for j=1:length(fields)
        name = fields(j);
        name = name{1};
        value = data.(name);

        if isa(value, 'struct')
           replaced.(name) = replace_indexers(value);
        
        elseif isa(value, 'Indexer')
           replaced.(name).b = value.b;
           replaced.(name).e = value.e;
           replaced.(name).sz = value.sz;
           replaced.(name).r = value.r;
        else
           replaced.(name) = value;
        end
    end
end

function busses = generate_bus_types(block_name, name_sufix, data, busses)

    if isnumeric(data)
        return
    end
    
    fields = fieldnames(data);
    new_data_bus = Simulink.Bus;
    for j=1:length(fields)
        name = fields(j);
        name = name{1};
        value = data.(name);

        el = Simulink.BusElement;
        el.Name = name;
        el.DimensionsMode = "Fixed";
        el.Dimensions = size(value);

        if isa(value, 'struct')
            busses = generate_bus_types(strcat(block_name, '_', name), ...
                name_sufix, value, busses);
            el.DataType = strcat(block_name, '_', name, name_sufix);
        elseif isa(value, 'Indexer')
            indexer_bus_s = create_indexer(strcat(block_name, '_', name), value);
            busses{end+1} = indexer_bus_s;
            el.DataType = indexer_bus_s.Name;
        end
        new_data_bus.Elements(end+1) = el; 
    end
    new_data_bus_s.Name = strcat(block_name, name_sufix);
    new_data_bus_s.Bus = new_data_bus;
    busses{end+1} = new_data_bus_s;

    
end


function indexer_bus_s = create_indexer(block_name, indexer)
    indexer_bus = Simulink.Bus;
    bel = Simulink.BusElement;
    bel.Name = 'b';
    bel.DimensionsMode = "Fixed";
    bel.Dimensions = 1;
    eel = Simulink.BusElement;
    eel.Name = 'e';
    eel.DimensionsMode = "Fixed";
    eel.Dimensions = 1;
    szel = Simulink.BusElement;
    szel.Name = 'sz';
    szel.DimensionsMode = "Fixed";
    szel.Dimensions = 1;
    rel = Simulink.BusElement;
    rel.Name = 'r';
    rel.DimensionsMode = "Fixed";
    rel.Dimensions = size(indexer.r);
    indexer_bus.Elements(1) = bel; 
    indexer_bus.Elements(2) = eel; 
    indexer_bus.Elements(3) = szel; 
    indexer_bus.Elements(4) = rel; 
    indexer_bus_s.Name = strcat(block_name, '_I'); 
    indexer_bus_s.Bus = indexer_bus;
end


function setup_component_mask_parameters(c)
    params = eval_component_params(c.Path);
    evaluate_mask_parameters_on_load(params, c.Path);
end


function type_dict = setup_simulink_m_component(c, model_name, folder_path, type_dict)
    c_path = getfullname(c);
    params = eval_component_params(c_path);
    is_m_controller = model_has_tag(c_path, '__cs_m_ctl');
    l_info = libinfo(c);

    class_name = get_m_component_class_name(l_info.ReferenceBlock);    
    
    add_mux_arg_str = '';
    if is_m_controller
        try
            mux = get_controller_mux_struct(c_path);
        catch
            mux = evalin('base', 'mux');
        end
        add_mux_arg_str = ', mux';
    end
    try
        data = eval(strcat(class_name, '.create_data_model(params', add_mux_arg_str, ')'));
    catch ME
        if strcmp(ME.identifier,  'MATLAB:subscripting:classHasNoPropertyOrMethod')
            data = 0;
            % error(['Class ', class_name, ' must implement static method create_data_model']);
        else
            error(strcat('Error calling "', class_name, '.create_data_model(params', add_mux_arg_str, ')'));
            rethrow(ME);
        end
    end

    io_args = get_m_component_inputs(class_name);
    
    data_f_name = strcat(folder_path, '/autogen/data_bus_.m');
    if exist(data_f_name, 'file')
        delete(data_f_name);
    end


    if is_m_controller
        a = 5;
        
    end    


    % generate bus data types for controller data
    name =  make_class_name(c_path);
    busses = {};
    busses = generate_bus_types(name, '_DT', data, busses);
    
    % if param struct is valid
    if ~isnumeric(params) && ~isempty(fieldnames(params))
        % generate bus data types for controller params
        busses = generate_bus_types(name, '_PT', params, busses);
        for l=1:length(busses)
            type_dict.addEntry(busses{l}.Name, busses{l}.Bus);
        end
    end


    % generate bus data types for logs
    log_desc = get_m_component_log_description(class_name);
    new_log_bus = Simulink.Bus;
    for l=1:length(log_desc)
        d = log_desc{l};
        
        try 
            value = data.(d.Name);
        catch
            error(['Log entry "', d.Name, '" does not exist in the data model']);
        end

        el = Simulink.BusElement;
        el.Name = d.Name;
        el.DimensionsMode = "Fixed";
        el.Dimensions = size(value);
        new_log_bus.Elements(end+1) = el; 
    end
    log_bus_name = strcat(name, '_LT');
    type_dict.addEntry(log_bus_name, new_log_bus);
       
    % generate bus data types for inputs
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
            busses = {};
            type_name = get_argument_type_name(c_path, io_args{l}.Name);
            busses = generate_input_bus(type_name, dim, busses);
            for o=1:length(busses)
               type_dict.addEntry(busses{o}.Name, busses{o}.Bus);
            end
        end
    end

    data_name = strcat(name, '_data');
    no_indexers_data = replace_indexers(data);
    mws = get_param(model_name, 'modelworkspace');
    mws.assignin(data_name, no_indexers_data);
    
end
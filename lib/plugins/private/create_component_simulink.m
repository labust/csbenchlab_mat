function block_path = create_component_simulink(info, lib_name, comp_type, tags, script_template, inputs, outputs, ctor_args, cfg_args, step_args, mask_parameters, extrinsic_init, icon, size)
    block_name = convertStringsToChars(info.Name);
    
    sim_lib_name = strcat(lib_name, '_', comp_type);

    h_first = getSimulinkBlockHandle(sim_lib_name);

    if h_first == -1
        load_and_unlock_system(sim_lib_name);
    end

    block_path = strcat(sim_lib_name, '/', block_name);
    handle = getSimulinkBlockHandle(block_path);
    if handle ~= -1
        delete_block(block_path);    
    end
    handle = add_block('simulink/Ports & Subsystems/Subsystem', block_path); 
    for i=1:length(tags)
        model_append_tag(handle, tags{i});
    end

    % delete io ports from subsystem, they will be created later
    inport_h = getSimulinkBlockHandle(...
        find_system(block_path, 'SearchDepth', 1, 'BlockType', 'Inport'));
    outport_h = getSimulinkBlockHandle(...
        find_system(block_path, 'SearchDepth', 1, 'BlockType', 'Outport'));
    
    inport_h_p = get_param(inport_h, 'PortHandles');
    outport_h_p = get_param(outport_h, 'PortHandles');

    delete_line(block_path, inport_h_p.Outport, outport_h_p.Inport);
    delete_block(inport_h); delete_block(outport_h);


    % create function block
    fun_block_name = strcat(block_name, '_fun');
    fun_block_path = strcat(block_path, '/', fun_block_name);


    fun_handle = add_block('simulink/User-Defined Functions/MATLAB Function', fun_block_path); 
    fun_block = get_function_block(block_path, fun_block_name);

    fun_block.ChartUpdate = 'DISCRETE';
    fun_block.SampleTime = '-1';
    obj_name = info.Name;
    
    input_cell = arrayfun(@(x) {x.Name}, inputs);
    output_cell = arrayfun(@(x) {x.Name}, outputs);

    r = ComponentRegister.get(info.Type);
    log_desc = r.get_component_log_description_from_file(info.ComponentPath);
    add_logging = ~isempty(log_desc);

    if add_logging
        fn_output_cell = [output_cell, {'log'}];
    else
        fn_output_cell = output_cell;
    end

    unique_name = replace(new_uuid, '-', '');

    function p = generate_script_parameters
         p = "% __classname:=" + '"' + obj_name + '";' + newline ...
           + "% __lib_name:=" + '"' + lib_name + '";' + newline ...
           + "% __comp_type:=" + '"' + comp_type + '";' + newline ...
           + "% __plugin_type:=" + '"' + info.Type + '";' + newline ...
           + "% __fnname:=" + '"' + "fcn_" + unique_name + '";' + newline ...
           + "% __input_args:=" + '"' + enlist_args(input_cell) + ', pid__, iid__";' + newline ...
           + "% __output_args:=" + '"' + enlist_args(output_cell) + '";' + newline ...
           + "% __fn_output_args:=" + '"' + enlist_args(fn_output_cell) + '";' + newline ...
           + "% __ctor_args:=" + '"' + enlist_args(ctor_args) + ", 'pid', pid__, 'iid', iid__"+ '";' + newline...
           + "% __cfg_args:=" + '"' + enlist_args(cfg_args) + '";' + newline...
           + "% __step_args:=" + '"' + enlist_args(step_args) + '";';
    end
    
    fun_block.Script = generate_script_parameters() + newline ...        
        + resolve_component_script_template(info, script_template, ...
        unique_name, obj_name, enlist_args(input_cell), enlist_args(output_cell), ...
        enlist_args(ctor_args), enlist_args(cfg_args), enlist_args(step_args), ...
        extrinsic_init);

    % extrinsic parameter
    if strcmp(fun_block.Inputs(end).Name, 'extrinsic')
        fun_block.Inputs(end).DataType = 'int32';
        fun_block.Inputs(end).Tunable = 0;
        fun_block.Inputs(end).Scope = 'Parameter';
    end

    % iid parameter
    fun_block.Inputs(end).DataType = 'uint8';
    fun_block.Inputs(end).Tunable = 0;
    fun_block.Inputs(end).Scope = 'Parameter';

    % pid parameter
    fun_block.Inputs(end).DataType = 'uint8';
    fun_block.Inputs(end).Tunable = 0;
    fun_block.Inputs(end).Scope = 'Parameter';

    
    for i=length(inputs):-1:1
        fun_block.Inputs(i).Tunable = inputs(i).Tunable;
        if ~isempty(inputs(i).DataType)
            fun_block.Inputs(i).DataType = inputs(i).DataType;
        end
        if ~isempty(inputs(i).Scope)
            fun_block.Inputs(i).Scope = inputs(i).Scope;
        end
    end

    if add_logging
        fun_block.Outputs(end).DataType = 'LogEntryType';
        fun_block.Outputs(end).Tunable = 0;
    end
    
    for i=length(outputs):-1:1
        if ~isempty(outputs(i).DataType)
            fun_block.Outputs(i).DataType = outputs(i).DataType;
        end
    end

    fun_p = get_param(fun_handle, 'PortHandles');
    fun_pos = get_param(fun_handle, 'Position');

    pos = [-150 -15];
    in_handles = [];
    in_ports = {};
    for i=1:length(fun_p.Inport)
        in_handles(end+1) = add_block('simulink/Quick Insert/Ports & Subsystems/Inport', strcat(block_path, '/', input_cell{i})); 
        
        if any(inputs(i).Size > 0) 
            set_param(in_handles(end), 'PortDimensions', mat2str(inputs(i).Size));
        end
        
        in_ports{end+1} = get_param(in_handles(end), 'PortHandles');
        block_offset(in_handles(end), fun_pos, pos);
        add_line(block_path, in_ports{i}.Outport, fun_p.Inport(i), "autorouting", "smart");

        pos = [pos(1), pos(2) + 15];

    end
    
    pos = [150, 0];
    out_handles = [];
    out_ports = {};
    for i=1:length(fun_p.Outport)
        if add_logging && i == length(output_cell) + 1
            n = 'log';
        else
            n = output_cell{i};
        end
        out_handles(end+1) = add_block('simulink/Quick Insert/Ports & Subsystems/Outport', strcat(block_path, '/', n)); 
        
        if i <= length(outputs) && any(outputs(i).Size > 0) 
            set_param(out_handles(end), 'PortDimensions', mat2str(outputs(i).Size));
        end
        
        out_ports{end+1} = get_param(out_handles(end), 'PortHandles');
        block_offset(out_handles(end), fun_pos, pos);
        add_line(block_path, fun_p.Outport(i), out_ports{i}.Inport, "autorouting", "smart");
        pos = [pos(1), pos(2) + 15];
    end


    set_block_mask_parameters(handle, block_name, ...
        [get_component_default_mask_params(info, lib_name, add_logging), mask_parameters]);

    if exist("icon", 'var')
        set_param(handle, 'MaskBlockDVGIcon', strcat('MaskBlockIcon.', icon));
        set_param(handle, 'MaskIconRotate', 'off');
    end

    if ~exist("size", 'var')
        size = [80, 50];
    end

    GRID_LEN = 4;
    count = length(find_system(sim_lib_name, 'SearchDepth', 1)) - 1;
    idx_j = floor((count-1) / GRID_LEN) + 1;
    idx_i = mod((count-1), GRID_LEN) + 1;
    dl = 200;
    
    position = [idx_i * dl, idx_j * dl, idx_i * dl + size(1), idx_j * dl + size(2)]';
    set_param(handle, 'Position', position);

    save_system(sim_lib_name);
    
    if h_first == -1
        close_system(sim_lib_name);
    end

end

